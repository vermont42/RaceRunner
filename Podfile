source 'https://github.com/CocoaPods/Specs.git'

platform :ios, '16.0'
use_frameworks!

target "RaceRunner" do
  pod 'AWSPinpoint'
  pod 'COBezierTableView'
  pod 'GoogleMaps' # fix build warning with https://stackoverflow.com/a/49570905/8248798
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
