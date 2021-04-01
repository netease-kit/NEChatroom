//
//  NTESNoticePopView.h
//  NEChatroom-iOS-ObjC
//
//  Created by vvj on 2021/2/4.
//  Copyright © 2021 netease. All rights reserved.
//

#import "NTESBaseView.h"

NS_ASSUME_NONNULL_BEGIN


typedef void (^CallBack)(NSString *password,BOOL isCancel);

@interface NTESNoticePopView : NTESBaseView


@property(nonatomic, copy) CallBack callBack;

@end

NS_ASSUME_NONNULL_END
