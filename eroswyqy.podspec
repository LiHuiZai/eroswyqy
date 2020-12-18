Pod::Spec.new do |s|
  s.name             = 'eroswyqy'
  s.version          = '0.1.6'
  s.summary          = 'A short description of eroswyqy.'
  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC
  s.homepage         = 'https://github.com/LiHuiZai/eroswyqy'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'xiaoxiaoh99@163.com' => 'xiaoxiaoh99@163.com' }
  s.source           = { :git => 'https://github.com/LiHuiZai/eroswyqy.git', :tag => s.version.to_s }
  s.ios.deployment_target = '9.0'

  s.source_files = 'eroswyqy/Classes/**/*'
  
  # s.resource_bundles = {
  #   'eroswyqy' => ['eroswyqy/Assets/*.png']
  # }

  s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  s.dependency 'QY_iOS_SDK', '~> 5.15.0'
end
