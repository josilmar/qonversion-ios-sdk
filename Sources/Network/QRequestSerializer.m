#import "QRequestSerializer.h"
#import "UserInfo.h"
#import "QDevice.h"
#import "StoreKit+Sugare.h"

@interface QRequestSerializer ()

@property (nonatomic, strong) NSString *userID;
@property (nonatomic, strong) QDevice *device;

@end

@implementation QRequestSerializer

- (instancetype)initWithUserID:(NSString *)uid {
  if (self = [super init]) {
    _userID = uid;
    _device = [[QDevice alloc] init];
  }
  return self;
}

- (NSDictionary *)launchData {
  return self.mainData;
}

- (NSDictionary *)mainData {
  return UserInfo.overallData;
}

- (NSDictionary *)purchaseData:(SKProduct *)product transaction:(SKPaymentTransaction *)transaction {
  NSMutableDictionary *result = [[NSMutableDictionary alloc] initWithDictionary:self.mainData];
  NSMutableDictionary *purchaseDict = [[NSMutableDictionary alloc] init];

  purchaseDict[@"product"] = product.productIdentifier;
  purchaseDict[@"currency"] = product.prettyCurrency;
  purchaseDict[@"value"] = product.price.stringValue;
  purchaseDict[@"transaction_id"] = transaction.transactionIdentifier ?: @"";
  purchaseDict[@"original_transaction_id"] = transaction.originalTransaction.transactionIdentifier ?: @"";
  
  if (@available(iOS 11.2, *)) {
    if (product.subscriptionPeriod != nil) {
      purchaseDict[@"period_unit"] = @(product.subscriptionPeriod.unit).stringValue;
      purchaseDict[@"period_number_of_units"] = @(product.subscriptionPeriod.numberOfUnits).stringValue;
    }
    
    if (product.introductoryPrice != nil) {
      NSMutableDictionary *introOffer = [[NSMutableDictionary alloc] init];
      
      SKProductDiscount *introductoryPrice = product.introductoryPrice;
      
      introOffer[@"value"] = introductoryPrice.price.stringValue;
      introOffer[@"number_of_periods"] = @(introductoryPrice.numberOfPeriods).stringValue;
      introOffer[@"period_number_of_units"] = @(introductoryPrice.subscriptionPeriod.numberOfUnits).stringValue;
      introOffer[@"period_unit"] = @(introductoryPrice.subscriptionPeriod.unit).stringValue;
      introOffer[@"payment_mode"] = @(introductoryPrice.paymentMode).stringValue;
      
      result[@"introductory_offer"] = introOffer;
    }
  }
  
  if (@available(iOS 13.0, *)) {
    NSString *countryCode = SKPaymentQueue.defaultQueue.storefront.countryCode ?: @"";
    purchaseDict[@"country"] = countryCode;
  }
  
  result[@"purchase"] = purchaseDict;
  return result;
}

- (NSDictionary *)attributionDataWithDict:(NSDictionary *)data fromProvider:(QAttributionProvider)provider userID:(nullable NSString *)uid {
  NSMutableDictionary *body = @{@"d": self.mainData}.mutableCopy;
  NSMutableDictionary *providerData = [NSMutableDictionary new];
  
  switch (provider) {
    case QAttributionProviderAppsFlyer:
      [providerData setValue:@"appsflyer" forKey:@"provider"];
      break;
    case QAttributionProviderAdjust:
      [providerData setValue:@"adjust" forKey:@"provider"];
      break;
    case QAttributionProviderBranch:
      [providerData setValue:@"branch" forKey:@"provider"];
      break;
  }
  
  NSString *_uid = nil;
  
  if (uid) {
    _uid = uid;
  } else {
    /** Temporary workaround for keep backward compatibility  */
    /** Recommend to remove after moving all clients to version > 1.0.4 */
    NSString *af_uid = _device.afUserID;
    if (af_uid && provider == QAttributionProviderAppsFlyer) {
      _uid = af_uid;
    }
  }
  
  [providerData setValue:data forKey:@"d"];
  
  if (_uid) {
    [providerData setValue:_uid forKey:@"uid"];
  }
  
  [body setValue:providerData forKey:@"provider_data"];
  
}

@end
