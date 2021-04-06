//
//  NTESHomeViewController.m
//  NEChatroom-iOS-ObjC
//
//  Created by vvj on 2021/2/1.
//  Copyright © 2021 netease. All rights reserved.
//

#import "NTESSegmentCtrl.h"
#import "UIView+NTES.h"

//未选中颜色
#define kNameLabelColor [UIColor darkTextColor]
//选中颜色
#define kSelectNameLabelColor [UIColor greenColor]
//底部线条颜色
#define kLineViewBGColor [UIColor orangeColor]
//字体大小
const CGFloat kFontSize = 14;
//底部视图高度
const CGFloat kLineViewH = 2;

const CGFloat kExtraLineViewW = 2;

const CGFloat kMySegmentBtnTag = 200;

#define kScreenW [UIScreen mainScreen].bounds.size.width
#define kScreenH [UIScreen mainScreen].bounds.size.height

@interface NTESSegmentCtrl ()
//底部线条
@property (nonatomic,strong) UIView *lineView;

@property (nonatomic,strong) NSMutableArray *btnArray;

@property (nonatomic,assign) CGFloat maxLabelW;


@end

@implementation NTESSegmentCtrl

- (instancetype)initWithFrame:(CGRect)frame gradientBackgroundWithColors:(NSArray<UIColor *> *)colors locations:(NSArray<NSNumber *> *)locations startPoint:(CGPoint)startPoint endPoint:(CGPoint)endPoint {
    if (self = [super initWithFrame:frame]) {
         [self setGradientBackgroundWithColors:colors locations:locations startPoint:startPoint endPoint:endPoint];
    }
    return self;
}

- (NSMutableArray *)btnArray {
    if (_btnArray == nil) {
        _btnArray = [NSMutableArray array];
    }
    return _btnArray;
}

- (instancetype)initWithFrame:(CGRect)frame {
    
    if (self = [super initWithFrame:frame]) {
        [self initializeTheDefaultProperties];
    }
    return self;
}

//xib
- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self initializeTheDefaultProperties];
    }
    return self;
}

//初始化默认属性
- (void)initializeTheDefaultProperties {
    self.fontSize = 18;
    self.lineViewColor = [UIColor orangeColor];
    self.lineViewHeight = 2;
    self.normalLabelColor = [UIColor darkTextColor];
    self.selectLabelColor = [UIColor greenColor];
    self.isShowBottomIntervalView = NO;
    self.singleClick = NO;
    self.bottomLineType = BottomLineTypeNormal;
    self.lineBottomDistanceInterval = 0;
}

#pragma mark -- 相关属性

- (void)setFontSize:(NSInteger)fontSize {
    _fontSize = fontSize;
    for (UIView *subView in self.subviews) {
        if ([subView isMemberOfClass:[MySegmentBtn class]]) {
            MySegmentBtn *btn = (MySegmentBtn *)subView;
            btn.nameLabel.font = Font_Default(fontSize);
        }
    }
}

- (void)setTextfont:(UIFont *)textfont {
    _textfont = textfont;
    for (UIView *subView in self.subviews) {
        if ([subView isMemberOfClass:[MySegmentBtn class]]) {
            MySegmentBtn *btn = (MySegmentBtn *)subView;
            btn.nameLabel.font = textfont;
        }
    }
}

- (void)setLineViewHeight:(NSInteger)lineViewHeight {
    _lineViewHeight = lineViewHeight;
}

- (void)setLineViewWidth:(NSInteger)lineViewWidth {
    _lineViewWidth = lineViewWidth;
}

- (void)setLineViewColor:(UIColor *)lineViewColor {
    _lineViewColor = lineViewColor;
}

- (void)setNormalLabelColor:(UIColor *)normalLabelColor {
    _normalLabelColor = normalLabelColor;
}

-(void)setSelectLabelColor:(UIColor *)selectLabelColor {
    _selectLabelColor = selectLabelColor;
}

- (void)setIsEqualInterval:(BOOL)isEqualInterval {
    _isEqualInterval = isEqualInterval;
    _isEqualInterval = NO;
}

- (void)setIsShowBottomIntervalView:(BOOL)isShowBottomIntervalView {
    _isShowBottomIntervalView = isShowBottomIntervalView;
}

- (void)setBottomIntervalViewColor:(UIColor *)bottomIntervalViewColor {
    _bottomIntervalViewColor = bottomIntervalViewColor;
}

