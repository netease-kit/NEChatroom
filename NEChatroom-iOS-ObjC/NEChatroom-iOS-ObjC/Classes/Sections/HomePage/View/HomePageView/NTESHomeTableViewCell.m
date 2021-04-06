//
//  NTESHomeTableVIewCell.m
//  NEChatroom-iOS-ObjC
//
//  Created by vvj on 2021/2/1.
//  Copyright © 2021 netease. All rights reserved.
//

#import "NTESHomeTableViewCell.h"
#import "NTESHomePageCellModel.h"
#import "UIImageView+CornerRadius.h"

@interface NTESHomeTableViewCell ()
@property (nonatomic, strong) UIImageView *cellBgImageView;
@property (nonatomic, strong) UIImageView *arrowImageView;
@property (nonatomic, strong) UILabel *titleNameLable;
@property (nonatomic, strong) UILabel *subtitleNameLable;

@end

@implementation NTESHomeTableViewCell

+ (instancetype)loadHomePageCellWithTableView:(UITableView *)tableView {
    static NSString *cellId = @"NTESHomeTableViewCell";
    NTESHomeTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (!cell) {
        cell = [[NTESHomeTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (void)ntes_setupViews {
    [self.contentView addSubview:self.cellBgImageView];
    [self.cellBgImageView addSubview:self.arrowImageView];
    [self.cellBgImageView addSubview:self.titleNameLable];
    [self.cellBgImageView addSubview:self.subtitleNameLable];
    
    [self.cellBgImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView).offset(8);
        make.bottom.equalTo(self.contentView).offset(-4);
        make.left.equalTo(self.contentView).offset(20);
        make.right.equalTo(self.contentView).offset(-20);

    }];
    
    [self.titleNameLable mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.cellBgImageView).offset(24);
        make.left.equalTo(self.cellBgImageView).offset(20);
        make.right.equalTo(self.cellBgImageView).offset(-20);
    }];
    
    [self.arrowImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.titleNameLable);
        make.right.equalTo(self.cellBgImageView).offset(-20);
        make.size.mas_equalTo(CGSizeMake(16, 16));
    }];
    
    [self.subtitleNameLable mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.titleNameLable.mas_bottom).offset(6);
        make.left.right.equalTo(self.titleNameLable);
    }];
}

- (void)setHomePageModel:(NTESHomePageCellModel *)homePageModel {
    _homePageModel = homePageModel;
    self.titleNameLable.text = homePageModel.title;
    self.subtitleNameLable.text = homePageModel.subtitle;
    self.cellBgImageView.image = [UIImage imageNamed:homePageModel.bgImageName];
}
#pragma mark =====LazyMethod
- (UIImageView *)cellBgImageView {
    if (!_cellBgImageView) {
        _cellBgImageView = [[UIImageView alloc]init];
       [_cellBgImageView zy_cornerRadiusAdvance:8 rectCornerType:UIRectCornerAllCorners];

    }
    return _cellBgImageView;
}

- (UIImageView *)arrowImageView {
    if (!_arrowImageView) {
        _arrowImageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"homePage_clickMore_icon"]];
    }
    return _arrowImageView;
}

- (UILabel *)titleNameLable {
    if (!_titleNameLable) {
        _titleNameLable = [NTESViewFactory createLabelFrame:CGRectZero title:@"语音聊天室" textColor:UIColor.whiteColor textAlignment:NSTextAlignmentLeft font:Font_Size(@"PingFangSC-Medium", 18)];
    }
    return _titleNameLable;
}

- (UILabel *)subtitleNameLable {
    if (!_subtitleNameLable) {
        _subtitleNameLable = [NTESViewFactory createLabelFrame:CGRectZero title:@"语音聊天室" textColor:UIColor.whiteColor textAlignment:NSTextAlignmentLeft font:TextFont_14];
    }
    return _subtitleNameLable;
}

@end
