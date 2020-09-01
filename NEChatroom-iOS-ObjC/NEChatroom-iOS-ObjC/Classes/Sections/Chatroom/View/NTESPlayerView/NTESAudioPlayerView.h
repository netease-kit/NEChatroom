//
//  NTESAudioPlayerView.h
//  NERtcAudioChatroom
//
//  Created by Netease on 2019/3/7.
//  Copyright © 2019年 netease. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol NTESAudioPlayerDelegate <NSObject>

- (void)didStartPlayAction:(BOOL)isPause;

- (void)didNextAction;

- (void)didMoreAction;

@end

@interface NTESAudioPlayerView : UIView

@property (nonatomic, weak) id<NTESAudioPlayerDelegate> delegate;

@property (nonatomic, assign) BOOL playState;

@property (nonatomic, copy) NSString *musicName;

@end

NS_ASSUME_NONNULL_END
