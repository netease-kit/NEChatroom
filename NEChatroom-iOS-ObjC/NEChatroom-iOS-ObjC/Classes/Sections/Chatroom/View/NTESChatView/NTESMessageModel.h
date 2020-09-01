//
//  NTESMessageModel.h
//  NIMLiveDemo
//
//  Created by chris on 16/3/28.
//  Copyright © 2016年 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, NTESMessageType) {
    NTESMessageNormal = 0,
    NTESMessageNotication,
};

@interface NTESMessageModel : NSObject

@property (nonatomic,strong) NIMMessage *message;

@property (nonatomic,assign) NTESMessageType type;

@property (nonatomic,assign) CGSize size;

@property (nonatomic,readonly) NSAttributedString *formatMessage;

- (void)caculate:(CGFloat)width;

@end
