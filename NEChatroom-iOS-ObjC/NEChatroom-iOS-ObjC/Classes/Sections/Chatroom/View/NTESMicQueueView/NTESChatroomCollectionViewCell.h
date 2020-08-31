//
//  NTESChatroomCollectionViewCell.h
//  NERtcAudioChatroom
//
//  Created by Simon Blue on 2019/1/23.
//  Copyright © 2019年 netease. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class NTESMicInfo;

@protocol NTESChatroomCollectionViewCellDelegate <NSObject>

- (void)onConnectBtnPressedWithMicInfo:(NTESMicInfo *)micInfo;

@end


@interface NTESChatroomCollectionViewCell : UICollectionViewCell

@property (nonatomic, weak)id<NTESChatroomCollectionViewCellDelegate> delegate;

- (void)startSoundAnimationWithValue:(NSInteger)value;

- (void)stopSoundAnimation;

- (void)refresh:(NTESMicInfo *)micInfo;

@end

NS_ASSUME_NONNULL_END