- (void)setIsShowLineBottomRoundedCorners:(BOOL)isShowLineBottomRoundedCorners {
    _isShowLineBottomRoundedCorners = isShowLineBottomRoundedCorners;
}

- (void)setLineBottomDistanceInterval:(CGFloat)lineBottomDistanceInterval {
    _lineBottomDistanceInterval = lineBottomDistanceInterval;
}

- (void)setBottomLineType:(BottomLineType)bottomLineType {
    _bottomLineType = bottomLineType;
}

- (void)setSelectTextFont:(UIFont *)selectTextFont {
    _selectTextFont = selectTextFont;
}

#pragma mark -- 赋值
- (void)setTitleArray:(NSArray *)titleArray {
    _titleArray = titleArray;
    for (UIView *view in self.subviews) {
        [view removeFromSuperview];
    }
    
    //添加底部横线
    if (self.isShowBottomIntervalView) {
        UIView *bottomlineView = [[UIView alloc]initWithFrame:CGRectMake(0, self.bounds.size.height-0.5, self.bounds.size.width, 0.5)];
        bottomlineView.backgroundColor = self.bottomIntervalViewColor;
        [self addSubview:bottomlineView];
    }
    
    CGFloat w = self.bounds.size.width/titleArray.count;
    CGFloat h = self.bounds.size.height;
    if (self.isEqualInterval) {
        CGFloat allW = 0;
        for (NSInteger i = 0; i < self.titleArray.count; i++) {
            allW += [self textIsAdaptWidth:self.titleArray[i]];
        }
        w = (self.bounds.size.width-60 - allW)/titleArray.count;
    }
    CGFloat interval = 0;
    for (int i = 0; i < titleArray.count; i++) {
        MySegmentBtn *btn = nil;
        if (self.isEqualInterval) {
            if (i > 0) {
                interval += [self textIsAdaptWidth:self.titleArray[i-1]];
            }
            btn = [[MySegmentBtn alloc] initWithFrame:CGRectMake(30+w*i+interval,0, w, h)];
        } else {
            btn = [[MySegmentBtn alloc] initWithFrame:CGRectMake(w*i,0, w, h)];
        }
        //设置tag值，关联序号
        //         btn.nameLabel.center = CGPointMake(w/2, h/2);
        btn.tag = kMySegmentBtnTag+i;
        btn.nameLabel.text = titleArray[i];
        if (![NSObject isNullOrNilWithObject:self.selectTextFont] && i == 0) {
            btn.nameLabel.font = self.selectTextFont;
        }else {
            btn.nameLabel.font = [UIFont systemFontOfSize:self.fontSize];
        }
        btn.nameLabel.textColor = self.normalLabelColor;
        [btn addTarget:self action:@selector(clickBtn:) forControlEvents:UIControlEventTouchUpInside];
        if (titleArray.count == 1 && !self.singleClick) {
            //显示单个按钮默认不可点击
            btn.userInteractionEnabled = NO;
        }
        [self addSubview:btn];
        [self.btnArray addObject:btn];
    }
    [self setupBottomLineView];
    //默认选中第一个
    _sIndex = -1;
    self.sIndex = 0;
}

//排序（小->大）
- (NSArray *)bubbleSort1:(NSMutableArray*)array int:(int)n
{
    int i= n -1;  //初始时,最后位置保持不变
    while ( i > 0) {
        int pos= 0; //每趟开始时,无记录交换
        for (int j = 0; j< i; j++)
        {
            if ([array[j] length]> [array[j+1] length]) {
                pos= j; //记录交换的位置
                NSNumber* tmp = array[j];
                [array replaceObjectAtIndex:j withObject:array[j+1]];
                [array replaceObjectAtIndex:j+1 withObject:tmp];
            }
        }
        i= pos; //为下一趟排序作准备
    }
    NSArray *arr = [NSArray arrayWithArray:array];
    return arr;
}

