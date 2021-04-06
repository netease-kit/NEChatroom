//
//  NTESBaseViewController.h
//  NLiteAVDemo
//
//  Created by 徐善栋 on 2020/12/31.
//  Copyright © 2020 Netease. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NTESBaseViewControllerProtocol.h"


/**
 事件回调
 */
typedef void (^EventBlock)(_Nullable id data);

NS_ASSUME_NONNULL_BEGIN

@interface NTESBaseViewController : UIViewController<NTESBaseViewControllerProtocol>
@property (nonatomic, readonly, assign) CGFloat currentNavHeight;// 当前导航栏高度
@property (nonatomic, readonly, assign) CGFloat currentTabbarHeight;// 当前Tab高度
/**
 参数
 */
@property (nonatomic, strong) id params;

/**
 事件回调属性
 */
@property (nonatomic, copy) EventBlock eventBlcok;


/**
 左边Item
 */
@property (nonatomic, strong) UIButton *leftButton;

/**
 右边Item
 */
@property (nonatomic, strong) UIButton *rightButton;

/**
 添加左边Item
 
 @param actionBlock 点击事件(注意点击事件需要弱引用self,防止引用循坏)
 */
- (void)addLeftNavItem:(NSString *)title actionBlock:(void(^)(id sender))actionBlock;

/**
 添加左边带图片的Item
 
 @param actionBlock 点击事件(注意点击事件需要弱引用self,防止引用循坏)
 */
- (void)addLeftImageNavItem:(NSString *)imageName actionBlock:(void(^)(id sender))actionBlock;

/**
 添加右边Item
 
 @param actionBlock 点击事件(注意点击事件需要弱引用self,防止引用循坏)
 */
- (void)addRightNavItem:(NSString *)title actionBlock:(void(^)(id sender))actionBlock;


/**
 添加右边带图片的item
 
 @param actionBlock 点击事件(注意点击事件需要弱引用self,防止引用循坏)
 */
- (void)addRightImageNavItem:(NSString *)imageName actionBlock:(void(^)(id sender))actionBlock;

@end

NS_ASSUME_NONNULL_END
