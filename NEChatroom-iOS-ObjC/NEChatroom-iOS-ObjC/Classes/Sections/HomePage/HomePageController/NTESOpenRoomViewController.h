//
//  NTESOpenRoomViewController.h
//  NEChatroom-iOS-ObjC
//
//  Created by vvj on 2021/1/28.
//  Copyright © 2021 netease. All rights reserved.
//

#import "NTESBaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface NTESOpenRoomViewController : NTESBaseViewController

/**
 根据类型初始化房间
 @param roomType 房间类型(语聊/KTV)
 */
- (instancetype)initWithRoomType:(NTESCreateRoomType)roomType;


@end

NS_ASSUME_NONNULL_END
