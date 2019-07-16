
Pod::Spec.new do |s|
  s.name             = 'Qonversion'
  s.version          = '0.2.7'
  s.summary          = 'qonversion.io'
  s.description      = <<-DESC
  Real-time app monitoring.
    Get a read on how your apps are doing in an instant and come to critical decisions quicker.
  App revenue analytics.
    Powerful yet simple subscription analytics. Conversion from install to paying user, MRR, LTV, churn.
  Offline Conversion Events.
    Feed your Facebook Ad account with the data on high-value users and out-of-the-box integration.
                       DESC
  s.homepage         = 'https://github.com/axcic/Qonversion'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Bogdan Novikov' => 'bogdan@qonversion.io' }
  s.source           = { :git => 'https://github.com/axcic/Qonversion.git', :tag => s.version.to_s }
  s.ios.deployment_target = '9.0'
  s.source_files = 'Qonversion/Classes/**/*'
  
end
