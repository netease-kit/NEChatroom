#
# Be sure to run `pod lib lint NEVoiceRoomKit.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#
require_relative "../../PodConfigs/config_podspec.rb"
require_relative "../../PodConfigs/config_third.rb"
require_relative "../../PodConfigs/config_local_common.rb"
require_relative "../../PodConfigs/config_local_room.rb"

Pod::Spec.new do |s|
  s.name             = 'NEVoiceRoomKit'
  s.version          = '1.6.0'
  s.summary          = 'A short description of NEVoiceRoomKit.'
  s.homepage         = YXConfig.homepage
  s.license          = YXConfig.license
  s.author           = YXConfig.author
  s.ios.deployment_target = YXConfig.deployment_target
  s.swift_version = YXConfig.swift_version
  
  if ENV["USE_SOURCE_FILES"] == "true"
    s.source = { :git => "https://github.com/netease-kit/" }

    s.source_files = 'NEVoiceRoomKit/Classes/**/*'
    s.dependency NERoomKit.Base_Special
    s.dependency NERoomKit.Segment_Special
    s.dependency NERoomKit.Audio_Special
  else
    s.source = { :http => "https://yx-web-nosdn.netease.im/package/1693884382177/NEVoiceRoomKit_iOS_v1.5.0.framework.zip?download=NEVoiceRoomKit_iOS_v1.5.0.framework.zip" }
    
    s.subspec 'NOS' do |nos|
      nos.vendored_frameworks = 'NEVoiceRoomKit.framework'
      nos.dependency NERoomKit.Base
      nos.dependency NERoomKit.Segment
      nos.dependency NERoomKit.Audio
    end
    
    s.subspec 'NOS_Special' do |nos|
      nos.vendored_frameworks = 'NEVoiceRoomKit.framework'
      nos.dependency NERoomKit.Base_Special
      nos.dependency NERoomKit.Segment_Special
      nos.dependency NERoomKit.Audio_Special
    end
    
    s.subspec 'FCS' do |fcs|
      fcs.vendored_frameworks = 'NEVoiceRoomKit.framework'
      fcs.dependency NERoomKit.Base_FCS
      fcs.dependency NERoomKit.Segment
      fcs.dependency NERoomKit.Audio
    end
    
    s.subspec 'FCS_Special' do |fcs|
      fcs.vendored_frameworks = 'NEVoiceRoomKit.framework'
      fcs.dependency NERoomKit.Base_FCS_Special
      fcs.dependency NERoomKit.Segment_Special
      fcs.dependency NERoomKit.Audio_Special
    end
    s.default_subspecs = 'NOS'
  end

  YXConfig.pod_target_xcconfig(s)

end
