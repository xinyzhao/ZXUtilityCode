Pod::Spec.new do |s|

  s.name         = "ZXUtilityCode"
  s.version      = "1.7.5"
  s.summary      = "Utility codes for iOS."
  s.description  = <<-DESC
                   Provides a few utility codes for iOS.
                   DESC
  s.homepage     = "https://github.com/xinyzhao/ZXUtilityCode"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author             = { "xinyzhao" => "xinyzhao@qq.com" }
  s.platform     = :ios, "7.0"
  s.source       = { :git => "https://github.com/xinyzhao/ZXUtilityCode.git", :tag => "#{s.version}" }
  s.requires_arc = true

  s.frameworks = "Foundation", "UIKit"
  # s.library   = "iconv"
  # s.libraries = "iconv", "xml2"

  s.source_files  = "Core/ZXUtilityCode.h"
  s.public_header_files = "Core/ZXUtilityCode.h"
  
  s.subspec "AVAudioProximityDetector" do |ss|
    ss.source_files  = "Core/AVAudioProximityDetector/*.{h,m}"
    ss.public_header_files = "Core/AVAudioProximityDetector/*.h"
    ss.frameworks = "AVFoundation"
  end

  s.subspec "Base64Encoding" do |ss|
    ss.source_files  = "Core/Base64Encoding/*.{h,m}"
    ss.public_header_files = "Core/Base64Encoding/*.h"
  end

  s.subspec "HashValue" do |ss|
    ss.source_files  = "Core/HashValue/*.{h,m}"
    ss.public_header_files = "Core/HashValue/*.h"
  end

  s.subspec "JSONObject" do |ss|
    ss.source_files  = "Core/JSONObject/*.{h,m}"
    ss.public_header_files = "Core/JSONObject/*.h"
  end

  s.subspec "NSArray+Extra" do |ss|
    ss.source_files  = "Core/NSArray+Extra/*.{h,m}"
    ss.public_header_files = "Core/NSArray+Extra/*.h"
  end

  s.subspec "NSDate+Extra" do |ss|
    ss.source_files  = "Core/NSDate+Extra/*.{h,m}"
    ss.public_header_files = "Core/NSDate+Extra/*.h"
  end

  s.subspec "NSFileManager+Extra" do |ss|
    ss.source_files  = "Core/NSFileManager+Extra/*.{h,m}"
    ss.public_header_files = "Core/NSFileManager+Extra/*.h"
  end

  s.subspec "NSLog+Extra" do |ss|
    ss.source_files  = "Core/NSLog+Extra/*.{h,m}"
    ss.public_header_files = "Core/NSLog+Extra/*.h"
  end

  s.subspec "NSObject+Extra" do |ss|
    ss.source_files  = "Core/NSObject+Extra/*.{h,m}"
    ss.public_header_files = "Core/NSObject+Extra/*.h"
  end

  s.subspec "NSString+NumberValue" do |ss|
    ss.source_files  = "Core/NSString+NumberValue/*.{h,m}"
    ss.public_header_files = "Core/NSString+NumberValue/*.h"
  end

  s.subspec "NSString+Pinyin" do |ss|
    ss.source_files  = "Core/NSString+Pinyin/*.{h,m}"
    ss.public_header_files = "Core/NSString+Pinyin/*.h"
  end

  s.subspec "NSString+Unicode" do |ss|
    ss.dependency 'ZXUtilityCode/NSObject+Extra'
    ss.source_files  = "Core/NSString+Unicode/*.{h,m}"
    ss.public_header_files = "Core/NSString+Unicode/*.h"
  end

  s.subspec "NSString+URLEncoding" do |ss|
    ss.source_files  = "Core/NSString+URLEncoding/*.{h,m}"
    ss.public_header_files = "Core/NSString+URLEncoding/*.h"
  end

  s.subspec "QRCodeGenerator" do |ss|
    ss.source_files  = "Core/QRCodeGenerator/*.{h,m}"
    ss.public_header_files = "Core/QRCodeGenerator/*.h"
  end

  s.subspec "QRCodeReader" do |ss|
    ss.source_files  = "Core/QRCodeReader/*.{h,m}"
    ss.public_header_files = "Core/QRCodeReader/*.h"
  end

  s.subspec "QRCodeScanner" do |ss|
    ss.source_files  = "Core/QRCodeScanner/*.{h,m}"
    ss.public_header_files = "Core/QRCodeScanner/*.h"
    ss.frameworks = "AVFoundation"
  end

  s.subspec "UIApplicationIdleTimer" do |ss|
    ss.source_files  = "Core/UIApplicationIdleTimer/*.{h,m}"
    ss.public_header_files = "Core/UIApplicationIdleTimer/*.h"
  end

  s.subspec "UIColor+Extra" do |ss|
    ss.source_files  = "Core/UIColor+Extra/*.{h,m}"
    ss.public_header_files = "Core/UIColor+Extra/*.h"
  end

  s.subspec "UIImage+Extra" do |ss|
    ss.source_files  = "Core/UIImage+Extra/*.{h,m}"
    ss.public_header_files = "Core/UIImage+Extra/*.h"
    ss.frameworks = "CoreGraphics", "ImageIO"
  end

  s.subspec "UINetworkActivityIndicator" do |ss|
    ss.source_files  = "Core/UINetworkActivityIndicator/*.{h,m}"
    ss.public_header_files = "Core/UINetworkActivityIndicator/*.h"
  end

  s.subspec "UITableViewCell+Separator" do |ss|
    ss.source_files  = "Core/UITableViewCell+Separator/*.{h,m}"
    ss.public_header_files = "Core/UITableViewCell+Separator/*.h"
  end

  s.subspec "UIView+Snapshot" do |ss|
    ss.source_files  = "Core/UIView+Snapshot/*.{h,m}"
    ss.public_header_files = "Core/UIView+Snapshot/*.h"
  end
  
  s.subspec "UIViewController+Extra" do |ss|
    ss.source_files  = "Core/UIViewController+Extra/*.{h,m}"
    ss.public_header_files = "Core/UIViewController+Extra/*.h"
  end

  s.subspec "ZXAlertView" do |ss|
    ss.source_files  = "Core/ZXAlertView/*.{h,m}"
    ss.public_header_files = "Core/ZXAlertView/*.h"
  end

  s.subspec "ZXAuthorizationHelper" do |ss|
    ss.source_files  = "Core/ZXAuthorizationHelper/*.{h,m}"
    ss.public_header_files = "Core/ZXAuthorizationHelper/*.h"
    ss.frameworks = "AddressBook", "AssetsLibrary", "AVFoundation", "CoreLocation"
    ss.weak_framework = "Contacts", "CoreTelephony", "Photos"
  end

  s.subspec "ZXBadgeLabel" do |ss|
    ss.source_files  = "Core/ZXBadgeLabel/*.{h,m}"
    ss.public_header_files = "Core/ZXBadgeLabel/*.h"
  end

  s.subspec "ZXCircularProgressView" do |ss|
    ss.source_files  = "Core/ZXCircularProgressView/*.{h,m}"
    ss.public_header_files = "Core/ZXCircularProgressView/*.h"
  end

  s.subspec "ZXDownloadManager" do |ss|
  	ss.dependency 'ZXUtilityCode/HashValue'
    ss.source_files  = "Core/ZXDownloadManager/*.{h,m}"
    ss.public_header_files = "Core/ZXDownloadManager/*.h"
  end

  s.subspec "ZXDrawingView" do |ss|
    ss.source_files  = "Core/ZXDrawingView/*.{h,m}"
    ss.public_header_files = "Core/ZXDrawingView/*.h"
  end

  s.subspec "ZXHTTPClient" do |ss|
    ss.source_files  = "Core/ZXHTTPClient/*.{h,m}"
    ss.public_header_files = "Core/ZXHTTPClient/*.h"
    ss.frameworks = "Security"
  end

  s.subspec "ZXImageView" do |ss|
    ss.source_files  = "Core/ZXImageView/*.{h,m}"
    ss.public_header_files = "Core/ZXImageView/*.h"
  end

  s.subspec "ZXNetworkTrafficMonitor" do |ss|
    ss.source_files  = "Core/ZXNetworkTrafficMonitor/*.{h,m}"
    ss.public_header_files = "Core/ZXNetworkTrafficMonitor/*.h"
  end

  s.subspec "ZXPageIndicatorView" do |ss|
    ss.source_files  = "Core/ZXPageIndicatorView/*.{h,m}"
    ss.public_header_files = "Core/ZXPageIndicatorView/*.h"
  end

  s.subspec "ZXPageView" do |ss|
    ss.source_files  = "Core/ZXPageView/*.{h,m}"
    ss.public_header_files = "Core/ZXPageView/*.h"
  end

  s.subspec "ZXPhotoLibrary" do |ss|
    ss.source_files  = "Core/ZXPhotoLibrary/*.{h,m}"
    ss.public_header_files = "Core/ZXPhotoLibrary/*.h"
    ss.frameworks = "AssetsLibrary", "CoreGraphics", "ImageIO"
    ss.weak_framework = "Photos"
  end

  s.subspec "ZXPlayerViewController" do |ss|
    ss.dependency 'ZXUtilityCode/NSObject+Extra'
    ss.dependency 'ZXUtilityCode/UIViewController+Extra'
    ss.source_files  = "Core/ZXPlayerViewController/*.{h,m}"
    ss.public_header_files = "Core/ZXPlayerViewController/*.h"
    ss.frameworks = "AVFoundation", "MediaPlayer"
  end

  s.subspec "ZXPopoverWindow" do |ss|
    ss.source_files  = "Core/ZXPopoverWindow/*.{h,m}"
    ss.public_header_files = "Core/ZXPopoverWindow/*.h"
  end

  s.subspec "ZXRefreshView" do |ss|
  	ss.dependency 'ZXUtilityCode/ZXCircularProgressView'
    ss.source_files  = "Core/ZXRefreshView/*.{h,m}"
    ss.public_header_files = "Core/ZXRefreshView/*.h"
  end

  s.subspec "ZXTabBarController" do |ss|
    ss.source_files  = "Core/ZXTabBarController/*.{h,m}"
    ss.public_header_files = "Core/ZXTabBarController/*.h"
  end

  s.subspec "ZXTagView" do |ss|
    ss.source_files  = "Core/ZXTagView/*.{h,m}"
    ss.public_header_files = "Core/ZXTagView/*.h"
  end

  s.subspec "ZXToastView" do |ss|
    ss.source_files  = "Core/ZXToastView/*.{h,m}"
    ss.public_header_files = "Core/ZXToastView/*.h"
  end

end
