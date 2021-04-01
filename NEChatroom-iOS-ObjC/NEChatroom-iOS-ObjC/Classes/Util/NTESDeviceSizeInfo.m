//
//  NETSDeviceSIzeInfo.m
//  NLiteAVDemo
//
//  Created by 徐善栋 on 2020/12/31.
//  Copyright © 2020 Netease. All rights reserved.
//

#import "NTESDeviceSizeInfo.h"

@implementation NTESDeviceSizeInfo

+ (BOOL)isIPhoneXSeries {
    BOOL iPhoneXSeries = NO;
    if (UIDevice.currentDevice.userInterfaceIdiom != UIUserInterfaceIdiomPhone) {
        return iPhoneXSeries;
    }
    if (@available(iOS 11.0, *)) {
        UIWindow *mainWindow = [[[UIApplication sharedApplication] delegate] window];
        if (mainWindow.safeAreaInsets.bottom > 0.0) {
            iPhoneXSeries = YES;
        }
    }
    return iPhoneXSeries;
}

+ (CGFloat)get_iPhoneTabBarHeight {
    if ([self isIPhoneXSeries]) {
        return 83;
    }
    return 49;
}

+ (CGFloat)get_iPhoneNavBarHeight {
    return [UIApplication sharedApplication].statusBarFrame.size.height + 44;
}

+ (CGFloat)get_iPhoneBottomSafeDistance {
    if ([self isIPhoneXSeries]) {
        return 34;
    }
    return 0;
}
@end
