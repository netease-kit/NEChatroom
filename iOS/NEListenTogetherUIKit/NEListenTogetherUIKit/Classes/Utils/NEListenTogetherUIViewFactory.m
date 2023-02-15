// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import "NEListenTogetherUIViewFactory.h"
#import "UIImage+ListenTogether.h"

@implementation NEListenTogetherUIViewFactory

+ (UITextField *)createTextfieldFrame:(CGRect)frame placeHolder:(NSString *)placeHolder {
  UITextField *textFiled = [[UITextField alloc] initWithFrame:frame];
  textFiled.placeholder = placeHolder;
  // 圆角
  textFiled.borderStyle = UITextBorderStyleNone;
  textFiled.clearButtonMode = UITextFieldViewModeWhileEditing;
  return textFiled;
}

+ (UILabel *)createLabelFrame:(CGRect)frame
                        title:(NSString *)title
                    textColor:(UIColor *)color
                textAlignment:(NSTextAlignment)textAlignment
                         font:(UIFont *)font {
  UILabel *label = [[UILabel alloc] initWithFrame:frame];
  if (title.length > 0) {
    label.text = title;
  }
  label.textColor = color;
  label.textAlignment = textAlignment;
  label.font = font;
  return label;
}

+ (UIButton *)createBtnFrame:(CGRect)frame
                       title:(NSString *)title
                     bgImage:(NSString *)bgImage
               selectBgImage:(NSString *)selectBgImage
                       image:(NSString *)image
                      target:(id)target
                      action:(SEL)action {
  NSString *path = [[NSBundle mainBundle]
      pathForResource:@"Frameworks/NEListenTogetherUIKit.framework/NEListenTogetherUIKit"
               ofType:@"bundle"];
  //    NSString *path = [[NSBundle bundleForClass:[self class]].resourcePath
  //    stringByAppendingPathComponent:@"NEListenTogetherUIKit.bundle"];
  NSBundle *bundle = [NSBundle bundleWithPath:path];
  return [NEListenTogetherUIViewFactory createBtnFrame:frame
                                                 title:title
                                               bgImage:bgImage
                                         selectBgImage:selectBgImage
                                                 image:image
                                                bundle:bundle
                                                target:target
                                                action:action];
}

+ (UIButton *)createBtnFrame:(CGRect)frame
                       title:(NSString *)title
                     bgImage:(NSString *)bgImage
               selectBgImage:(NSString *)selectBgImage
                       image:(NSString *)image
                      bundle:(NSBundle *)bundle
                      target:(id)target
                      action:(SEL)action {
  UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
  button.frame = frame;
  [button setTitle:title forState:UIControlStateNormal];
  // 字体颜色修改为黑色
  [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
  if (image.length) {
    if (bundle) {
      [button setImage:[UIImage imageNamed:image inBundle:bundle compatibleWithTraitCollection:nil]
              forState:UIControlStateNormal];
    } else {
      [button setImage:[UIImage voiceRoom_imageNamed:image] forState:UIControlStateNormal];
    }
  }
  if (bgImage.length) {
    if (bundle) {
      [button setBackgroundImage:[UIImage imageNamed:bgImage
                                                          inBundle:bundle
                                     compatibleWithTraitCollection:nil]
                        forState:UIControlStateNormal];
      [button setBackgroundImage:[UIImage imageNamed:bgImage
                                                          inBundle:bundle
                                     compatibleWithTraitCollection:nil]
                        forState:UIControlStateHighlighted];
    } else {
      [button setBackgroundImage:[UIImage voiceRoom_imageNamed:bgImage]
                        forState:UIControlStateNormal];
      [button setBackgroundImage:[UIImage voiceRoom_imageNamed:bgImage]
                        forState:UIControlStateHighlighted];
    }
  }
  // 选中图片
  if (selectBgImage.length) {
    if (bundle) {
      [button setBackgroundImage:[UIImage imageNamed:selectBgImage
                                                          inBundle:bundle
                                     compatibleWithTraitCollection:nil]
                        forState:UIControlStateSelected];
    } else {
      [button setBackgroundImage:[UIImage voiceRoom_imageNamed:selectBgImage]
                        forState:UIControlStateSelected];
    }
  }
  [button addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
  return button;
}

+ (UIImageView *)createImageViewFrame:(CGRect)frame imageName:(NSString *)imageName {
  UIImageView *imgView = [[UIImageView alloc] initWithFrame:frame];
  if (imageName.length > 0) {
    imgView.image = [UIImage voiceRoom_imageNamed:imageName];
  }
  return imgView;
}

+ (UIButton *)createSystemBtnFrame:(CGRect)frame
                             title:(NSString *)title
                        titleColor:(UIColor *)titleColor
                   backgroundColor:(UIColor *)bgColor
                            target:(id)target
                            action:(SEL)action {
  UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
  button.frame = frame;
  [button setTitle:title forState:UIControlStateNormal];
  // 字体颜色修改为黑色
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
