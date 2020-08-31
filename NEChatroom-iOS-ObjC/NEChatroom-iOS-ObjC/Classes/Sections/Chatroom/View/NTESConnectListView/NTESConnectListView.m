//
//  NTESConnectListView.m
//  NERtcAudioChatroom
//
//  Created by Simon Blue on 2019/1/28.
//  Copyright © 2019年 netease. All rights reserved.
//

#import "NTESConnectListView.h"
#import "UIView+NTES.h"
#import "NTESConnectListViewCell.h"
#import "NTESMicInfo.h"
#import "NTESConnectAlertView.h"

#define cellHeight 80
#define connectAlertViewHeight 57
#define connectAlertViewWidth 84
#define titleLabelHeight  51
#define tableviewMaxHeight (cellHeight*4 + cellHeight/2)

@interface NTESConnectListView ()<UITableViewDelegate, UITableViewDataSource, NTESConnectListViewCellDelegate,NTESConnectAlertViewDelegate>
{
    CGRect _preRect;
}
@property (nonatomic ,strong)UIView *bar;
@property (nonatomic ,strong)UITableView *listView;
@property (nonatomic ,strong)UILabel *titleLable;
@property (nonatomic ,strong)NSMutableArray *dataArray;
@property (nonatomic ,strong)NTESConnectAlertView *connectAlertView;
@property (nonatomic ,strong)UIView *coverView;
@property (nonatomic ,assign)BOOL listViewPushed;
@property (nonatomic ,assign)BOOL isShown;
@end

@implementation NTESConnectListView

- (void)dealloc {
    NELPLogInfo(@"NTESConnectListView 释放");
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self addTarget:self action:@selector(onTapBackground:) forControlEvents:UIControlEventTouchUpInside];
    }
    return self;
}

- (void)onTapBackground:(id)sender
{
    [self dismiss];
}

- (void)showAsAlertOnView:(UIView *)view
{
    if (_isShown) {
        return;
    }
    
    [view addSubview:self];
    //先刷新宽高
    [self layoutIfNeeded];
    self.bottom = 0;
    self.listView.hidden = YES;
    self.titleLable.hidden = YES;
    [UIView animateWithDuration:0.25 animations:^{
        self.bottom = IPHONE_X ? IPHONE_X_HairHeight + connectAlertViewHeight : connectAlertViewHeight;
    }];
    self.listViewPushed = NO;
    [self.connectAlertView refreshAlertView:self.listViewPushed];
    _isShown = YES;
}

- (void)showListView
{
    self.listView.hidden = NO;
    self.titleLable.hidden = NO;
    self.bottom = 0;
    [self forceLayoutSubviews];
    [UIView animateWithDuration:0.25 animations:^{
        self.top = 0;
    } completion:^(BOOL finished) {
        self.listViewPushed = YES;
        [self.connectAlertView refreshAlertView:self.listViewPushed];
    }];
}

- (void)dismissListView
{
    [UIView animateWithDuration:0.25 animations:^{
        self.bottom = IPHONE_X ? IPHONE_X_HairHeight + connectAlertViewHeight : connectAlertViewHeight;
    } completion:^(BOOL finished) {
        self.listView.hidden = YES;
        self.titleLable.hidden = YES;
        self.listViewPushed = NO;
        [self.connectAlertView refreshAlertView:self.listViewPushed];
    }];
}

- (void)dismiss
{
    if (!_isShown) {
        return;
    }
    
    [UIView animateWithDuration:0.25 animations:^{
        self.bottom = 0;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
        self.listViewPushed = NO;
    }];
    _isShown = NO;
}

- (void)refreshWithDataArray:(NSMutableArray *)dataArray
{
    if (!dataArray.count) {
        [self dismiss];
        return;
    }
    self.dataArray = dataArray;
    [self.connectAlertView updateConnectCount:self.dataArray.count];
    [self.titleLable setText:[NSString stringWithFormat:@"申请上麦(%lu)",(unsigned long)self.dataArray.count]];
    [self.listView reloadData];
    [self forceLayoutSubviews];
}

