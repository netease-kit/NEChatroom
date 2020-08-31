//
//  NTESChatroomAlertView.m
//  NERtcAudioChatroom
//
//  Created by Simon Blue on 2019/1/31.
//  Copyright © 2019年 netease. All rights reserved.
//

#import "NTESChatroomAlertView.h"
#import "NTESActionSheet.h"

@interface NTESChatroomAlertView ()

@property (nonatomic, strong) NSMutableArray <NTESChatroomAlertAction *> *actions;

@end

@implementation NTESChatroomAlertView

- (instancetype)initWithActions:(NSMutableArray <NTESChatroomAlertAction *> *)actions {
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
        NTESAlertActionType type = (NTESAlertActionType)[typeNum integerValue];
        for (NTESChatroomAlertAction *model in _actions) {
            if (model.type == type) {
                NTESActionSheetModel *item = [[NTESActionSheetModel alloc] init];
                item.title = model.title;
                if (model.type == NTESAlertActionTypeCancelOnMicRequest
                    || model.type == NTESAlertActionTypeDropMic
                    || model.type == NTESAlertActionTypeExistRoom) {
                    item.itemType = NTESActionSheetItemDelete;
                } else {
                    item.itemType = NTESActionSheetItemNoraml;
                }
                item.sheetId = (int)[_actions indexOfObject:model];
                [alertActionModels addObject:item];
            }
        }
    }
    
    if (alertActionModels.count != 0) {
        __weak typeof(self) weakSelf = self;
        [NTESActionSheet showWithDesc:nil actionModels:alertActionModels action:^(NTESActionSheetModel *model) {
            int index = model.sheetId;
            NTESChatroomAlertAction *action = weakSelf.actions[index];
            if (action.handle) {
                action.handle(info);
            }
        } cancel:_cancel];
    }
}

- (UIAlertAction *)alertActionWithModel:(NTESChatroomAlertAction *)model info:(id)info {
    UIAlertAction *ret =  [UIAlertAction actionWithTitle:model.title
                                                   style:UIAlertActionStyleDefault
                                                 handler:^(UIAlertAction * _Nonnull action) {
        if (model.handle) {
            model.handle(info);
        }
    }];
    if (model.type == NTESAlertActionTypeCancelOnMicRequest
        || model.type == NTESAlertActionTypeDropMic
        || model.type == NTESAlertActionTypeExistRoom) {
        [ret setValue:[UIColor redColor] forKey:@"titleTextColor"];
    }
    return ret;
}

- (void)dismiss {
    [NTESActionSheet hide];
}

+ (void)showAlertWithMessage:(NSString *)message {
    [self showAlertWithMessage:message completion:nil];
}

+ (void)showAlertWithMessage:(NSString *)message
                  completion:(nullable dispatch_block_t)completion {
    UIAlertAction *ret = [UIAlertAction actionWithTitle:@"知道了" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        if (completion) {
            completion();
        }
    }];
    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:nil
                                                                     message:message
                                                              preferredStyle:UIAlertControllerStyleAlert];
    [alertVC addAction:ret];
    UINavigationController *rootVC = (UINavigationController *)[UIApplication sharedApplication].keyWindow.rootViewController;
    UIViewController *topVC = [rootVC.viewControllers lastObject];
    if (IS_IPAD) {
        UIPopoverPresentationController *popPresenter = [alertVC popoverPresentationController];
        popPresenter.sourceView = topVC.view;
        popPresenter.sourceRect = topVC.view.bounds;
    }
    [topVC presentViewController:alertVC animated:YES completion:nil];
}

@end

@implementation NTESChatroomAlertAction

+ (NTESChatroomAlertAction *)actionWithTitle:(NSString *)title
                                        type:(NTESAlertActionType)type
                                     handler:(NTESAlertActionHandle)handle {
    NTESChatroomAlertAction *ret = [[NTESChatroomAlertAction alloc] init];
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
