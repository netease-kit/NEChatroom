//
//  NETSViewFactory.m
//  NLiteAVDemo
//
//  Created by 徐善栋 on 2020/12/31.
//  Copyright © 2020 Netease. All rights reserved.
//

#import "NTESViewFactory.h"

@implementation NTESViewFactory

+ (UITextField *)createTextfieldFrame:(CGRect)frame placeHolder:(NSString *)placeHolder {
    UITextField * textFiled =[[UITextField alloc]initWithFrame:frame];
    textFiled.placeholder=placeHolder;
    //圆角
    textFiled.borderStyle = UITextBorderStyleNone;
    textFiled.clearButtonMode = UITextFieldViewModeWhileEditing;
    return textFiled;
}


+ (UILabel *)createLabelFrame:(CGRect)frame title:(NSString *)title textColor:(UIColor *)color textAlignment:(NSTextAlignment)textAlignment font:(UIFont *)font {
    UILabel *label = [[UILabel alloc] initWithFrame:frame];
    if (title.length>0) {
        label.text = title;
    }
    label.textColor = color;
    label.textAlignment = textAlignment;
    label.font = font;
    return label;
}

+ (UIButton *)createBtnFrame:(CGRect)frame title:(NSString *)title bgImage:(NSString *)bgImage selectBgImage:(NSString *)selectBgImage image:(NSString *)image target:(id)target action:(SEL)action {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = frame;
    [button setTitle:title forState:UIControlStateNormal];
    //字体颜色修改为黑色
    [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    if (image) {
        [button setImage:[UIImage imageNamed:image] forState:UIControlStateNormal];
    }
    if (bgImage) {
        [button setBackgroundImage:[UIImage imageNamed:bgImage] forState:UIControlStateNormal];
        [button setBackgroundImage:[UIImage imageNamed:bgImage] forState:UIControlStateHighlighted];
    }
    //选中图片
    if (selectBgImage) {
        [button setBackgroundImage:[UIImage imageNamed:selectBgImage] forState:UIControlStateSelected];
    }
    [button addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    return button;
}

+ (UIImageView *)createImageViewFrame:(CGRect)frame imageName:(NSString *)imageName {
    UIImageView *imgView = [[UIImageView alloc] initWithFrame:frame];
    if (imageName.length>0) {
        imgView.image = [UIImage imageNamed:imageName];
    }
    return imgView;
}

+ (UIButton *)createSystemBtnFrame:(CGRect)frame title:(NSString *)title titleColor:(UIColor *)titleColor backgroundColor:(UIColor *)bgColor target:(id)target action:(SEL)action {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    button.frame = frame;
    [button setTitle:title forState:UIControlStateNormal];
    //字体颜色修改为黑色
    [button setTitleColor:titleColor forState:UIControlStateNormal];
    [button setBackgroundColor:bgColor];
    [button addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    return button;
}

+ (UIView *)createViewFrame:(CGRect)frame BackgroundColor:(UIColor *)bgColor {
    UIView *view = [[UIView alloc] initWithFrame:frame];
    view.backgroundColor = bgColor;
    return view;
}
@end
