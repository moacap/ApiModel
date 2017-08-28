platform :ios, '10.0'

source 'https://github.com/CocoaPods/Specs.git'

use_frameworks!

def realm_dep
  pod 'RealmSwift'
end

target :ApiModel do
  realm_dep

  pod 'Alamofire', '~> 4.5.0'
  pod 'SwiftyJSON'
end

target :Tests do
  realm_dep

  pod 'Alamofire'
  pod 'SwiftyJSON'
  pod 'OHHTTPStubs/Swift'
end

