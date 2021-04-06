//
//  NTESChatroomTableViewCell.h
//  NERtcAudioChatroom
//
//  Created by Simon Blue on 2019/1/17.
//  Copyright © 2019年 netease. All rights reserved.
//

#import <UIKit/UIKit.h>

@class NTESChatroomInfo;
NS_ASSUME_NONNULL_BEGIN

@interface NTESChatroomTableViewCell : UITableViewCell

- (void)refresh:(NTESChatroomInfo *)info;

@end

NS_ASSUME_NONNULL_END
