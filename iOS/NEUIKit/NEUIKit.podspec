#
# Be sure to run `pod lib lint NEUIKit.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'NEUIKit'
  s.version          = '1.0.0'
  s.summary          = 'A short description of NEUIKit.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/zhouxiaolu/NEUIKit'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'zhouxiaolu' => 'zhouxiaolu@corp.netease.com' }
  s.source           = { :git => 'https://github.com/zhouxiaolu/NEUIKit.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '9.0'

  s.source_files = 'NEUIKit/Classes/**/*'
  
  s.pod_target_xcconfig = {
    'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64',
      'BUILD_LIBRARY_FOR_DISTRIBUTION' => 'YES'
    }
  
  s.subspec 'Base' do |ss| 
    ss.source_files = 'NEUIKit/Classes/Base/**/*'
    ss.resource_bundles = {
      'NEUIKitBase' => ['NEUIKit/Assets/Base.xcassets']
    }
  end
  
  s.subspec 'Category' do |ss|
    ss.source_files = 'NEUIKit/Classes/Category/**/*'
  end
  
  s.dependency 'Masonry'
  # s.resource_bundles = {
  #   'NEUIKit' => ['NEUIKit/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
