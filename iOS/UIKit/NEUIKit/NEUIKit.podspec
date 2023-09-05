#
# Be sure to run `pod lib lint NEUIKit.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#
require_relative "../../PodConfigs/config_podspec.rb"

Pod::Spec.new do |s|
  s.name             = 'NEUIKit'
  s.version          = '1.0.0'
  s.summary          = 'A short description of NEUIKit.'
  s.homepage         = YXConfig.homepage
  s.license          = YXConfig.license
  s.author           = YXConfig.author
  s.ios.deployment_target = YXConfig.deployment_target
  s.source = { :git => "https://github.com/netease-kit/" }

  s.source_files = 'NEUIKit/Classes/**/*'
  
  s.pod_target_xcconfig = {
    'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64',
      'BUILD_LIBRARY_FOR_DISTRIBUTION' => 'YES'
    }
  
  s.subspec 'Base' do |ss| 
    ss.source_files = 'NEUIKit/Classes/Base/**/*'
    ss.resource = 'NEUIKit/Assets/**/*'
  end
  
  s.subspec 'Category' do |ss|
    ss.source_files = 'NEUIKit/Classes/Category/**/*'
  end
  
  s.dependency 'Masonry'
  
  YXConfig.pod_target_xcconfig(s)
end
