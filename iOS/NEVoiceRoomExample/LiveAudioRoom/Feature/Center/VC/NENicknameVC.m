// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import "NENicknameVC.h"
#import <Masonry/Masonry.h>
#import <NEUIKit/NEUICommon.h>
#import <NEUIKit/UIColor+NEUIExtension.h>
#import "UIView+Toast.h"

@interface NENicknameVC () <UITextFieldDelegate>

@end

@implementation NENicknameVC

- (void)viewDidLoad {
  [super viewDidLoad];
  [self initializeConfig];
  [self setupSubviews];
}

- (void)initializeConfig {
  self.title = NSLocalizedString(@"修改昵称", nil);
  self.view.backgroundColor = [UIColor ne_colorWithHex:0x1A1A24];
}

- (void)setupSubviews {
  UIBarButtonItem *rightBar = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"完成", nil)
                                                               style:UIBarButtonItemStylePlain
                                                              target:self
                                                              action:@selector(doneEvent)];
  self.navigationItem.rightBarButtonItem = rightBar;
  [self.view addSubview:self.nickTextField];
  [self.nickTextField mas_makeConstraints:^(MASConstraintMaker *make) {
    make.top.mas_equalTo([NEUICommon ne_topBarHeight] + 20);
    make.left.mas_equalTo(10);
    make.right.mas_equalTo(-10);
    make.height.mas_equalTo(56);
  }];
}

- (void)doneEvent {
  [self.view endEditing:YES];
  [self modifyNickname:self.nickTextField.text];
}
- (void)modifyNickname:(NSString *)nickName {
  if (nickName.length <= 0) {
    [self.view makeToast:@"昵称不可以为空哦" duration:2 position:CSToastPositionCenter];

    return;
  } else if (nickName.length > 12) {
    [self.view makeToast:@"仅支持12位及以下文本、字母及数字组合"
                duration:2
                position:CSToastPositionCenter];
    return;
  }
  //    NEModifyNicknameTask *task = [NEModifyNicknameTask task];
  //    task.req_nickname = nickName;
  //    [task postWithCompletion:^(NSDictionary * _Nullable data, id  _Nullable task, NSError *
  //    _Nullable error) {
  //        NSLog(@"error:%@ data:%@",error,data);
  //        if (error) {
  //            [self.view makeToast:error.localizedDescription duration:2
  //            position:CSToastPositionCenter];
  //
  //        }else {
  //            NSDictionary *userDic = [data objectForKey:@"data"];
  //            NEUser *user = [[NEUser alloc] initWithDictionary:userDic];
  //            [NEAccount updateUserInfo:user];
  //            [self.view makeToast:@"修改成功" duration:2 position:CSToastPositionCenter];
  //
  //            if (self.didModifyNickname) {
  //                self.didModifyNickname(user.nickname);
  //            }
  //        }
  //    }];
}

- (UITextField *)nickTextField {
  if (!_nickTextField) {
    _nickTextField = [[UITextField alloc] init];
    _nickTextField.backgroundColor = [UIColor colorWithRed:41 / 255.0
                                                     green:41 / 255.0
                                                      blue:54 / 255.0
                                                     alpha:1 / 1.0];
    _nickTextField.delegate = self;
    _nickTextField.textColor = [UIColor whiteColor];
    NSMutableAttributedString *string = [[NSMutableAttributedString alloc]
        initWithString:NSLocalizedString(@"输入昵称", nil)
            attributes:@{
              NSForegroundColorAttributeName : [UIColor grayColor],
              NSFontAttributeName : _nickTextField.font
            }];
    _nickTextField.attributedPlaceholder = string;
    _nickTextField.layer.cornerRadius = 8;

    _nickTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    if ([_nickTextField respondsToSelector:@selector(setReturnKeyType:)]) {
      _nickTextField.returnKeyType = UIReturnKeyDone;
    }

    UIView *leftview = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 20, 40)];
    _nickTextField.leftViewMode = UITextFieldViewModeAlways;
    _nickTextField.leftView = leftview;
  }
  return _nickTextField;
}
#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
  [textField resignFirstResponder];
  return YES;
}
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
  [self.view endEditing:YES];
}

@end
