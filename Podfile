platform :ios, '13.0'
use_frameworks!

target "RaceRunner" do
  pod 'GoogleMaps'
  pod 'PubNub'
  pod 'DLRadioButton'
  pod 'COBezierTableView'
  pod 'MGSwipeTableCell'
  pod 'MarqueeLabel'
  pod 'AWSPinpoint'
end

# https://stackoverflow.com/a/54786324/8248798
post_install do |installer|
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['LD_NO_PIE'] = 'NO'
        end
    end
end
