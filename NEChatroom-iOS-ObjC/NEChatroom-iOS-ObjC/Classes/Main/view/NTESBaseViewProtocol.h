//
//  NTESBaseViewProtocol.m
//  NEChatroom-iOS-ObjC
//
//  Created by vvj on 2021/1/28.
//  Copyright © 2021 netease. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol NTESBaseViewProtocol <NSObject>

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
