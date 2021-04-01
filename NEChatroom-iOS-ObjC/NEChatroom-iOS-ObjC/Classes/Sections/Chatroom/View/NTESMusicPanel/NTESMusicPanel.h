//
//  NTESMusicPanelViewController.h
//  NEChatroom-iOS-ObjC
//
//  Created by Wenchao Ding on 2021/1/26.
//  Copyright © 2021 netease. All rights reserved.
//

#import <UIKit/UIKit.h>

@class NTESMusicPanelViewController;

NS_ASSUME_NONNULL_BEGIN

@protocol NTESMusicPanelDelegate <NSObject>

/**
 暂停
 */
- (void)musicPanelDidPause:(NTESMusicPanelViewController *)panel;

/**
 恢复
 */
- (void)musicPanelDidResume:(NTESMusicPanelViewController *)panel;

/**
 切歌
 */
- (void)musicPanelDidSwitchNext:(NTESMusicPanelViewController *)panel;

@end

@interface NTESMusicPanelViewController : UIViewController

/**
 代理对象
 */
@property (nonatomic, weak) id<NTESMusicPanelDelegate> delegate;

/**
 是否显示点歌、切歌等控制空间
 */
@property (nonatomic, assign) BOOL showsMusicControls;

/**
 是否显示暂停区域
 */
@property (nonatomic, assign) BOOL showsPauseMask;

/**
 歌词文件地址
 */
@property (nonatomic, copy) NSString *lyricFilePath;

/**
 歌词位置
 */
@property (nonatomic, assign) uint64_t lyricPosition;

/**
 建议高度
 */
+ (CGFloat)suggestedHeight;

@end

NS_ASSUME_NONNULL_END
