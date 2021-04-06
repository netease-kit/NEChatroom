//
//  NTESHomeTableVIewCell.h
//  NEChatroom-iOS-ObjC
//
//  Created by vvj on 2021/2/1.
//  Copyright © 2021 netease. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NTESBaseTabViewCellProtocol.h"
#import "NTESBaseModelProtocol.h"

@interface NTESBaseTabViewCell : UITableViewCell<NTESBaseTabViewCellProtocol>

/**
 数据模型(对外只读，对内可修改)
 */
@property (nonatomic, readonly, strong) id model;


/**
 分割线显示还是隐藏, yes是隐藏
 */
@property (nonatomic,assign) BOOL splitLineStyle;

/**
 初始化方法
 
 @param style 样式
 @param reuseIdentifier 标记id
 @param model 数据模型
 @return 视图对象
 */
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier model:(id<NTESBaseModelProtocol>)model NS_DESIGNATED_INITIALIZER;




@end
