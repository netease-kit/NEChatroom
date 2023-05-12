// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import "NEUIConnectAlertView.h"
#import <NEUIKit/UIColor+NEUIExtension.h>
#import "NEUIViewFactory.h"
#import "NEVoiceRoomLocalized.h"
#import "UIView+Gradient.h"

@interface NEUIConnectAlertView ()
@property(nonatomic, assign) NSUInteger connectCount;
@end

@implementation NEUIConnectAlertView
- (void)layoutSubviews {
  self.showConnectListBtn.frame = self.bounds;
}
- (void)onShowConnectListBtnPressed:(UIButton *)btn {
  if (self.actionBlock) {
    self.actionBlock();
  }
  self.showConnectListBtn.hidden = YES;
}
- (void)updateConnectCount:(NSUInteger)connectCount {
  NSString *msg =
      [NSString stringWithFormat:@"%@(%zd)", NELocalizedString(@"申请上麦"), connectCount];
  [self.showConnectListBtn setTitle:msg forState:UIControlStateNormal];
}
- (void)refreshAlertView:(BOOL)listViewPushed {
  self.showConnectListBtn.hidden = listViewPushed;
}
#pragma mark------------------------ Getter ------------------------
- (UIButton *)showConnectListBtn {
  if (!_showConnectListBtn) {
    _showConnectListBtn =
        [NEUIViewFactory createSystemBtnFrame:CGRectZero
                                        title:@""
                                   titleColor:UIColor.whiteColor
                              backgroundColor:nil
                                       target:self
                                       action:@selector(onShowConnectListBtnPressed:)];
    [_showConnectListBtn setGradientBackgroundWithColors:@[
      [UIColor ne_colorWithHex:0x4D88FF], [UIColor ne_colorWithHex:0xD2A6FF]
    ]
                                               locations:nil
                                              startPoint:CGPointMake(0, 0)
                                                endPoint:CGPointMake(0, 1)];
    [_showConnectListBtn
        setTitle:[NSString stringWithFormat:@"%@(1)", NELocalizedString(@"申请上麦")]
        forState:UIControlStateNormal];
    [_showConnectListBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    _showConnectListBtn.layer.cornerRadius = 19.0;
    _showConnectListBtn.layer.masksToBounds = YES;
    [self addSubview:_showConnectListBtn];
  }
  return _showConnectListBtn;
}
@end
