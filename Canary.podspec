#
# Be sure to run `pod lib lint Canary.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'Canary'
  s.version          = '0.4.0'
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
  
  s.swift_version = '4.2'

  s.ios.deployment_target = '9.0'
  
  s.pod_target_xcconfig = { "DEFINES_MODULE" => "YES" }
  
  s.resource = 'Sources/Assets/Canary.bundle'
  s.user_target_xcconfig = { "GCC_PREPROCESSOR_DEFINITIONS" => 'CANARY_ENABLE=1' }

  s.source_files = 'Sources/CanarySwift/**/*'
  s.dependency 'CocoaLumberjack/Swift'
  s.dependency 'SwifterSwift'
  s.dependency 'SnapKit'
  s.dependency 'SwiftyJSON'
  s.dependency 'SocketRocket', '~> 0.5'
  s.dependency 'AFNetworking'

end
