//
//  NTESNavBar.h
//  NERtcAudioChatroom
//
//  Created by Netease on 2019/3/6.
//  Copyright © 2019年 netease. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface NTESNavBar : UIView

@property (nonatomic, strong) dispatch_block_t backBlock;

@property (nonatomic, copy) NSString *title;

@end

NS_ASSUME_NONNULL_END
