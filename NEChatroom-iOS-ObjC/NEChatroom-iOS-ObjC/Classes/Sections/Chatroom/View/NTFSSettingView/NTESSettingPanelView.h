//
//  NTESSettingPanelView.h
//  NERtcAudioChatroom
//
//  Created by Think on 2020/8/19.
//  Copyright © 2020 netease. All rights reserved.
//

/**
 设置面板视图
 */

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol NTESSettingPanelDelegate <NSObject>

- (void)setEarbackEnable:(BOOL)enable;
- (void)setGatherVolume:(CGFloat)volume;

@end

@interface NTESSettingPanelView : UIView

/**
 展示聊天室设置面板
 @param controller      视图控制器
 @param earbackSwitch   是否开启耳返功能
 @param volume          采集音量值
*/
+ (void)showWithController:(UIViewController <NTESSettingPanelDelegate> *)controller
             earbackSwifth:(BOOL)earbackSwitch
                    volume:(CGFloat)volume;

@end

NS_ASSUME_NONNULL_END
