//
//  NETSKeyboardToolbar.h
//  NLiteAVDemo
//
//  Created by Think on 2021/1/20.
//  Copyright © 2021 Netease. All rights reserved.
//

#import "NTESBaseView.h"

NS_ASSUME_NONNULL_BEGIN

@protocol NTESKeyboardToolbarDelegate <NSObject>

/**
 点击工具条发送文字
 @param text    - 文本
 */
- (void)didToolBarSendText:(NSString *)text;

@end

@interface NTESKeyboardToolbarView : NTESBaseView


@property (nonatomic, weak) id<NTESKeyboardToolbarDelegate> cusDelegate;

////相应成为第一响应者
- (void)becomeFirstResponse;

- (void)setUpInputContent:(NSString *)content;

@end

NS_ASSUME_NONNULL_END
