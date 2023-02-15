// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import "NEListenTogetherUIBackgroundMusicModel.h"

@implementation NEListenTogetherUIBackgroundMusicModel
- (BOOL)isEqual:(id)object {
  if (![object isKindOfClass:self.class]) {
    return NO;
  }
  NEListenTogetherUIBackgroundMusicModel *other = object;
  if (self.title != other.title && ![self.title isEqual:other.title]) return NO;
  if (self.artist != other.artist && ![self.artist isEqual:other.artist]) return NO;
  if (self.albumName != other.albumName && ![self.albumName isEqual:other.albumName]) return NO;
  if (self.fileName != other.fileName && ![self.fileName isEqual:other.fileName]) return NO;
  return YES;
}
@end