//设置底部线条
- (void)setupBottomLineView {
    CGFloat w = self.bounds.size.width/self.titleArray.count;
    CGFloat h = self.bounds.size.height;
    if (self.isEqualInterval) {
        CGFloat allW = 0;
        for (NSInteger i = 0; i < self.titleArray.count; i++) {
            allW += [self textIsAdaptWidth:self.titleArray[i]];
        }
        w = (self.bounds.size.width-60 - allW)/self.titleArray.count;
    }
    if (self.bottomLineType == BottomLineTypeNormal) {
        //默认样式
        self.lineView = [[UIView alloc] initWithFrame:CGRectMake(0, h-self.lineViewHeight-self.lineBottomDistanceInterval, w, self.lineViewHeight)];
        self.lineView.backgroundColor = self.lineViewColor;
        [self addSubview:self.lineView];
    }else if (self.bottomLineType == BottomLineTypeLongestFont) {
        //按照最长字体长度展示线条宽度
        NSInteger num = 0;
        NSMutableArray *array = [NSMutableArray arrayWithArray:self.titleArray];
        NSArray *arr = [self bubbleSort1:array int:(int)self.titleArray.count];
        for (NSInteger j = 0; j<self.titleArray.count; j++) {
            if ([self.titleArray[j] isEqualToString:[arr lastObject]]) {
                num = j;
            }
        }
        CGFloat nameLabelW = 0;
        nameLabelW = [self textIsAdaptWidth:self.titleArray[num]] + kExtraLineViewW;
        self.lineView = [[UIView alloc]initWithFrame:CGRectMake((w - nameLabelW)/2, h-self.lineViewHeight-self.lineBottomDistanceInterval, nameLabelW, self.lineViewHeight)];
        self.lineView.backgroundColor = self.lineViewColor;
        self.maxLabelW = nameLabelW;
        [self addSubview:self.lineView];
    }else if (self.bottomLineType == BottomLineTypeShortestFont) {
        //按照最短字体长度展示线条宽度
        NSInteger num = 0;
        NSMutableArray *array = [NSMutableArray arrayWithArray:self.titleArray];
        NSArray *arr = [self bubbleSort1:array int:(int)self.titleArray.count];
        for (NSInteger j = 0; j<self.titleArray.count; j++) {
            if ([self.titleArray[j] isEqualToString:[arr firstObject]]) {
                num = j;
            }
        }
        CGFloat nameLabelW = 0;
        nameLabelW = [self textIsAdaptWidth:self.titleArray[num]] + kExtraLineViewW;
        self.lineView = [[UIView alloc]initWithFrame:CGRectMake((w - nameLabelW)/2, h-self.lineViewHeight-self.lineBottomDistanceInterval, nameLabelW, self.lineViewHeight)];
        self.lineView.backgroundColor = self.lineViewColor;
        self.maxLabelW = nameLabelW;
        [self.lineView cutViewRounded:UIRectCornerTopLeft | UIRectCornerTopRight cornerRadii:CGSizeMake(1, 1)];
        
        
        
        [self addSubview:self.lineView];
    }else if (self.bottomLineType == BottomLineTypeaAdapterFont) {
        //按照字体宽度适配宽度
        NSInteger num = 0;
        NSMutableArray *array = [NSMutableArray arrayWithArray:self.titleArray];
        NSArray *arr = [self bubbleSort1:array int:(int)self.titleArray.count];
        for (NSInteger j = 0; j<self.titleArray.count; j++) {
            if ([self.titleArray[j] isEqualToString:[arr lastObject]]) {
                num = j;
            }
        }
        CGFloat nameLabelW = 0;
        nameLabelW = [self textIsAdaptWidth:[self.titleArray firstObject]];
        self.lineView = [[UIView alloc]initWithFrame:CGRectMake((w - nameLabelW)/2, h-self.lineViewHeight-self.lineBottomDistanceInterval, nameLabelW, self.lineViewHeight)];
        self.lineView.backgroundColor = self.lineViewColor;
        self.maxLabelW = nameLabelW;
        [self addSubview:self.lineView];
    }else if (self.bottomLineType == BottomLineTypeaUniformWidth) {
        //统一宽度
        self.lineView = [[UIView alloc] initWithFrame:CGRectMake(0, h-self.lineViewHeight-self.lineBottomDistanceInterval, self.lineViewWidth, self.lineViewHeight)];
        self.lineView.backgroundColor = self.lineViewColor;
        [self addSubview:self.lineView];
    }
    if (self.isShowLineBottomRoundedCorners) {
        //显示圆角
        self.lineView.layer.cornerRadius = self.lineView.size.height / 2;
        self.lineView.layer.masksToBounds = YES;
    }
}

//点击回调
- (void)clickBtn:(MySegmentBtn *)btn
{
    NSInteger index = btn.tag - kMySegmentBtnTag;
    if (self.clickBlock) {
        self.clickBlock(index);
    }
    //修改底部视图的位置
    self.sIndex = index;
}

