//
//  NTESMoreItem.m
//  NEChatroom-iOS-ObjC
//
//  Created by Wenchao Ding on 2021/1/27.
//  Copyright © 2021 netease. All rights reserved.
//

#import "NTESMoreItem.h"

@implementation NTESMoreItem

+ (instancetype)itemWithTitle:(NSString *)title onImage:(UIImage *)onImage offImage:(nullable UIImage *)offImage tag:(NSInteger)tag {
    NTESMoreItem *item = [[NTESMoreItem alloc] init];
    item.title = title;
    item.onImage = onImage;
    item.offImage = offImage;
    item.tag = tag;
    return item;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.on = YES;
    }
    return self;
}

- (UIImage *)currentImage {
    return self.on ? self.onImage : self.offImage;
}

@end
