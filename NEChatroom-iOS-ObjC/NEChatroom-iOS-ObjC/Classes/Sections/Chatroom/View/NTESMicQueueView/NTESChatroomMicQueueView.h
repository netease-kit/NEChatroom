//
//  NTESChatroomMicQueueView.h
//  NERtcAudioChatroom
//
//  Created by Netease on 2019/3/5.
//  Copyright © 2019年 netease. All rights reserved.
//

#import <UIKit/UIKit.h>

@class NTESMicInfo;

NS_ASSUME_NONNULL_BEGIN

@protocol NTESChatroomMicQueueViewDelegate <NSObject>

- (void)micQueueConnectBtnPressedWithMicInfo:(NTESMicInfo *)micInfo;

@end

@interface NTESChatroomMicQueueView : UIView

@property (nonatomic, weak) id <NTESChatroomMicQueueViewDelegate>delegate;

@property (nonatomic,strong) NSMutableArray<NTESMicInfo *> *datas;

- (void)updateCellWithMicInfo:(NTESMicInfo *)micInfo;

- (CGFloat)calculateHeightWithWidth:(CGFloat)width;

- (void)startSoundAnimation:(NSInteger)micOrder volume:(NSInteger)volume;

- (void)stopSoundAnimation:(NSInteger)micOrder;

@end

NS_ASSUME_NONNULL_END
