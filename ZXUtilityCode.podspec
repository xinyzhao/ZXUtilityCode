Pod::Spec.new do |s|

  s.name         = "ZXUtilityCode"
  s.version      = "1.0.7"
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

  s.subspec "DispatchQueue" do |ss|
    ss.source_files  = "Core/DispatchQueue/*.{h,m}"
    ss.public_header_files = "Core/DispatchQueue/*.h"
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

  s.subspec "NSObject+PerformAction" do |ss|
    ss.source_files  = "Core/NSObject+PerformAction/*.{h,m}"
    ss.public_header_files = "Core/NSObject+PerformAction/*.h"
  end

  s.subspec "NSString+Pinyin" do |ss|
    ss.source_files  = "Core/NSString+Pinyin/*.{h,m}"
    ss.public_header_files = "Core/NSString+Pinyin/*.h"
  end

  s.subspec "NSString+Unicode" do |ss|
    ss.source_files  = "Core/NSString+Unicode/*.{h,m}"
    ss.public_header_files = "Core/NSString+Unicode/*.h"
  end

  s.subspec "NSString+URLEncoding" do |ss|
    ss.source_files  = "Core/NSString+URLEncoding/*.{h,m}"
    ss.public_header_files = "Core/NSString+URLEncoding/*.h"
  end

  s.subspec "NSURLSessionManager" do |ss|
    ss.source_files  = "Core/NSURLSessionManager/*.{h,m}"
    ss.public_header_files = "Core/NSURLSessionManager/*.h"
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

  s.subspec "UIButton+Extra" do |ss|
    ss.source_files  = "Core/UIButton+Extra/*.{h,m}"
    ss.public_header_files = "Core/UIButton+Extra/*.h"
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

  s.subspec "UIPopoverWindow" do |ss|
    ss.source_files  = "Core/UIPopoverWindow/*.{h,m}"
    ss.public_header_files = "Core/UIPopoverWindow/*.h"
  end

  s.subspec "UITableViewCell+Separator" do |ss|
    ss.source_files  = "Core/UITableViewCell+Separator/*.{h,m}"
    ss.public_header_files = "Core/UITableViewCell+Separator/*.h"
  end

  s.subspec "UIViewController+Extra" do |ss|
    ss.source_files  = "Core/UIViewController+Extra/*.{h,m}"
    ss.public_header_files = "Core/UIViewController+Extra/*.h"
  end

  s.subspec "ZXAlertView" do |ss|
    ss.source_files  = "Core/ZXAlertView/*.{h,m}"
    ss.public_header_files = "Core/ZXAlertView/*.h"
  end

  s.subspec "ZXBadgeLabel" do |ss|
    ss.source_files  = "Core/ZXBadgeLabel/*.{h,m}"
    ss.public_header_files = "Core/ZXBadgeLabel/*.h"
  end

  s.subspec "ZXImageView" do |ss|
    ss.source_files  = "Core/ZXImageView/*.{h,m}"
    ss.public_header_files = "Core/ZXImageView/*.h"
  end

  s.subspec "ZXPageView" do |ss|
    ss.source_files  = "Core/ZXPageView/*.{h,m}"
    ss.public_header_files = "Core/ZXPageView/*.h"
  end

  s.subspec "ZXPhotoLibrary" do |ss|
    ss.source_files  = "Core/ZXPhotoLibrary/*.{h,m}"
    ss.public_header_files = "Core/ZXPhotoLibrary/*.h"
    ss.frameworks = "AssetsLibrary", "CoreGraphics", "ImageIO", "Photos"
  end

  s.subspec "ZXRefreshView" do |ss|
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

end
