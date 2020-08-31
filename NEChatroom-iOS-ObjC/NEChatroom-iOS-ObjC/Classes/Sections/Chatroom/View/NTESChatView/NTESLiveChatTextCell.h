//
//  NTESLiveChatTextCell.h
//  NIMLiveDemo
//
//  Created by chris on 16/3/28.
//  Copyright © 2016年 Netease. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NTESMessageModel.h"

@interface NTESLiveChatTextCell : UITableViewCell

- (void)refresh:(NTESMessageModel *)model;

@end
