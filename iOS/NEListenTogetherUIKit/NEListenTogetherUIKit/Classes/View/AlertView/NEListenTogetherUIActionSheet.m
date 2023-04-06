// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import "NEListenTogetherUIActionSheet.h"
#import "NEListenTogetherLocalized.h"

@implementation NEUIActionSheetModel
@end

@interface UIColor (Extend)
+ (UIColor *)ne_vrColorWithHexString:(NSString *)stringToConvert;
@end

@interface NEListenTogetherUIActionSheet ()
@property(nonatomic, copy) NSString *desc;
@property(nonatomic, strong) UILabel *descriptionL;
@property(nonatomic, strong) UIView *bgView;
@property(nonatomic, strong) NSArray *actionModels;
@property(nonatomic, copy) void (^click)(NEUIActionSheetModel *model);
@property(nonatomic, copy) dispatch_block_t cancel;
@end

@implementation NEListenTogetherUIActionSheet
/**
 所有需要修改的外观显示的常量
 */
#define BG_Color [UIColor colorWithRed:0 green:0 blue:0 alpha:0.6]
#define Bottom_BG_Color [UIColor ne_vrColorWithHexString:@"EFEFEF"]
#define Desc_Color [UIColor ne_vrColorWithHexString:@"#666666"]
#define Desc_Font [UIFont systemFontOfSize:12]
#define Item_Normal_Color [UIColor blackColor]
#define Item_Normal_Font [UIFont systemFontOfSize:16]
#define Sub_Item_Normal_Color [UIColor blackColor]
#define Sub_Item_Normal_Font [UIFont systemFontOfSize:12]
#define Item_Delete_Color [UIColor redColor]
#define Item_Delete_Font [UIFont systemFontOfSize:16]

static const CGFloat kitemHeight = 50.0f;
static const CGFloat kmiddleGap = 10.0f;
static const int kitemOriginTag = 23;

static NEListenTogetherUIActionSheet *sheet = nil;

+ (void)showWithDesc:(NSString *)desc
        actionModels:(NSArray<NEUIActionSheetModel *> *)models
              action:(void (^)(NEUIActionSheetModel *))action {
  [self showWithDesc:desc actionModels:models action:action cancel:nil];
}

+ (void)showWithDesc:(NSString *)desc
        actionModels:(NSArray<NEUIActionSheetModel *> *)models
              action:(void (^)(NEUIActionSheetModel *))action
              cancel:(dispatch_block_t)cancel {
  if (sheet) {
    return;
  }
  sheet = [[NEListenTogetherUIActionSheet alloc] initWithFrame:CGRectZero];
  sheet.desc = desc;
  sheet.actionModels = models;
  sheet.click = action;
  sheet.cancel = cancel;
  [sheet createUI];
  [sheet show];
}

- (void)show {
  [[UIApplication sharedApplication].keyWindow addSubview:self];
  [[UIApplication sharedApplication].keyWindow addSubview:self.bgView];
  [UIView animateWithDuration:0.3
                   animations:^{
                     self.bgView.frame =
                         CGRectMake(0, self.bounds.size.height - self.bgView.bounds.size.height,
                                    self.bounds.size.width, self.bgView.bounds.size.height);
                   }];
  self.bgView.frame = CGRectMake(0, self.bounds.size.height - self.bgView.bounds.size.height,
                                 self.bounds.size.width, self.bgView.bounds.size.height);
}

+ (void)hide {
  [sheet hide];
}

- (void)setFrame:(CGRect)frame {
  CGRect rect = [UIScreen mainScreen].bounds;
  [super setFrame:rect];
}

- (void)createUI {
  self.tag = 1236;
  self.backgroundColor = BG_Color;
  self.bgView = [[UIView alloc] init];
  self.bgView.backgroundColor = Bottom_BG_Color;

  // 加一个介绍
  CGFloat orginItemY = 0;
  if (sheet.desc.length) {
    [sheet addDescrioptionLabel];
    orginItemY = [sheet descriptionStringHeight] + 1;
  }
  // 确定整个视图的frame
  CGFloat screenWidth = self.bounds.size.width;
  CGFloat screenHeight = self.bounds.size.height;
  self.bgView.frame =
      CGRectMake(0, screenHeight, screenWidth,
                 orginItemY + (self.actionModels.count + 1) * (kitemHeight + 1) + kmiddleGap);
  for (int i = 0; i < self.actionModels.count; i++) {
    NEUIActionSheetModel *model = self.actionModels[i];
    UIButton *button = [[UIButton alloc] init];
    button.backgroundColor = [UIColor whiteColor];
    button.tag = kitemOriginTag + i;
    button.frame = CGRectMake(0, orginItemY + (kitemHeight + 1) * i, screenWidth, kitemHeight);
    [button addTarget:self
                  action:@selector(itemClick:)
        forControlEvents:UIControlEventTouchUpInside];
    [self.bgView addSubview:button];

    UILabel *title = [[UILabel alloc] init];
    if (model.subTitle.length) {
      title.frame = CGRectMake(0, 0, screenWidth, 30);
    } else {
      title.frame = button.bounds;
    }
    title.textAlignment = NSTextAlignmentCenter;
    if (model.itemType == NSTextAlignmentCenter) {
      title.textColor = Item_Delete_Color;
    } else {
      title.textColor = Item_Normal_Color;
    }
    title.font = Item_Normal_Font;
    title.text = model.title;
    [button addSubview:title];

    if (model.subTitle) {
      UILabel *subTitle = [[UILabel alloc] init];
      subTitle.frame = CGRectMake(0, 30, screenWidth, 20);
      subTitle.textAlignment = NSTextAlignmentCenter;
      if (model.itemType == NEUIActionSheetItemDelete) {
        subTitle.textColor = Item_Delete_Color;
      } else {
        subTitle.textColor = Sub_Item_Normal_Color;
      }
      subTitle.font = Sub_Item_Normal_Font;
      subTitle.text = model.subTitle;
      [button addSubview:subTitle];
    }
  }

  UIButton *button = [[UIButton alloc] init];
  button.backgroundColor = [UIColor whiteColor];
  button.tag = kitemOriginTag + self.actionModels.count;
  button.frame =
      CGRectMake(0, self.bgView.frame.size.height - kitemHeight - 1, screenWidth, kitemHeight);
  [button addTarget:self action:@selector(itemClick:) forControlEvents:UIControlEventTouchUpInside];
  [self.bgView addSubview:button];

  UILabel *title = [[UILabel alloc] init];
  title.frame = CGRectMake(0, 0, screenWidth, kitemHeight);
  title.textAlignment = NSTextAlignmentCenter;
  title.textColor = Item_Normal_Color;
  title.font = Item_Normal_Font;
  title.text = NELocalizedString(@"取消");
  [button addSubview:title];

  UITapGestureRecognizer *tap =
      [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction)];
  [self addGestureRecognizer:tap];
}

