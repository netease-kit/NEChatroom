//
//  NTESHomeTableVIewCell.h
//  NEChatroom-iOS-ObjC
//
//  Created by vvj on 2021/2/1.
//  Copyright © 2021 netease. All rights reserved.
//
#import <Foundation/Foundation.h>

@protocol NTESBaseModelProtocol <NSObject>

@optional

/**
 初始化配置方法
 */
- (void)fb_initialize;

/**
 数据解析

 @param data 源数据
 */
- (void)dataParsing:(id)data;

@end
