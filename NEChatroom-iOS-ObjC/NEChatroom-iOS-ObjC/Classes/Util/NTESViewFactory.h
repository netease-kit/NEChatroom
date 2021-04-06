//
//  NETSViewFactory.h
//  NLiteAVDemo
//
//  Created by 徐善栋 on 2020/12/31.
//  Copyright © 2020 Netease. All rights reserved.
//  UIView的工厂方法

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NTESViewFactory : NSObject
/**
 创建UILabel

 @param frame 布局
 @param title 标题
 @param color 字体颜色
 @param textAlignment 对齐方式
 @param font 字体大小
 @return label
 */
+ (UILabel *)createLabelFrame:(CGRect)frame title:(NSString *)title textColor:(UIColor *)color textAlignment:(NSTextAlignment)textAlignment font:(UIFont *)font;

/**
 创建UIButton

 @param frame 布局
 @param title 标题
 @param bgImage 普通状态下背景图片
 @param selectBgImage 选中状态下背景图片
 @param image 普通状态下指示图片
 @param target target
 @param action action
 @return button
 */
+ (UIButton *)createBtnFrame:(CGRect)frame title:(NSString *)title bgImage:(NSString *)bgImage selectBgImage:(NSString *)selectBgImage image:(NSString *)image target:(id)target action:(SEL)action;

/**
 创建UIImageView

 @param frame 布局
 @param imageName 图片
 @return imageView
 */
+ (UIImageView *)createImageViewFrame:(CGRect)frame imageName:(NSString *)imageName;

/**
 创建TextField

 @param frame 布局
 @param placeHolder 占位提示文字
 @return textField
 */
+ (UITextField *)createTextfieldFrame:(CGRect)frame placeHolder:(NSString *)placeHolder;

/**
 创建文字类型btn
 
 @param frame 布局
 @param title 提示文字
 @param bgColor 背景颜色
 @param target target
 @param action action
 @return button
 */
+ (UIButton *)createSystemBtnFrame:(CGRect)frame title:(NSString *)title titleColor:(UIColor *)titleColor backgroundColor:(UIColor *)bgColor target:(id)target action:(SEL)action;

/**
 创建view

 @param frame 布局
 @param bgColor 背景色
 @return view
 */
+ (UIView *)createViewFrame:(CGRect)frame BackgroundColor:(UIColor *)bgColor;
@end

NS_ASSUME_NONNULL_END
