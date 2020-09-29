#
# Be sure to run `pod lib lint Canary.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'Canary'
  s.version          = '0.2.4'
  s.summary          = 'Canary is SDK For CanaryWeb.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/Rake Yang/Canary'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Rake Yang' => 'fenglaijun@gmail.com' }
  s.source           = { :git => 'https://github.com/BinaryParadise/Canary.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'
  
  s.swift_version = '4.0'

  s.ios.deployment_target = '9.0'
  s.osx.deployment_target = '10.11'

  s.default_subspecs = 'Core'
  
  s.subspec 'Core' do |ss|
    ss.ios.source_files = 'Sources/Canary/Internal/*', 'Sources/Canary/*', 'Sources/Canary/iOS/*'
    ss.osx.source_files = 'Sources/Canary/Internal/*', 'Sources/Canary/*', 'Sources/Canary/macOS/*'
    ss.dependency 'CocoaLumberjack'
  end

  s.subspec 'Swift' do |ss|
    ss.source_files = 'Sources/CanarySwift/*'
    ss.dependency   'Canary/Core'
    ss.dependency 'CocoaLumberjack/Swift'
  end
  
  s.resource_bundle = {'Canary' => ['Sources/Assets/*']}
  s.user_target_xcconfig = { "GCC_PREPROCESSOR_DEFINITIONS" => 'CANARY_ENABLE=1' }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  s.dependency 'MJExtension'
  s.dependency 'SAMKeychain', '~> 1.5'
  s.dependency 'SocketRocket', '~> 0.5'
end
