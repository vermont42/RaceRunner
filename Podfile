source 'https://github.com/CocoaPods/Specs.git'

platform :ios, '17.0'
use_frameworks!

target "RaceRunner" do
  pod 'AWSPinpoint'
  # version 8.3.1, the latest as of 12/18/23, causes Auto Layout bug on screens that use Google Map
  # consider filing issue: https://github.com/googlemaps/ios-maps-sdk
  pod 'GoogleMaps', '7.1.0'
  pod 'MarqueeLabel'
  pod 'PubNub'
end

post_install do |installer|
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['LD_NO_PIE'] = 'NO' # https://stackoverflow.com/a/54786324/8248798
            config.build_settings.delete 'IPHONEOS_DEPLOYMENT_TARGET' # https://www.jessesquires.com/blog/2020/07/20/xcode-12-drops-support-for-ios-8-fix-for-cocoapods/
        end
    end
end
