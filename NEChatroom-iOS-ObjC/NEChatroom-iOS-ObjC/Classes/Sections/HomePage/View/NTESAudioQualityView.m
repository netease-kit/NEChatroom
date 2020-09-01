//
//  NTESAudioQualityView.m
//  NERtcAudioChatroom
//
//  Created by Netease on 2019/5/14.
//  Copyright © 2019 netease. All rights reserved.
//

#import "NTESAudioQualityView.h"
#import "UIView+NTES.h"

typedef void(^NTESAudioQualityBarBlock)(void);

@interface NTESAudioQualityModel : NSObject

@property (nonatomic, copy) NSString *imageName;
@property (nonatomic, copy) NSString *content;
@property (nonatomic, readonly) NSAttributedString *attrContent;
@end

@interface NTESAudioQualityBar : UIView <UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) UILabel *titleLab;
@property (nonatomic, strong) UITableView *list;
@property (nonatomic, strong) UIButton *sureBtn;
@property (nonatomic, strong) NSMutableArray *datas;
@property (nonatomic, assign) NSInteger selectedIndex;
@property (nonatomic, copy) NTESAudioQualityBarBlock sureBlock;
@property (nonatomic, weak) id<NTESAudioQualityViewDelegate> delegate;
@end

@interface NTESAudioQualityView ()
@property (nonatomic, assign) BOOL show;
@property (nonatomic, strong) NTESAudioQualityBar *bar;
@end

@implementation NTESAudioQualityView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = UIColorFromRGBA(0x606060, 1.0);
        _bar = [[NTESAudioQualityBar alloc] initWithFrame:frame];
        _bar.height = 340.0;
        _bar.clipsToBounds = YES;
        _bar.layer.cornerRadius = 8.0;
        __weak typeof(self) weakSelf = self;
        _bar.sureBlock = ^{
            [weakSelf dismiss];
        };
        [self addSubview:_bar];
        [self addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    if (_show && CGRectEqualToRect(self.frame, self.superview.bounds)) {
        self.frame = self.superview.bounds;
        _bar.frame = CGRectMake(0, self.height - _bar.height + 8.0, self.width, _bar.height);
    }
}

- (void)showOnView:(UIView *)view {
    if (_show) {
        return;
    }
    _show = YES;
    self.frame = view.bounds;
    _bar.frame = CGRectMake(0, self.height, self.width, _bar.height);
    [view addSubview:self];
    __weak typeof(self) weakSelf = self;
    [UIView animateWithDuration:0.25 animations:^{
        weakSelf.bar.top = weakSelf.height - weakSelf.bar.height + 8.0;
    }];
}

- (void)dismiss {
    if (!_show) {
        return;
    }
    _show = NO;
    __weak typeof(self) weakSelf = self;
    [UIView animateWithDuration:0.25 animations:^{
        weakSelf.bar.top = weakSelf.bottom;
    } completion:^(BOOL finished) {
        [weakSelf removeFromSuperview];
    }];
}

- (void)setDelegate:(id<NTESAudioQualityViewDelegate>)delegate {
    _delegate = delegate;
    _bar.delegate = delegate;
}

@end

@implementation NTESAudioQualityBar

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setupDatas];
        _selectedIndex = 1;
        self.backgroundColor = [UIColor whiteColor];
        [self addSubview:self.titleLab];
        [self addSubview:self.list];
        [self addSubview:self.sureBtn];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    _titleLab.frame = CGRectMake(0, 0, self.width, 80.0);
    _list.frame = CGRectMake(0, _titleLab.bottom, self.width, 178.0);
    _sureBtn.frame = CGRectMake(0, _list.bottom + 14.0, _list.width, 60.0);
}

- (void)setupDatas {
    
    NSArray *tmp = @[
                     @[@"aq_normal", @"普通语音  普通音质，流畅度佳"],
                     @[@"aq_hd", @"高清语音  音质较好，流畅度较好"],
                     @[@"aq_music_hd", @"高清音乐  音质最佳，对网络要求较高"]
                    ];
    
    _datas = [NSMutableArray array];
    for (NSArray *obj in tmp) {
        NTESAudioQualityModel *model = [[NTESAudioQualityModel alloc] init];
        model.imageName = obj[0];
        model.content = obj[1];
        [_datas addObject:model];
    }
}

