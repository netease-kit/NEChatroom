//
//  NTESActionSheetNavigationController.h
//  NEChatroom-iOS-ObjC
//
//  Created by Wenchao Ding on 2021/1/27.
//  Copyright © 2021 netease. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NTESActionSheetNavigationController : UINavigationController

/**
 是否点击外侧消失
 */
@property (nonatomic, assign) BOOL dismissOnTouchOutside;

@end


NS_ASSUME_NONNULL_END
