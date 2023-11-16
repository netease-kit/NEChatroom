#
# Be sure to run `pod lib lint NEVoiceRoomBaseUIKit.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#
require_relative "../../PodConfigs/config_podspec.rb"
require_relative "../../PodConfigs/config_third.rb"
require_relative "../../PodConfigs/config_local_common.rb"
require_relative "../../PodConfigs/config_local_social.rb"

Pod::Spec.new do |s|
  s.name             = 'NEVoiceRoomBaseUIKit'
  s.version          = '0.1.0'
  s.summary          = 'A short description of NEVoiceRoomBaseUIKit.'
  s.homepage         = YXConfig.homepage
  s.license          = YXConfig.license
  s.author           = YXConfig.author
  s.ios.deployment_target = YXConfig.deployment_target
  s.swift_version = YXConfig.swift_version
  
  if ENV["USE_SOURCE_FILES"] == "true"
    s.source = { :git => "https://github.com/netease-kit/" }

    s.source_files = 'NEVoiceRoomBaseUIKit/Classes/**/*'
    s.resource = 'NEVoiceRoomBaseUIKit/Assets/**/*'
    s.dependency NESocialUIKit.name
    s.dependency NEVoiceRoomKit.name
    s.dependency SnapKit.name
    s.dependency LottieSwift.name
    s.dependency MJRefresh.name
  else

  end

  YXConfig.pod_target_xcconfig(s)
end
