//
//  NTESSlideView.h
//  NEChatroom-iOS-ObjC
//
//  Created by vvj on 2021/1/28.
//  Copyright © 2021 netease. All rights reserved.
//

#import "NTESBaseView.h"

NS_ASSUME_NONNULL_BEGIN
@protocol NTESCreateRoomDelegate <NSObject>

- (void)createRoomResult:(NTESCreateRoomType)roomType;

@end

@interface NTESCreateRoomNameView : NTESBaseView

@property (nonatomic, weak) id<NTESCreateRoomDelegate> delegate;

@property (nonatomic, assign) NTESCreateRoomType roomType;
//获取聊天室名称
- (NSString *)getRoomName;

@end

NS_ASSUME_NONNULL_END
