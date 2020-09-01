//
//  NTESAnimationButton.h
//  NERtcAudioChatroom
//
//  Created by Netease on 2019/3/13.
//  Copyright © 2019年 netease. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface NTESAnimationButton : UIButton

@property (nullable, nonatomic, copy) NSString *info;

- (void)startCustomAnimation;

- (void)stopCustomAnimation;

@end

NS_ASSUME_NONNULL_END
