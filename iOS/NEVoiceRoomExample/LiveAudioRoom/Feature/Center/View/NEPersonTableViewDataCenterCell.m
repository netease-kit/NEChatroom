// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import "NEPersonTableViewDataCenterCell.h"
#import <Masonry/Masonry.h>

@implementation NEPersonTableViewDataCenterCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style
              reuseIdentifier:(NSString *)reuseIdentifier {
  self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
  if (self) {
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    NEPersonDataCenterView *view = [[NEPersonDataCenterView alloc] init];
    [self.contentView addSubview:view];
    [view mas_makeConstraints:^(MASConstraintMaker *make) {
      make.edges.mas_equalTo(0);
    }];
    self.personDataCenterView = view;
  }
  return self;
}

@end
