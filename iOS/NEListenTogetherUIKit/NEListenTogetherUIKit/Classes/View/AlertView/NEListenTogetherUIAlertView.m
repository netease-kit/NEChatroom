// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import "NEListenTogetherUIAlertView.h"
#import "NEListenTogetherLocalized.h"
#import "NEListenTogetherUIActionSheet.h"

@interface NEListenTogetherUIAlertView ()

@property(nonatomic, strong) NSMutableArray<NEListenTogetherUIAlertAction *> *actions;

@end

@implementation NEListenTogetherUIAlertView

- (instancetype)initWithActions:(NSMutableArray<NEListenTogetherUIAlertAction *> *)actions {
  if (self = [super init]) {
    _actions = actions;
  }
  return self;
}

- (void)showWithTypes:(NSArray<NSNumber *> *)types info:(id)info {
  if (types.count == 0) {
    return;
  }
  NSMutableArray *alertActionModels = [NSMutableArray array];
  for (NSNumber *typeNum in types) {
    NEUIAlertActionType type = (NEUIAlertActionType)[typeNum integerValue];
    for (NEListenTogetherUIAlertAction *model in _actions) {
      if (model.type == type) {
        NEUIActionSheetModel *item = [[NEUIActionSheetModel alloc] init];
        item.title = model.title;
        if (model.type == NEUIAlertActionTypeCancelOnMicRequest ||
            model.type == NEUIAlertActionTypeDropMic ||
            model.type == NEUIAlertActionTypeExistRoom) {
          item.itemType = NEUIActionSheetItemDelete;
        } else {
          item.itemType = NEUIActionSheetItemNoraml;
        }
        item.sheetId = (int)[_actions indexOfObject:model];
        [alertActionModels addObject:item];
      }
    }
  }

  if (alertActionModels.count != 0) {
    __weak typeof(self) weakSelf = self;
    [NEListenTogetherUIActionSheet showWithDesc:nil
                                   actionModels:alertActionModels
                                         action:^(NEUIActionSheetModel *model) {
                                           int index = model.sheetId;
                                           NEListenTogetherUIAlertAction *action =
                                               weakSelf.actions[index];
                                           if (action.handle) {
                                             action.handle(info);
                                           }
                                         }
                                         cancel:_cancel];
  }
}

- (UIAlertAction *)alertActionWithModel:(NEListenTogetherUIAlertAction *)model info:(id)info {
  UIAlertAction *ret = [UIAlertAction actionWithTitle:model.title
                                                style:UIAlertActionStyleDefault
                                              handler:^(UIAlertAction *_Nonnull action) {
                                                if (model.handle) {
                                                  model.handle(info);
                                                }
                                              }];
  if (model.type == NEUIAlertActionTypeCancelOnMicRequest ||
      model.type == NEUIAlertActionTypeDropMic || model.type == NEUIAlertActionTypeExistRoom) {
    [ret setValue:[UIColor redColor] forKey:@"titleTextColor"];
  }
  return ret;
}

- (void)dismiss {
  [NEListenTogetherUIActionSheet hide];
}

+ (void)showAlertWithMessage:(NSString *)message {
  [self showAlertWithMessage:message completion:nil];
}

+ (void)showAlertWithMessage:(NSString *)message completion:(nullable dispatch_block_t)completion {
  UIAlertAction *ret = [UIAlertAction actionWithTitle:NELocalizedString(@"知道了")
                                                style:UIAlertActionStyleCancel
                                              handler:^(UIAlertAction *_Nonnull action) {
                                                if (completion) {
                                                  completion();
                                                }
                                              }];
  UIAlertController *alertVC =
      [UIAlertController alertControllerWithTitle:nil
                                          message:message
                                   preferredStyle:UIAlertControllerStyleAlert];
  [alertVC addAction:ret];

  if ([[UIApplication sharedApplication].delegate respondsToSelector:@selector(window)]) {
    UIViewController *topVC =
        [self currentViewControllerFrom:[UIApplication sharedApplication]
                                            .delegate.window.rootViewController];
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
      UIPopoverPresentationController *popPresenter = [alertVC popoverPresentationController];
      popPresenter.sourceView = topVC.view;
      popPresenter.sourceRect = topVC.view.bounds;
    }
    [topVC presentViewController:alertVC animated:YES completion:nil];
  }
}

+ (UIViewController *)currentViewControllerFrom:(UIViewController *)viewController {
  if ([viewController isKindOfClass:[UINavigationController class]]) {
    UINavigationController *navigationController = (UINavigationController *)viewController;
    return [self currentViewControllerFrom:navigationController.viewControllers.lastObject];
  }  // 如果传入的控制器是导航控制器,则返回最后一个
  else if ([viewController isKindOfClass:[UITabBarController class]]) {
    UITabBarController *tabBarController = (UITabBarController *)viewController;
    return [self currentViewControllerFrom:tabBarController.selectedViewController];
  }  // 如果传入的控制器是tabBar控制器,则返回选中的那个
  else if (viewController.presentedViewController != nil) {
    return [self currentViewControllerFrom:viewController.presentedViewController];
  }  // 如果传入的控制器发生了modal,则就可以拿到modal的那个控制器
  else {
    return viewController;
  }
}

@end

@implementation NEListenTogetherUIAlertAction

+ (NEListenTogetherUIAlertAction *)actionWithTitle:(NSString *)title
                                              type:(NEUIAlertActionType)type
                                           handler:(NEUIAlertActionHandle)handle {
  NEListenTogetherUIAlertAction *ret = [[NEListenTogetherUIAlertAction alloc] init];
  ret.title = title;
  ret.type = type;
  ret.handle = handle;
  return ret;
}

- (instancetype)init {
  if (self = [super init]) {
    _title = @"";
  }
  return self;
}

@end
