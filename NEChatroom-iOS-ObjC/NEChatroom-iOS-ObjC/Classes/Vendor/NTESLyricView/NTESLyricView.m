//
//  NTESLyricView.m
//  NEChatroom-iOS-Objc
//
//  Created by WenchaoD on 2020/1/20.
//  Copyright © 2017年 Netease. All rights reserved.
//

#import "NTESLyricView.h"
#import "NTESLyricFrame.h"
#import "NTESLyricCell.h"

#define kRowHeight 26.0

static inline NSInteger binarySearch(NSArray<NTESLyricFrame *> *frames, NSInteger left, NSInteger right, NSTimeInterval target) {
    if (!frames.count) return NSNotFound;
    while (left <= right) {
        NSInteger mid = left + (right-left)/2;
        NSInteger midVal = frames[mid].time;
        if (midVal == target) return mid;
        if (midVal < target) left = mid + 1;
        else right = mid - 1;
    }
    right = MAX(right, 0);
    NSInteger res = right < frames.count ? right : NSNotFound;
    return res;
}

@interface NTESLyricView () <UITableViewDataSource,UITableViewDelegate>

// 内容区域
@property (nonatomic, strong) UIView *contentView;

// 列表视图
@property (nonatomic, strong) UITableView *tableView;

// 当前滚动的位置
@property (nonatomic, assign) NSInteger currIndex;

// 当前歌词位置
@property (nonatomic, assign) NSInteger currLyricIndex;

// 正在滚动的目标位置
@property (nonatomic, assign) NSInteger targetingIndex;

// 刷新可见区域的UI
- (void)updateProgressForVisibleRows;

@end

@implementation NTESLyricView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.contentView = [[UIView alloc] initWithFrame:self.bounds];
        self.contentView.backgroundColor = UIColor.clearColor;
        [self addSubview:self.contentView];
        
        self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        self.tableView.dataSource = self;
        self.tableView.delegate = self;
        self.tableView.rowHeight = kRowHeight;
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        self.tableView.showsVerticalScrollIndicator = NO;
        self.tableView.backgroundColor = UIColor.clearColor;
        self.tableView.allowsSelection = NO;

        if (@available(iOS 11.0, *)) {
            self.tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
        [self.tableView registerClass:NTESLyricCell.class forCellReuseIdentifier:@"cell"];
        [self.contentView addSubview:self.tableView];
    }
    return self;
}

- (void)dealloc{
    self.tableView.dataSource = nil;
    self.tableView.delegate = nil;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.contentView.frame = self.bounds;
    self.tableView.frame = self.contentView.bounds;
    CGFloat inset = self.tableView.frame.size.height/2.0 - kRowHeight/2.0;
    self.tableView.contentInset = UIEdgeInsetsMake(inset, 0, inset, 0);
    self.tableView.contentOffset = CGPointMake(0, -self.tableView.contentInset.top);
}

- (void)reloadData {
    [self.tableView reloadData];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.frames.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NTESLyricFrame *frame = self.frames[indexPath.row];
    NTESLyricCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    cell.textLabel.text = frame.content;
    cell.progress = indexPath.row == self.currLyricIndex ? 0 : 1.0;
    return cell;
}

- (void)setFrames:(NSArray *)frames {
    _frames = frames;
    [self.tableView reloadData];
    [self.tableView layoutIfNeeded];
    [self reset];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat middleInTable = scrollView.contentOffset.y + scrollView.frame.size.height*0.5;
    self.currIndex = [self.tableView indexPathForRowAtPoint:CGPointMake(self.tableView.bounds.size.width/2.0, middleInTable)].row;
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {
    CGFloat targetItem = round(targetContentOffset->y/self.tableView.rowHeight);
    targetContentOffset->y = targetItem * self.tableView.rowHeight;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    self.targetingIndex = -1;
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    self.targetingIndex = -1;
}

- (void)setCurrentTime:(uint64_t)currentTime {
    NSInteger targetIndex;
    if (_currentTime < currentTime) {
        targetIndex = binarySearch(self.frames, self.currLyricIndex, self.frames.count-1, currentTime);
    } else {
        targetIndex = binarySearch(self.frames, 0, self.currLyricIndex, currentTime);
    }
//    NSLog(@"currTime:%@, newTime:%@, targetIndex:%@", @(_currentTime), @(currentTime), @(targetIndex));
    _currentTime = currentTime;
    if (self.tableView.isDragging || self.tableView.isDecelerating) {
        return;
    }
    if (targetIndex == NSNotFound || targetIndex == self.targetingIndex) {
        return;
    }
    self.targetingIndex = targetIndex;
    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:targetIndex inSection:0] atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
    if (targetIndex != self.currLyricIndex) {
        NSIndexPath *oldIndexPath = [NSIndexPath indexPathForRow:self.currLyricIndex inSection:0];
        NSIndexPath *newIndexPath = [NSIndexPath indexPathForRow:targetIndex inSection:0];
        self.currLyricIndex = targetIndex;
        NTESLyricCell *oldCell = [self.tableView cellForRowAtIndexPath:oldIndexPath];
        NTESLyricCell *newCell = [self.tableView cellForRowAtIndexPath:newIndexPath];
        oldCell.progress = 1;
        newCell.progress = 0;
    }
}

- (void)updateProgressForVisibleRows {
    CGFloat middleInTable = self.tableView.contentOffset.y + self.tableView.frame.size.height*0.5;
    [self.tableView.visibleCells enumerateObjectsUsingBlock:^(__kindof UITableViewCell * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        CGFloat distance = ABS(obj.center.y-middleInTable);
        CGFloat progress = MIN(distance/kRowHeight, 1.0);
        NTESLyricCell *cell = obj;
        cell.progress = progress;
    }];
}

- (void)reset {
    _currLyricIndex = 0;
    _currentTime = 0;
    self.tableView.contentOffset = CGPointMake(0, -self.tableView.contentInset.top);
}

@end
