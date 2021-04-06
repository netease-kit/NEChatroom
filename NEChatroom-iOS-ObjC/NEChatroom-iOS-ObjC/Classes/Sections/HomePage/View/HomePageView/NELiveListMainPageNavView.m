//
//  NELiveListMainPageNavView.h
//  NEChatroom-iOS-ObjC
//
//  Created by vvj on 2021/2/2.
//  Copyright © 2021 netease. All rights reserved.
//

#import "NELiveListMainPageNavView.h"
#import "NTESSegmentCtrl.h"

@interface NELiveListMainPageNavView ()

@property (nonatomic, strong) NSArray *titleArray;
@property (nonatomic, strong) NTESSegmentCtrl *segmentCtrl;
@property(nonatomic, strong) UIButton *backButton;

@end

@implementation NELiveListMainPageNavView

- (void)ntes_setupViews {
    [super ntes_setupViews];
    
    [self addSubview:self.segmentCtrl];
    [self addSubview:self.backButton];

    [self.backButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(12);
        make.bottom.mas_equalTo(-12);
        make.size.mas_equalTo(CGSizeMake(60, 20));
    }];
    self.segmentCtrl.frame = CGRectMake((UIScreenWidth-160)/2, self.bounds.size.height-42, 160, 42);
    self.segmentCtrl.titleArray = self.titleArray;
}

- (void)ntes_bindViewModel {
    [super ntes_bindViewModel];
    @weakify(self)

    [[self.backButton rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
        @strongify(self)
        [self.backSubject sendNext:nil];
    }];
}

- (void)setSelectIndex:(NSInteger)selectIndex {
    _selectIndex = selectIndex;
    self.segmentCtrl.sIndex = selectIndex;
}

#pragma mark - Lazy

- (NTESSegmentCtrl *)segmentCtrl {
    if (!_segmentCtrl) {
        @weakify(self)
        _segmentCtrl = [[NTESSegmentCtrl alloc]initWithFrame:CGRectZero];
        _segmentCtrl.bottomLineType = BottomLineTypeShortestFont;
        _segmentCtrl.fontSize = 16;
        _segmentCtrl.selectTextFont = Font_Size(@"PingFangSC-Medium", 16);
        _segmentCtrl.normalLabelColor = UIColorFromRGB(0x999999);;
        _segmentCtrl.selectLabelColor = UIColorFromRGB(0x222222);
        _segmentCtrl.lineViewColor = UIColorFromRGB(0x337EFF);
        _segmentCtrl.lineViewHeight = 3;
        _segmentCtrl.isShowLineBottomRoundedCorners = YES;
        _segmentCtrl.lineBottomDistanceInterval = 0;
        _segmentCtrl.clickBlock = ^(NSInteger selectIndex) {
            @strongify(self)
            [self.selectMenuSubject sendNext:@(selectIndex)];
        };
    }
    return _segmentCtrl;
}

- (NSArray *)titleArray {
    if (!_titleArray) {
        _titleArray = @[@"语聊",@"KTV"];
    }
    return _titleArray;
}

- (UIButton *)backButton {
    if (!_backButton) {
        _backButton = [NTESViewFactory createBtnFrame:CGRectZero title:nil bgImage:nil selectBgImage:nil image:@"nav_back_icon" target:nil action:nil];
        
        [_backButton setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 32)];
    }
    return _backButton;
}

@end
