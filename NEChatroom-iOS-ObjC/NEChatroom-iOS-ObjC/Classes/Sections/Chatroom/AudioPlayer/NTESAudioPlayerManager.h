//
//  NTESAudioPlayerManager.h
//  NERtcAudioChatroom
//
//  Created by Netease on 2019/3/11.
//  Copyright © 2019年 netease. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NTESAudioPlayerView.h"
#import "NTESAudioPanelView.h"
#import <NERtcSDK/NERtcSDK.h>
NS_ASSUME_NONNULL_BEGIN

@interface NTESAudioPlayerManager : NSObject

@property (nonatomic, readonly) NTESAudioPlayerView *view;
@property (nonatomic, readonly) NTESAudioPanelView  *audioPanelView;
@property (nonatomic, strong)   UIView  *maskView;

- (void)stop;

- (void)onAudioMixingStateChanged:(NERtcAudioMixingState)state;

@end

NS_ASSUME_NONNULL_END
