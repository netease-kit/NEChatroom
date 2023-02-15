// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import "NEMenuHeader.h"
#import <NEUIKit/UIView+NEUIExtension.h>

@interface NEMenuHeader ()

@property(nonatomic, strong) UIImageView *icon;

@end

@implementation NEMenuHeader

- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier {
  self = [super initWithReuseIdentifier:reuseIdentifier];
  if (self) {
    [self addSubview:self.icon];
  }
  return self;
}

- (void)layoutSubviews {
  self.icon.frame = CGRectMake((self.width - 144) / 2.0, 10, 144, 20);
}

- (void)setSection:(NSInteger)section {
  NSString *name = @"base_header_ico";
  switch (section) {
    case 1:
      name = @"live_header_ico";
      break;

    default:
      break;
  }
  self.icon.image = [UIImage imageNamed:name];
}

+ (CGFloat)height {
  return 40;
}

#pragma mark - lazy load

- (UIImageView *)icon {
  if (!_icon) {
    _icon = [[UIImageView alloc] init];
  }
  return _icon;
}

@end
