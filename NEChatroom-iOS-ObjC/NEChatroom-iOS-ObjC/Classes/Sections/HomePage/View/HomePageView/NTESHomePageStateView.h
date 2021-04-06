//
//  NTESHomePageStateView.h
//  NERtcAudioChatroom
//
//  Created by Netease on 2019/3/4.
//  Copyright © 2019年 netease. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, NTESHomePageStateViewMode){
    NTESHomePageStateViewEmpty = 0,
    NTESHomePageStateViewNetworkError,
    NTESHomePageStateViewHidden,
};


@protocol NTESHomePageStateDelegate <NSObject>

- (void)stateViewDidReceiveRetryAction;

@end

@interface NTESHomePageStateView : UIView

@property (nonatomic, weak) id <NTESHomePageStateDelegate> delegate;
@property (nonatomic, assign) NTESHomePageStateViewMode mode;

@end

NS_ASSUME_NONNULL_END
