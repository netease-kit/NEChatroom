//
//  NTESCreateRoomTitleButton.m
//  NEChatroom-iOS-ObjC
//
//  Created by vvj on 2021/2/2.
//  Copyright © 2021 netease. All rights reserved.
//

#import "NTESCreateRoomTitleButton.h"

@interface NTESCreateRoomTitleButton ()
@property (nonatomic, strong) NSString *imageName;
@property (nonatomic, strong) NSString *content;

@property (nonatomic, strong) UIImageView *headImage;
@property (nonatomic, strong) UILabel *contentLable;

@end

@implementation NTESCreateRoomTitleButton

//- (instancetype)initWithFrame:(CGRect)frame {
//    if ([super initWithFrame:frame]) {
//        [self ntes_setupViews];
//    }
//    return self;
//}

- (instancetype)initWithImage:(NSString *)imageName content:(NSString *)content {
    if (self = [super init]) {
        _imageName = imageName;
        _content = content;
        [self ntes_setupViews];

    }
    return self;
}


- (void)ntes_setupViews {
    [self addSubview:self.headImage];
    [self addSubview:self.contentLable];

    
    [self.contentLable mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self);
        make.centerX.equalTo(self).offset(20);
    }];
    
    [self.headImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.contentLable);
        make.size.mas_equalTo(CGSizeMake(16, 16));
        make.right.equalTo(self.contentLable.mas_left).offset(-4);
    }];
    
}

- (void)setLableFont:(UIFont *)lableFont {
    self.contentLable.font = lableFont;
}

- (void)setLeftMargin:(CGFloat)leftMargin imageSize:(CGSize)imageSize {

    [self.headImage mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self);
        make.size.mas_equalTo(imageSize);
        make.left.equalTo(self).offset(leftMargin);
    }];
    
    [self.contentLable mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.headImage);
        make.left.equalTo(self.headImage.mas_right).offset(4);
    }];
    
}


- (void)setContent:(NSString *)content {
    self.contentLable.text = content;
}
#pragma mark - lazyMethod
- (UIImageView *)headImage {
    if (!_headImage) {
        _headImage = [NTESViewFactory createImageViewFrame:CGRectZero imageName:self.imageName];
    }
    return _headImage;
}

- (UILabel *)contentLable {
    if (!_contentLable) {
        _contentLable = [NTESViewFactory createLabelFrame:CGRectZero title:self.content textColor:UIColor.whiteColor textAlignment:NSTextAlignmentLeft font:TextFont_16];
    }
    return _contentLable;
}

@end
