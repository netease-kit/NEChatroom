//
//  NTESHomeTableVIewCell.h
//  NEChatroom-iOS-ObjC
//
//  Created by vvj on 2021/2/1.
//  Copyright © 2021 netease. All rights reserved.
//
#import "NTESBaseTabViewCell.h"

@interface NTESBaseTabViewCell()

@property (nonatomic, readwrite, strong) id model;
@property (nonatomic,strong) UIView *bottomView;//底部默认线条

@end

@implementation NTESBaseTabViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier model:(id<NTESBaseModelProtocol>)model {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _model = model;
        self.contentView.backgroundColor = [UIColor whiteColor];
        [self ntes_setupViews];
        [self ntes_bindViewModel];
    }
    return self;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    return [self initWithStyle:style reuseIdentifier:reuseIdentifier model:nil];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    return [self initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil model:nil];
}

- (void)ntes_setupViews {
    [self.contentView addSubview:self.bottomView];
    [self.bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(0.5);
        make.bottom.right.equalTo(self);
        make.left.equalTo(self.contentView).offset(15);
    }];
}

- (void)ntes_bindViewModel {
    
}

- (void)setSplitLineStyle:(BOOL)splitLineStyle {
    if (splitLineStyle) {
        self.bottomView.hidden = YES;
    }else {
        self.bottomView.hidden = NO;
    }
}

#pragma mark === lazyMethod
- (UIView *)bottomView {
    if (!_bottomView) {
        _bottomView = [[UIView alloc]init];
//        _bottomView.backgroundColor = FBDefaultLineColor;
        _bottomView.hidden = YES;
    }
    return _bottomView;
}

@end