- (void)setSIndex:(NSInteger)sIndex {
    CGFloat w = self.bounds.size.width/self.titleArray.count;
    if (_sIndex != sIndex) {
        //修改当前选择的按钮
        //取消前面按钮的选中状态
        MySegmentBtn *lastBtn = (MySegmentBtn *)[self viewWithTag:kMySegmentBtnTag+_sIndex];
        lastBtn.nameLabel.textColor = self.normalLabelColor;
        //选中当前的按钮
        MySegmentBtn *curBtn = (MySegmentBtn *)[self viewWithTag:kMySegmentBtnTag+sIndex];
        curBtn.nameLabel.textColor = self.selectLabelColor;
        //当前选中的字体变大
        [UIView animateWithDuration:0.2 delay:0.1 options:UIViewAnimationOptionTransitionCurlDown animations:^{
            lastBtn.nameLabel.font = [UIFont systemFontOfSize:self.fontSize];
            if (![NSObject isNullOrNilWithObject:self.selectTextFont]) {
                curBtn.nameLabel.font = self.selectTextFont;
            }else {
                 curBtn.nameLabel.font = [UIFont systemFontOfSize:self.fontSize];;
            }
        } completion:^(BOOL finished) {
            lastBtn.nameLabel.font = [UIFont systemFontOfSize:self.fontSize];
            if (![NSObject isNullOrNilWithObject:self.selectTextFont]) {
                curBtn.nameLabel.font = self.selectTextFont;
            }else {
                 curBtn.nameLabel.font = [UIFont systemFontOfSize:self.fontSize];;
            }
        }];
//        if (self.isBigger) {
//        }
        //修改底部视图的位置
        [UIView animateWithDuration:0.2 animations:^{
            CGRect lastFrame = self.lineView.frame;
            if (self.bottomLineType == BottomLineTypeNormal ||
                self.bottomLineType == BottomLineTypeaUniformWidth) {
                 lastFrame.origin.x = lastFrame.size.width*sIndex;
            }else {
                CGFloat lengthW = [self textIsAdaptWidth:self.titleArray[sIndex]];
                if (sIndex == 0) {
                    if (self.bottomLineType == BottomLineTypeaAdapterFont) {
                        //底部视图自适应长度
                        lastFrame.origin.x = (w-lengthW)/2;
                        lastFrame.size.width = lengthW;
                    }else {
                         lastFrame.origin.x = (w-self.maxLabelW)/2;
                    }
                } else {
                    if (self.bottomLineType == BottomLineTypeaAdapterFont) {
                        lastFrame.origin.x = w*sIndex+(w-lengthW)/2;
                        lastFrame.size.width = lengthW;
                    }else {
                         lastFrame.origin.x = w*sIndex+(w-self.maxLabelW)/2;
                    }
                }
            }
            self.lineView.frame = lastFrame;
        }];
        _sIndex = sIndex;
    }
}

#pragma mark ********** 动态调整线条位置 **********
- (void)lineViewDidMoveFromIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex progress:(CGFloat)progress {
    if (fromIndex < 0 ||
        fromIndex >= self.titleArray.count ||
        toIndex < 0 ||
        toIndex >= self.titleArray.count
        ) {
        return;
    }
    MySegmentBtn *oldTitleView = (MySegmentBtn *)self.btnArray[fromIndex];
    MySegmentBtn *currentTitleView = (MySegmentBtn *)self.btnArray[toIndex];
    CGFloat xDistance = currentTitleView.centerX - oldTitleView.centerX;
    CGFloat wDistance = [self textIsAdaptWidth:self.titleArray[toIndex]] - self.lineView.width;
    if (self.bottomLineType == BottomLineTypeaAdapterFont) {
        self.lineView.width += wDistance * progress;
    }else {
        self.lineView.centerX = oldTitleView.centerX + xDistance * progress;
    }
}

- (CGFloat)textIsAdaptWidth:(NSString *)text{
    CGFloat w = [text boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, self.bounds.size.height) options:NSStringDrawingUsesLineFragmentOrigin |NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:self.fontSize]} context:nil].size.width;
    return w;
}

@end


@implementation MySegmentBtn

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.nameLabel = [[UILabel alloc]initWithFrame:self.bounds];
        self.nameLabel.textColor = kNameLabelColor;
        self.nameLabel.textAlignment = NSTextAlignmentCenter;
        self.nameLabel.font =  TextFont_18;
        [self addSubview:self.nameLabel];
    }
    return self;
}

@end
