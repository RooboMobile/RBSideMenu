

Pod::Spec.new do |s|
  s.name             = 'RBSideMenu'
  s.version="1.0.0"
  s.summary          = 'A short description of RBNetworking.'
  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/RooboMobile/RBSideMenu'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'baxiang' => 'baxiang@roobo.com' }
  s.source           = { :git => 'https://github.com/RooboMobile/RBSideMenu.git', :tag => s.version.to_s }
  s.ios.deployment_target = '7.0'
  s.source_files = 'RBSideMenu/*.{h,m}'
 
end
