//
//  NTESNavBar.h
//  NERtcAudioChatroom
//
//  Created by Netease on 2019/3/6.
//  Copyright © 2019年 netease. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, NTESBanSpeakNavType) {
    NTESBanSpeakNavTypeCancel = 0,
    NTESBanSpeakNavTypeArrow,
};

@interface NTESNavBar : UIView

@property (nonatomic, strong) dispatch_block_t backBlock;

@property (nonatomic, strong) dispatch_block_t arrowBackBlock;

@property (nonatomic, copy) NSString *title;
//nav样式 “取消” "<"
@property(nonatomic, assign) NTESBanSpeakNavType navType;

@end

NS_ASSUME_NONNULL_END
