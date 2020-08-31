//
//  NTESChatroomStateView.h
//  NERtcAudioChatroom
//
//  Created by Netease on 2019/3/6.
//  Copyright © 2019年 netease. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface NTESChatroomStateView : UIView

@property (nonatomic, copy) NSString *info;

- (instancetype)initWithInfo:(NSString *)info;

@end

NS_ASSUME_NONNULL_END
