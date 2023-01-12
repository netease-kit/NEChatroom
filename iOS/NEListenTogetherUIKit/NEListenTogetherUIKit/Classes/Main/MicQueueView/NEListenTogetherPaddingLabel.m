// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import "NEListenTogetherPaddingLabel.h"

@implementation NEListenTogetherPaddingLabel

- (id)initWithFrame:(CGRect)frame {
  self = [super initWithFrame:frame];

  if (self) {
    self.edgeInsets = UIEdgeInsetsMake(0, 3, 0, 3);
  }

  return self;
}

- (void)drawRect:(CGRect)rect {
  [super drawTextInRect:UIEdgeInsetsInsetRect(rect, self.edgeInsets)];
}

- (CGSize)intrinsicContentSize {
  CGSize size = [super intrinsicContentSize];

  size.width += self.edgeInsets.left + self.edgeInsets.right;

  size.height += self.edgeInsets.top + self.edgeInsets.bottom;

  return size;
}

@end
