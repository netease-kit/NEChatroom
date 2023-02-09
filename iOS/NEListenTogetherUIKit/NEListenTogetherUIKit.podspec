# Copyright (c) 2022 NetEase, Inc. All rights reserved.
# Use of this source code is governed by a MIT license that can be
# found in the LICENSE file.

Pod::Spec.new do |s|
  s.name             = 'NEListenTogetherUIKit'
  s.version          = '1.0.0'
  s.summary          = 'A short description of NEListenTogetherUIKit.'
  
  # This description is used to generate tags and improve search results.
  #   * Think: What does it do? Why did you write it? What is the focus?
  #   * Try to keep it short, snappy and to the point.
  #   * Write the description between the DESC delimiters below.
  #   * Finally, don't worry about the indent, CocoaPods strips it!
  
  s.description      = <<-DESC
  TODO: Add long description of the pod here.
  DESC
  
  s.homepage         = 'https://github.com/969901329@qq.com/NEListenTogetherUIKit'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { '969901329@qq.com' => 'mayajie@corp.netease.com' }
  s.source           = { :git => 'https://github.com/969901329@qq.com/NEListenTogetherUIKit.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'
  
  s.ios.deployment_target = '9.0'
  s.swift_version = '5.0'
  
  s.source_files = 'NEListenTogetherUIKit/Classes/**/*'
  
  s.dependency 'NEListenTogetherKit'
  s.dependency 'Masonry'
  s.dependency 'ReactiveObjC'
  s.dependency 'libextobjc'
  s.dependency 'YYModel'
  s.dependency 'MJRefresh'
  s.dependency 'M80AttributedLabel'
  s.dependency 'lottie-ios', '~> 2.5.3'
  s.dependency 'NEUIKit'
  s.dependency 'SDWebImage'
  s.dependency 'Toast'
  s.dependency 'NECopyrightedMedia'
  s.dependency 'NELyricUIKit'
  s.dependency 'NEAudioEffectKit'
  s.dependency 'LottieSwift'
  s.dependency 'NECoreKit'
  
  s.resource_bundles = {
    'NEListenTogetherUIKit' => ['NEListenTogetherUIKit/Assets/**/*']
  }
  s.frameworks = 'UIKit'
end
