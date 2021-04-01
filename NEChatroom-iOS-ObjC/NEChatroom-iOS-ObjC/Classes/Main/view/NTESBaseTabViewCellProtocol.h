//
//  NTESHomeTableVIewCell.h
//  NEChatroom-iOS-ObjC
//
//  Created by vvj on 2021/2/1.
//  Copyright © 2021 netease. All rights reserved.
//


#import <Foundation/Foundation.h>

@protocol NTESBaseTabViewCellProtocol <NSObject>

@optional

/**
 子视图添加
 */
- (void)ntes_setupViews;

/**
 业务逻辑绑定
 */
- (void)ntes_bindViewModel;

@end
