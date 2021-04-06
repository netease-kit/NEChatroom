//
//  NTESBackgroundMusicCell.h
//  NEChatroom-iOS-ObjC
//
//  Created by Wenchao Ding on 2021/1/29.
//  Copyright © 2021 netease. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Lottie.h"

NS_ASSUME_NONNULL_BEGIN

@interface NTESBackgroundMusicCell : UITableViewCell

/**
 序号
 */
@property (nonatomic, strong) UILabel *indexLabel;

/**
 播放动效
 */
@property (nonatomic, strong) LOTAnimationView *playingAnimationView;



@end

NS_ASSUME_NONNULL_END
