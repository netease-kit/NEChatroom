// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import "NEPersonDataCenterView.h"
#import <Masonry/Masonry.h>
#import "AppKey.h"

@implementation NEPersonDataCenterView

- (instancetype)init {
  self = [super init];
  if (self) {
    [self initUI];
  }
  return self;
}

- (void)initUI {
  self.backgroundColor = [UIColor colorWithRed:26 / 255.0
                                         green:26 / 255.0
                                          blue:36 / 255.0
                                         alpha:1.0];
  UILabel *lineLabel = [[UILabel alloc] init];
  lineLabel.backgroundColor = [UIColor grayColor];
  [self addSubview:lineLabel];
  [lineLabel mas_makeConstraints:^(MASConstraintMaker *make) {
    make.top.width.equalTo(self);
    make.height.equalTo(@0.5);
  }];

  self.dataCenterLabel = [[UILabel alloc] init];
  self.dataCenterLabel.textColor = [UIColor whiteColor];
  self.dataCenterLabel.text = NSLocalizedString(@"数据中心", nil);
  [self addSubview:self.dataCenterLabel];
  [self.dataCenterLabel mas_makeConstraints:^(MASConstraintMaker *make) {
    make.left.equalTo(self).offset(40);
    make.centerY.equalTo(self);
  }];
  self.chinaButton = [[UIButton alloc] init];
  self.chinaButton.backgroundColor =
      [self isOutOdChinaDataCenter] ? [UIColor whiteColor] : [UIColor blueColor];
  self.chinaButton.tag = 0;
  [self.chinaButton addTarget:self
                       action:@selector(clickChangeDataCenter:)
             forControlEvents:UIControlEventTouchUpInside];
  [self.chinaButton.layer masksToBounds];
  self.chinaButton.layer.cornerRadius = 10;
  [self addSubview:self.chinaButton];
  [self.chinaButton mas_makeConstraints:^(MASConstraintMaker *make) {
    make.left.equalTo(self.dataCenterLabel.mas_right).offset(10);
    make.centerY.equalTo(self);
    make.width.height.equalTo(@20);
  }];

  self.chinaLabel = [[UILabel alloc] init];
  self.chinaLabel.textColor = [UIColor whiteColor];
  self.chinaLabel.text = NSLocalizedString(@"中国", nil);
  [self addSubview:self.chinaLabel];
  [self.chinaLabel mas_makeConstraints:^(MASConstraintMaker *make) {
    make.left.equalTo(self.chinaButton.mas_right).offset(10);
    make.centerY.equalTo(self);
  }];

  self.outOfChinaButton = [[UIButton alloc] init];
  self.outOfChinaButton.backgroundColor =
      [self isOutOdChinaDataCenter] ? [UIColor blueColor] : [UIColor whiteColor];
  self.outOfChinaButton.tag = 1;
  [self.outOfChinaButton addTarget:self
                            action:@selector(clickChangeDataCenter:)
                  forControlEvents:UIControlEventTouchUpInside];
  [self.outOfChinaButton.layer masksToBounds];
  self.outOfChinaButton.layer.cornerRadius = 10;
  [self addSubview:self.outOfChinaButton];
  [self.outOfChinaButton mas_makeConstraints:^(MASConstraintMaker *make) {
    make.left.equalTo(self.chinaLabel.mas_right).offset(10);
    make.centerY.equalTo(self);
    make.width.height.equalTo(@20);
  }];

  self.outOfChinaLabel = [[UILabel alloc] init];
  self.outOfChinaLabel.textColor = [UIColor whiteColor];
  self.outOfChinaLabel.text = NSLocalizedString(@"海外地区", nil);
  [self addSubview:self.outOfChinaLabel];
  [self.outOfChinaLabel mas_makeConstraints:^(MASConstraintMaker *make) {
    make.left.equalTo(self.outOfChinaButton.mas_right).offset(10);
    make.centerY.equalTo(self);
  }];
}

- (BOOL)isOutOdChinaDataCenter {
  return [[NSUserDefaults standardUserDefaults] boolForKey:isOutOdChinaDataCenter];
}

- (void)clickChangeDataCenter:(UIButton *)sender {
  if ([self isOutOdChinaDataCenter] == sender.tag) {
    ///本地记录值和选择一致
    return;
  }
  self.selectDataCenter(sender.tag);
}

- (void)updateDataCenter:(long)index {
  [[NSUserDefaults standardUserDefaults] setBool:index == 0 ? NO : YES
                                          forKey:isOutOdChinaDataCenter];
  self.chinaButton.backgroundColor = index == 0 ? [UIColor blueColor] : [UIColor whiteColor];
  self.outOfChinaButton.backgroundColor = index == 0 ? [UIColor whiteColor] : [UIColor blueColor];
  abort();
}
@end