- (void)forceLayoutSubviews {
    if (!_listView.hidden) {
        self.height = self.barHeight;
        
        self.bar.frame = CGRectMake(0, 0, self.width, self.height);
        self.coverView.frame = CGRectMake(0,
                                          0,
                                          self.width,
                                          self.bar.height - self.listViewHeight - titleLabelHeight - connectAlertViewHeight);
        self.titleLable.frame = CGRectMake(0, self.coverView.bottom ? : 0, self.width, titleLabelHeight);
        
        self.listView.frame = CGRectMake(0, self.titleLable.bottom, self.width, self.listViewHeight);

        self.connectAlertView.width = connectAlertViewWidth;
        self.connectAlertView.height = connectAlertViewHeight;
        self.connectAlertView.centerX = self.width / 2;
        self.connectAlertView.bottom = self.bar.bottom;
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    if (!CGRectEqualToRect(_preRect, self.bounds)) {
        [self forceLayoutSubviews];
        _preRect = self.bounds;
    }
}

- (void)drawCorner
{
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:self.listView.bounds      byRoundingCorners:UIRectCornerBottomLeft | UIRectCornerBottomRight    cornerRadii:CGSizeMake(20, 20)];
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    maskLayer.frame = self.listView.bounds;
    maskLayer.path = maskPath.CGPath;
    self.listView.layer.mask = maskLayer;
}

- (CGFloat)listViewHeight
{
    CGFloat tableviewHeight = self.dataArray.count * cellHeight;
    return MIN(tableviewHeight, tableviewMaxHeight);
}

- (CGFloat)barHeight
{
   return self.listViewHeight + connectAlertViewHeight + titleLabelHeight + (IPHONE_X ? statusBarHeight : 0);
}

#pragma mark - <UITableViewDelegate, UITableViewDataSource>
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return cellHeight;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NTESConnectListViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    cell.delegate = self;
    NTESMicInfo *info = [self.dataArray objectAtIndex:indexPath.row];
    [cell refresh:info];
    return cell;
}

#pragma mark - NTESConnectListViewCellDelegate
- (void)onAcceptBtnPressedWithMicInfo:(NTESMicInfo *)micInfo
{
    if (self.delegate) {
        [self.delegate onAcceptBtnPressedWithMicInfo:micInfo];
    }
}

- (void)onRejectBtnPressedWithMicInfo:(NTESMicInfo *)micInfo
{
    if (self.delegate) {
        [self.delegate onRejectBtnPressedWithMicInfo:micInfo];
    }
}

#pragma mark - NTESConnectAlertViewDelegate
-(void)onShowConnectListBtnPressed:(UIButton *)button
{
    if (self.listViewPushed) {
        [self dismissListView];
    }
    else{
        [self showListView];
    }
}

#pragma mark - Get
- (UIView *)bar
{
    if (!_bar) {
        UIView * bar = [[UIView alloc]initWithFrame:CGRectZero];
        _bar = bar;
        [self addSubview:_bar];
    }
    return _bar;
}

- (UILabel *)titleLable
{
    if (!_titleLable)
    {
        UILabel * titleLabel = [[UILabel alloc] init];
        [titleLabel setTextColor:[UIColor whiteColor]];
        [titleLabel setTextAlignment:NSTextAlignmentCenter];
        titleLabel.font = [UIFont systemFontOfSize:15];
        [titleLabel setText:@"test1"];
        titleLabel.backgroundColor = UIColorFromRGBA(0x1D1D24, 0.9);
        _titleLable = titleLabel;        
        [self.bar addSubview:_titleLable];
    }
    return _titleLable;
}

- (UIView *)coverView
{
    if (!_coverView) {
        UIView * coverView = [[UIView alloc]initWithFrame:CGRectZero];
        coverView.backgroundColor = UIColorFromRGBA(0x1D1D24, 0.9);
        _coverView = coverView;
        [self.bar addSubview:coverView];
    }
    return _coverView;
}

- (UITableView *)listView
{
    if (!_listView) {
        UITableView *tableview = [[UITableView alloc]initWithFrame:CGRectZero];
        tableview.delegate = self;
        tableview.dataSource = self;
        [tableview registerClass:[NTESConnectListViewCell class] forCellReuseIdentifier:@"cell"];
        tableview.backgroundColor = UIColorFromRGBA(0x1D1D24, 0.9);
        [tableview setSeparatorColor:UIColorFromRGB(0xE2E2E2)];
        [tableview setTableFooterView:[[UIView alloc] initWithFrame:CGRectZero]];
        tableview.separatorStyle = UITableViewCellSeparatorStyleNone;
        _listView = tableview;
        [self.bar addSubview:_listView];
    }
    return _listView;
}

- (NTESConnectAlertView *)connectAlertView
{
    if (!_connectAlertView) {
        _connectAlertView = [[NTESConnectAlertView alloc]init];
        _connectAlertView.delegate = self;
        [self.bar addSubview:_connectAlertView];
    }
    return _connectAlertView;
}

@end
