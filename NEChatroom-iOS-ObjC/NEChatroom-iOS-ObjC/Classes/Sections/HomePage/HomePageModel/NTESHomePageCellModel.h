//
//  NTESHomePageCellModel.h
//  NEChatroom-iOS-ObjC
//
//  Created by vvj on 2021/2/1.
//  Copyright © 2021 netease. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NTESHomePageCellModel : NSObject
//主标题
@property (nonatomic, copy) NSString *title;
//副标题
@property (nonatomic, copy) NSString *subtitle;
//cell背景图片名称
@property (nonatomic, copy) NSString *bgImageName;

@end

NS_ASSUME_NONNULL_END
