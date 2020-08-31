//
//  NTESConnectAlertView.h
//  NERtcAudioChatroom
//
//  Created by Simon Blue on 2019/1/31.
//  Copyright © 2019年 netease. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol NTESConnectAlertViewDelegate <NSObject>

- (void)onShowConnectListBtnPressed:(UIButton *)button;

@end

@interface NTESConnectAlertView : UIView

@property (nonatomic, weak)id<NTESConnectAlertViewDelegate> delegate;
- (void)updateConnectCount:(NSUInteger)connectCount;
- (void)refreshAlertView:(BOOL)listViewPushed;

@end

NS_ASSUME_NONNULL_END
