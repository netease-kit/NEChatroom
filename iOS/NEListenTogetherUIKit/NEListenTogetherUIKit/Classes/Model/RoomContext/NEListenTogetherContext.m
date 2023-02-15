// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import "NEListenTogetherContext.h"

static uint32_t kEarbackVolume = 80;
@implementation NEListenTogetherRtcConfig
- (instancetype)init {
  self = [super init];
  if (self) {
    _earbackOn = NO;
    _micOn = YES;
    _speakerOn = YES;
    _effectVolume = 100;
    _audioMixingVolume = 100;
    _audioRecordVolume = 100;
  }
  return self;
}
- (void)setEarbackOn:(BOOL)earbackOn {
  NSInteger code = 0;
  if (earbackOn) {
    code = [NEListenTogetherKit.getInstance enableEarBack:kEarbackVolume];
  } else {
    code = [NEListenTogetherKit.getInstance disableEarBack];
  }
  if (code != 0) return;
  _earbackOn = earbackOn;
}
- (void)setAudioRecordVolume:(uint32_t)audioRecordVolume {
  NSInteger code = [NEListenTogetherKit.getInstance adjustRecordingSignalVolume:audioRecordVolume];
  if (code != 0) return;
  _audioRecordVolume = audioRecordVolume;
}
@end

@interface NEListenTogetherContext () <NEListenTogetherListener>

@end

@implementation NEListenTogetherContext
- (void)dealloc {
  [NEListenTogetherKit.getInstance removeVoiceRoomListener:self];
}
- (instancetype)init {
  self = [super init];
  if (self) {
    self.rtcConfig = [NEListenTogetherRtcConfig new];
    [NEListenTogetherKit.getInstance addVoiceRoomListener:self];
  }
  return self;
}
#pragma mark------------------------ NEListenTogetherListener ------------------------
- (void)onMemberAudioMuteChanged:(NEListenTogetherMember *)member
                            mute:(BOOL)mute
                       operateBy:(NEListenTogetherMember *)operateBy {
  if ([member.account
          isEqualToString:NEListenTogetherKit.getInstance.localMember.account]) {  // 自己
    self.rtcConfig.micOn = !mute;
  }
}
@end
