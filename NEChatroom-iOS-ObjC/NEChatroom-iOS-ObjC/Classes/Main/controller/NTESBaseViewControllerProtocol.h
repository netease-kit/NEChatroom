//
//  NTESBaseViewControllerProtocol.h
//  NLiteAVDemo
//
//  Created by 徐善栋 on 2020/12/31.
//  Copyright © 2020 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol NTESBaseViewControllerProtocol <NSObject>

/**
 初始化导航栏配置
 */
- (void)ntes_layoutNavigation;

/**
 初始化相关配置
 */
- (void)ntes_initializeConfig;

/**
 添加子视图
 */
- (void)ntes_addSubViews;

/**
 绑定视图模型以及相关事件
 */
- (void)ntes_bindViewModel;

/**
 加载数据
 */
- (void)ntes_getNewData;

@end