- (void)addDescrioptionLabel {
  _descriptionL = [[UILabel alloc] init];
  _descriptionL.font = Desc_Font;
  _descriptionL.textColor = Desc_Color;
  _descriptionL.textAlignment = NSTextAlignmentCenter;
  _descriptionL.text = self.desc;
  CGFloat heigt = [self descriptionStringHeight];
  UIView *view = [[UIView alloc] init];
  view.backgroundColor = [UIColor whiteColor];
  view.frame = CGRectMake(0, 0, self.bounds.size.width, heigt);
  _descriptionL.frame = CGRectMake(15, 0, view.bounds.size.width - 15 * 2, heigt);
  [view addSubview:_descriptionL];
  [self.bgView addSubview:view];
}

// 获取描述的label的高度
- (CGFloat)descriptionStringHeight {
  CGSize size =
      [self.desc boundingRectWithSize:CGSizeMake(self.bounds.size.width - 15 * 2, CGFLOAT_MAX)
                              options:NSStringDrawingUsesLineFragmentOrigin
                           attributes:@{NSFontAttributeName : self.descriptionL.font}
                              context:nil]
          .size;
  if (size.height < kitemHeight) {
    return kitemHeight;
  }
  return size.height;
}

- (void)itemClick:(UIButton *)button {
  [sheet hide];
  NSInteger index = button.tag - kitemOriginTag;
  if (index == self.actionModels.count) {
    // 用户点击取消
    if (_cancel) {
      _cancel();
    }
    return;
  }

  //    index = index > self.actionModels.count ? 0:index;
  if (index > self.actionModels.count) {  // 防止数组越界
    [self hide];
    return;
  }

  NEUIActionSheetModel *model = self.actionModels[index];
  if (model.actionBlock) {
    model.actionBlock();
  }
  if (self.click) {
    self.click(model);
  }
}

- (void)tapAction {
  if (_cancel) {
    _cancel();
  }
  [self hide];
}

- (void)hide {
  [UIView animateWithDuration:0.3
      animations:^{
        self.bgView.frame = CGRectMake(0, self.bounds.size.height, self.bounds.size.width,
                                       self.bgView.bounds.size.height);
      }
      completion:^(BOOL finished) {
        if (finished) {
          self.desc = nil;
          [self.bgView removeFromSuperview];
          [self removeFromSuperview];
          sheet = nil;
        }
      }];
}

- (void)dealloc {
  NSLog(@"%s", __func__);
}
@end

@implementation UIColor (Extend)
+ (UIColor *)ne_vrColorWithHexString:(NSString *)stringToConvert {
  NSString *cString = [[stringToConvert
      stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] uppercaseString];
  if ([cString length] < 6) return nil;
  if ([cString hasPrefix:@"0X"]) {
    cString = [cString substringFromIndex:2];
  }
  if ([cString hasPrefix:@"#"]) {
    cString = [cString substringFromIndex:1];
  }
  if ([cString length] != 6) return nil;

  NSRange rang;
  rang.location = 0;
  rang.length = 2;
  NSString *rString = [cString substringWithRange:rang];

  rang.location = 2;
  NSString *gString = [cString substringWithRange:rang];

  rang.location = 4;
  NSString *bString = [cString substringWithRange:rang];

  unsigned int r, g, b;
  [[NSScanner scannerWithString:rString] scanHexInt:&r];
  [[NSScanner scannerWithString:gString] scanHexInt:&g];
  [[NSScanner scannerWithString:bString] scanHexInt:&b];

  return [UIColor colorWithRed:((float)r / 255.0f)
                         green:((float)g / 255.0f)
                          blue:((float)b / 255.0f)
                         alpha:1.0f];
}

@end
