//
//  NTESBaseView.h
//  NEChatroom-iOS-ObjC
//
//  Created by vvj on 2021/1/28.
//  Copyright © 2021 netease. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NTESBaseViewProtocol.h"
#import "NTESBaseModelProtocol.h"

@interface NTESBaseView : UIView<NTESBaseViewProtocol>

/**
 数据模型(对外只读，对内可修改)
 */
@property (nonatomic, readonly, strong) id model;

/**
 初始化对象(指定初始化方法)
 
 @param frame 布局
 @param model 数据模型
 @return 视图对象
 */
- (instancetype)initWithFrame:(CGRect)frame model:(id<NTESBaseModelProtocol>)model NS_DESIGNATED_INITIALIZER;

@end
