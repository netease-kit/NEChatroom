//
//  NTESTextInputView.h
//  NIMLiveDemo
//
//  Created by chris on 16/3/28.
//  Copyright © 2016年 Netease. All rights reserved.
//

#import "NTESGrowingTextView.h"

typedef NS_ENUM(NSUInteger, NTESDisableType){
    NTESDisableTypeMute = 0,
    NTESDisableTypeMuteAll,
};

@protocol NTESTextInputViewDelegate <NSObject>

@optional

- (void)didSendText:(NSString *)text;

- (void)willChangeHeight:(CGFloat)height;

- (void)didChangeHeight:(CGFloat)height;

- (void)topDidChange:(CGFloat)offset;

@end

@interface NTESTextInputView : UIView

@property (nonatomic,assign) id<NTESTextInputViewDelegate> delegate;

- (void)setEnableMuteWithType:(NTESDisableType)type;

- (void)setDisableMute;

@end
