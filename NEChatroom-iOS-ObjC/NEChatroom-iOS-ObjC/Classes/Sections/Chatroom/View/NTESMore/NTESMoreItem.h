//
//  NTESMoreItem.h
//  NEChatroom-iOS-ObjC
//
//  Created by Wenchao Ding on 2021/1/27.
//  Copyright © 2021 netease. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NTESMoreItem : NSObject

/**
 启用图片
 */
@property (nonatomic, strong) UIImage *onImage;

/**
 禁用图片
 */
@property (nonatomic, strong) UIImage *offImage;

/**
 名称
 */
@property (nonatomic, copy) NSString *title;

/**
 是否开启
 */
@property (nonatomic, assign) BOOL on;

/**
 当前状态的图片
 */
@property (nonatomic, readonly) UIImage *currentImage;

/**
 标签
 */
@property (nonatomic, assign) NSInteger tag;

/**
初始化方法
*/
+ (instancetype)itemWithTitle:(NSString *)title onImage:(UIImage *)onImage offImage:(nullable UIImage *)offImage tag:(NSInteger)tag;

@end

NS_ASSUME_NONNULL_END
