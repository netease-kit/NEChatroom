//
//  UIView+NTESToast.h
//  NERtcAudioChatroom
//
//  Created by Netease on 2019/3/8.
//  Copyright © 2019年 netease. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger,NTESToastState)
{
    NTESToastStateSuccess = 0,
    NTESToastStateFail,
    NTESToastCancel,
};

@interface UIView (NTESToast)

- (void)showToastWithMessage:(NSString *)message
                       state:(NTESToastState)state;

- (void)showToastWithMessage:(NSString *)message
                       state:(NTESToastState)state
                 autoDismiss:(BOOL)autoDismiss;

- (void)showToastWithMessage:(NSString *)message
                       state:(NTESToastState)state
                      cancel:(nullable dispatch_block_t)cancel;

- (void)dismissToast;

@end

NS_ASSUME_NONNULL_END
