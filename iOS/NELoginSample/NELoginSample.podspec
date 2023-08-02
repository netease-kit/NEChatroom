#
# Be sure to run `pod lib lint NELoginSample.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'NELoginSample'
  s.version          = '1.0.0'
  s.summary          = 'A short description of NELoginSample.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/mayajie@gmail.com/NELoginSample'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'mayajie@gmail.com' => 'mayajie@corp.netease.com' }
  s.source           = { :git => 'https://github.com/mayajie@gmail.com/NELoginSample.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '10.0'
  s.swift_version = '5.0'
  
  s.dependency 'NECommonKit'
  s.dependency 'SnapKit'
  s.dependency 'NECoreKit'
  

  s.source_files = 'NELoginSample/Classes/**/*'
  s.resource = 'NELoginSample/Assets/**/*'
  
  s.pod_target_xcconfig = {
    'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64',
      'BUILD_LIBRARY_FOR_DISTRIBUTION' => 'YES'
    }

end
