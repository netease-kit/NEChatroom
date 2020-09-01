//
//  NTESLiveChatView.h
//  NIMLiveDemo
//
//  Created by chris on 16/3/28.
//  Copyright © 2016年 Netease. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol NTESLiveChatViewDelegate <NSObject>

- (void)onTapChatView:(CGPoint)point;

@end

@interface NTESLiveChatView : UIView

@property (nonatomic,strong) UITableView *tableView;

@property (nonatomic,weak) id<NTESLiveChatViewDelegate> delegate;

- (void)addMessages:(NSArray<NIMMessage *> *)messages;

@end
