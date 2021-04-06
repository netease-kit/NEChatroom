//
//  UIButton+Layout.h
//  FBSearchBar
//
//  Created by Tim on 2019/4/8.
//  Copyright © 2019 Steven Xie. All rights reserved.
//

#import <UIKit/UIKit.h>

// 定义一个枚举（包含了四种类型的button）
typedef NS_ENUM(NSUInteger, QSButtonEdgeInsetsStyle) {
    QSButtonEdgeInsetsStyleDefault = 0, // 默认
    QSButtonEdgeInsetsStyleTop, // image在上，label在下
    QSButtonEdgeInsetsStyleLeft, // image在左，label在右
    QSButtonEdgeInsetsStyleBottom, // image在下，label在上
    QSButtonEdgeInsetsStyleRight // image在右，label在左
};


@interface UIButton (Layout)


/**
 *  设置button的titleLabel和imageView的布局样式，及间距
 *
 *  @param style titleLabel和imageView的布局样式
 *  @param space titleLabel和imageView的间距
 */
- (void)layoutButtonWithEdgeInsetsStyle:(QSButtonEdgeInsetsStyle)style
                        imageTitleSpace:(CGFloat)space;

- (void)layoutButtonWithEdgeInsetsStyle:(QSButtonEdgeInsetsStyle)style
imageTitleSpace:(CGFloat)space widthTolerance:(CGFloat)widthTolerance;

@end
