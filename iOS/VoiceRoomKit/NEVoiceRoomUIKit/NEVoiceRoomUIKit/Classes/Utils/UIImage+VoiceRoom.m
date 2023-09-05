// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import "UIImage+VoiceRoom.h"

#import "NEVoiceRoomUI.h"

@implementation UIImage (VoiceRoom)

+ (UIImage *)nevoiceRoom_imageNamed:(NSString *)name {
  return [NEVoiceRoomUI ne_voice_imageName:name];
}

@end
