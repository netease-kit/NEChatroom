//
//  NTESHomeViewController.m
//  NEChatroom-iOS-ObjC
//
//  Created by vvj on 2021/2/1.
//  Copyright © 2021 netease. All rights reserved.
//

#import <UIKit/UIKit.h>

FOUNDATION_EXPORT const CGFloat kFontSize;
FOUNDATION_EXPORT const CGFloat kLineViewH;
FOUNDATION_EXPORT const CGFloat kExtraLineViewW;
FOUNDATION_EXPORT const CGFloat kMySegmentBtnTag;

/**
 底部线条样式
 */
typedef NS_ENUM(NSUInteger,BottomLineType){
    /** 正常默认样式 */
    BottomLineTypeNormal = 0,
    /** 按照最长字体长度展示线条宽度 */
    BottomLineTypeLongestFont,
    /** 按照最短字体长度展示线条宽度 */
    BottomLineTypeShortestFont,
    /** 按照字体宽度适配宽度 */
    BottomLineTypeaAdapterFont,
    /** 统一宽度 */
    BottomLineTypeaUniformWidth,
};

@interface NTESSegmentCtrl : UIView

/**
 初始化渐变色视图对象

 @param frame 位置大小
 @param colors 颜色数组，最前面的是第一个颜色，后面的依次排列
 @param locations 起始位置
 @param startPoint 开始的点
 @param endPoint 结束的点
 @return 视图对象
 */
- (instancetype)initWithFrame:(CGRect)frame gradientBackgroundWithColors:(NSArray<UIColor *> *)colors locations:(NSArray<NSNumber *> *)locations startPoint:(CGPoint)startPoint endPoint:(CGPoint)endPoint;

/**
 底部线条类型
 */
@property (nonatomic, assign) BottomLineType bottomLineType;
/* 只展示单个元素是否可点击(默认不可点击 NO)  */
@property (nonatomic,assign) BOOL singleClick;
/* 当前选中的字体是否变大(已废弃)  */
@property (nonatomic,assign) BOOL isBigger;
/** 是否显示底部间隔线(默认不显示) */
@property (nonatomic, assign) BOOL isShowBottomIntervalView;
/** 底部间隔线颜色 */
@property (nonatomic, strong) UIColor *bottomIntervalViewColor;
/* 显示字体大小(默认系统字体) */
@property (nonatomic,assign) NSInteger fontSize;
/* 显示字体类型以及大小 */
@property (nonatomic,strong) UIFont *textfont;
/// 选中字体大小(不设置则跟默认字体一样)
@property(nonatomic, strong) UIFont *selectTextFont;
/* 底部视图高度 */
@property (nonatomic,assign) NSInteger lineViewHeight;
/* 底部视图宽度 */
@property (nonatomic,assign) NSInteger lineViewWidth;

/* 未选中字体颜色 */
@property (nonatomic,strong) UIColor *normalLabelColor;

/* 选中字体颜色 */
@property (nonatomic,strong) UIColor *selectLabelColor;

/* 底部视图颜色 */
@property (nonatomic,strong) UIColor *lineViewColor;

/**
 是否显示底部线条圆角
 */
@property (nonatomic, assign) BOOL isShowLineBottomRoundedCorners;

/**
 底部线条距离底部间隔(默认0)
 */
@property (nonatomic, assign) CGFloat lineBottomDistanceInterval;

/*点击事件*/
@property (nonatomic,copy)void (^clickBlock)(NSInteger selectIndex);

/*设置当前选择的按钮序号*/
@property (nonatomic,assign) NSInteger sIndex;

/* 是否均等间隔  （暂时不能使用） */
@property (nonatomic,assign) BOOL isEqualInterval;

/* 数据源数组  */
@property (nonatomic,strong) NSArray *titleArray;

/**
 动态调整线条从一点去往另外一点

 @param fromIndex fromIndex
 @param toIndex toIndex
 @param progress 进度
 */
- (void)lineViewDidMoveFromIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex progress:(CGFloat)progress;

@end

@interface MySegmentBtn : UIControl
//文字
@property (nonatomic,strong) UILabel *nameLabel;

@end
