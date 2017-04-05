//
//  UIDevice+Extra.m
//  PianoTrainer
//
//  Created by xyz on 2017/4/5.
//  Copyright © 2017年 kuaileshenzhou.com. All rights reserved.
//

#import "UIDevice+Extra.h"
#import "SAMKeychain.h"

@implementation UIDevice (Extra)

- (NSString *)uniqueDeviceIdentifier {
    NSString *service = [NSBundle mainBundle].infoDictionary[@"CFBundleIdentifier"];
    NSString *account = NSStringFromSelector(_cmd);
    NSString *password = [SAMKeychain passwordForService:service account:account];
    if (password == nil) {
        password = [NSUUID UUID].UUIDString;
        [SAMKeychain setPassword:password forService:service account:account];
    }
    return password;
}

@end
