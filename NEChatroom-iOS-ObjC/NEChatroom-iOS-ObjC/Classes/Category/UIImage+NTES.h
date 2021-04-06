//
//  UIImage+NTES.h
//  NEChatroom-iOS-ObjC
//
//  Created by Think on 2021/2/1.
//  Copyright © 2021 netease. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIImage (NTES)

/**
 绘制纯色图片
 
 @param color 图片颜色
 @return 纯色图片
 */
+ (UIImage *)ne_imageWithColor:(UIColor *)color;

/**
为图片染色

@param tintColor 渲染颜色
@return 染色后的图片
*/
- (UIImage *)ne_imageWithTintColor:(UIColor *)tintColor;

@end

NS_ASSUME_NONNULL_END
