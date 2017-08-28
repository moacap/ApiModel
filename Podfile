platform :ios, '10.0'

source 'https://github.com/CocoaPods/Specs.git'

use_frameworks!

def realm_dep
  pod 'RealmSwift','~> 2.10.0'
end

target :ApiModel do
  realm_dep

  pod 'Alamofire', '~> 4.5.0'
  pod 'SwiftyJSON'
end

target :Tests do
  realm_dep

  pod 'Alamofire','~> 4.5.0'
  pod 'SwiftyJSON'
  pod 'OHHTTPStubs/Swift'
end

post_install do |installer|
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['SWIFT_VERSION'] = '3.0'
        end
    end
end
