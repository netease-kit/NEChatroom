# Copyright (c) 2022 NetEase, Inc. All rights reserved.
# Use of this source code is governed by a MIT license that can be
# found in the LICENSE file.

require_relative "../../PodConfigs/config_podspec.rb"
require_relative "../../PodConfigs/config_third.rb"
require_relative "../../PodConfigs/config_local_social.rb"
require_relative "../../PodConfigs/config_local_common.rb"
require_relative "../../PodConfigs/config_local_core.rb"

Pod::Spec.new do |s|
  s.name             = 'NEVoiceRoomUIKit'
  s.version          = '1.0.0'
  s.summary          = 'A short description of NEVoiceRoomUIKit.'
  s.homepage         = YXConfig.homepage
  s.license          = YXConfig.license
  s.author           = YXConfig.author
  s.ios.deployment_target = YXConfig.deployment_target
  
  if ENV["USE_SOURCE_FILES"] == "true"
    s.source = { :git => "https://github.com/netease-kit/" }

    s.source_files = 'NEVoiceRoomUIKit/Classes/**/*'
    s.resource = 'NEVoiceRoomUIKit/Assets/**/*'
    s.dependency NEVoiceRoomKit.name
    s.dependency NEOrderSong.name
    s.dependency Masonry.name
    s.dependency MJRefresh.name
    s.dependency LottieOC.name, LottieOC.version
    s.dependency NEUIKit.name
    s.dependency SDWebImage.name
    s.dependency NECopyrightedMedia.name
    s.dependency NEAudioEffectKit.name
    s.dependency NECoreKit.name
    s.dependency LottieSwift.name
    s.dependency NESocialUIKit.name
    s.dependency NECommonUIKit.name
    s.dependency NEVoiceRoomBaseUIKit.name
  else

  end
  YXConfig.pod_target_xcconfig(s)

end