- (void)sureAction:(UIButton *)btn {
    if (_sureBlock) {
        _sureBlock();
    }
    if (_delegate && [_delegate respondsToSelector:@selector(didSureCreateRoomWithAudioQuality:)]) {
        [_delegate didSureCreateRoomWithAudioQuality:_selectedIndex];
    }
}

#pragma mark - <UITableViewDelegate, UITableViewDataSource>
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _datas.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:@"cell"];
        cell.backgroundColor = [UIColor clearColor];
        if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
            [tableView setSeparatorInset:UIEdgeInsetsMake(0, 38, 0, 38)];
        }
        if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
            [tableView setLayoutMargins:UIEdgeInsetsMake(0, 38, 0, 38)];
        }
    }
    NTESAudioQualityModel *model = _datas[indexPath.row];
    cell.textLabel.attributedText = model.attrContent;
    cell.imageView.image = [UIImage imageNamed:model.imageName];
    if (_selectedIndex == indexPath.row) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.row != _selectedIndex) {
        NSIndexPath *lastIndexPath = [NSIndexPath indexPathForRow:_selectedIndex inSection:0];
        UITableViewCell *lastCell = [tableView cellForRowAtIndexPath:lastIndexPath];
        lastCell.accessoryType = UITableViewCellAccessoryNone;
        
        UITableViewCell *curCell = [tableView cellForRowAtIndexPath:indexPath];
        curCell.accessoryType = UITableViewCellAccessoryCheckmark;
        _selectedIndex = indexPath.row;
    }
}

- (UILabel *)titleLab {
    if (!_titleLab) {
        _titleLab = [[UILabel alloc] init];
        _titleLab.font = [UIFont systemFontOfSize:22.0];
        _titleLab.textAlignment = NSTextAlignmentCenter;
        _titleLab.text = @"房间音质";
    }
    return _titleLab;
}

- (UIButton *)sureBtn {
    if (!_sureBtn) {
        _sureBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _sureBtn.backgroundColor = UIColorFromRGB(0x3f82ff);
        _sureBtn.titleLabel.font = [UIFont systemFontOfSize:17.0];
        [_sureBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_sureBtn setTitle:@"立即创建" forState:UIControlStateNormal];
        [_sureBtn addTarget:self action:@selector(sureAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _sureBtn;
}

- (UITableView *)list {
    if (!_list) {
        _list = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 100, 100) style:UITableViewStylePlain];
        _list.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
        _list.bounces = NO;
        _list.showsHorizontalScrollIndicator = NO;
        _list.showsVerticalScrollIndicator = NO;
        _list.rowHeight = 60.0;
        _list.dataSource = self;
        _list.delegate = self;
    }
    return _list;
}

@end

@interface NTESAudioQualityModel ()
@property (nonatomic, copy) NSMutableAttributedString *attrContent;
@end

@implementation NTESAudioQualityModel

- (void)setContent:(NSString *)content {
    _content = content;
    _attrContent = [[NSMutableAttributedString alloc] initWithString:content];
    NSRange first = [content rangeOfString:@" "];
    if (first.location != NSNotFound) {
        [_attrContent addAttribute:NSForegroundColorAttributeName
                             value:UIColorFromRGB(0x333333)
                             range:NSMakeRange(0, first.location)];
        [_attrContent addAttribute:NSFontAttributeName
                            value:[UIFont systemFontOfSize:17.0]
                            range:NSMakeRange(0, first.location)];
        
        if (first.location < content.length) {
            NSRange second = NSMakeRange(first.location, content.length - first.location);
            [_attrContent addAttribute:NSForegroundColorAttributeName
                                 value:UIColorFromRGB(0xaeaeae)
                                 range:second];
            [_attrContent addAttribute:NSFontAttributeName
                                 value:[UIFont systemFontOfSize:14.0]
                                 range:second];
        }
    }
}

- (NSAttributedString *)attrContent {
    return _attrContent;
}

@end
