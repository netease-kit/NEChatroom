//
//  NTESAudioQualityView.h
//  NERtcAudioChatroom
//
//  Created by Netease on 2019/5/14.
//  Copyright © 2019 netease. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol NTESAudioQualityViewDelegate <NSObject>

- (void)didSureCreateRoomWithAudioQuality:(NSInteger)audioQuality;

@end

@interface NTESAudioQualityView : UIControl

@property (nonatomic, weak) id<NTESAudioQualityViewDelegate> delegate;

- (void)showOnView:(UIView *)view;

- (void)dismiss;

@end



NS_ASSUME_NONNULL_END
