// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import "NEListenTogetherAuthorityHelper.h"
#import <AVFoundation/AVFoundation.h>
#import "NEListenTogetherLocalized.h"
#import "NEListenTogetherToast.h"
@implementation NEListenTogetherAuthorityHelper
+ (BOOL)checkMicAuthority {
  BOOL isAvalible = NO;
  NSString *mediaType = AVMediaTypeAudio;
  AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:mediaType];
  // 用户尚未授权->申请权限
  if (authStatus == AVAuthorizationStatusNotDetermined) {
    [AVCaptureDevice
        requestAccessForMediaType:mediaType
                completionHandler:^(BOOL granted) {
                  if (!granted) {  // 没有授权 提示用户开启麦克风权限
                    [NEListenTogetherToast
                        showToast:NELocalizedString(@"麦克风权限未打开，请前往系统设置进行修改")];
                  }
                }];
  } else if (authStatus == AVAuthorizationStatusAuthorized) {  // 用户已经授权
    isAvalible = YES;
  } else {  // 用户拒绝授权, 提示用户开启麦克风权限
    isAvalible = NO;
    //        [NEListenTogetherToast
    //        showToast:@"麦克风权限未打开，请前往系统设置进行修改"];
  }
  return isAvalible;
}
@end
