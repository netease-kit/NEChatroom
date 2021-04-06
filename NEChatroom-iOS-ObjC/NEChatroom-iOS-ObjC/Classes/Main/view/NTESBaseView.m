//
//  NTESBaseView.m
//  NEChatroom-iOS-ObjC
//
//  Created by vvj on 2021/1/28.
//  Copyright © 2021 netease. All rights reserved.
//

#import "NTESBaseView.h"

@interface NTESBaseView()

@property (nonatomic, readwrite, strong) id model;

@end

@implementation NTESBaseView

- (instancetype)initWithFrame:(CGRect)frame model:(id<NTESBaseModelProtocol>)model {
    self = [super initWithFrame:frame];
    if (self) {
        _model = model;
        self.backgroundColor = [UIColor whiteColor];
        [self ntes_setupViews];
        [self ntes_bindViewModel];
    }
    return self;
}


- (instancetype)init {
    return [self initWithFrame:CGRectZero model:nil];
}

- (instancetype)initWithFrame:(CGRect)frame {
    return [self initWithFrame:frame model:nil];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    return [self initWithFrame:CGRectZero model:nil];
}

- (void)ntes_setupViews {
    
}

- (void)ntes_bindViewModel {
    
}

@end
