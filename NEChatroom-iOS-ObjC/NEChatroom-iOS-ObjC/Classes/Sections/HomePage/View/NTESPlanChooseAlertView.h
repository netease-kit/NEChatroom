//
//  NTESPlanChooseAlertView.h
//  NEChatroom-iOS-ObjC
//
//  Created by vvj on 2021/1/19.
//  Copyright © 2021 netease. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@protocol NTESPlanChooseDelegate <NSObject>

- (void)planChooseResult:(NSInteger)selectIndex;

@end

@interface NTESPlanChooseAlertView : UIView

@property (nonatomic, weak) id<NTESPlanChooseDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
