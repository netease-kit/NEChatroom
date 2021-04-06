//
//  NTESLiveListMainViewController.h
//  NEChatroom-iOS-ObjC
//
//  Created by vvj on 2021/2/2.
//  Copyright © 2021 netease. All rights reserved.
//

#import "NTESBaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface NTESLiveListMainViewController : NTESBaseViewController

/// 初始化方法
/// @param selectType 选择类型selectType
- (instancetype)initWithSelectType:(NTESCreateRoomType)selectType;

@end

NS_ASSUME_NONNULL_END
