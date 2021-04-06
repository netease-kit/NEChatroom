//
//  NTESLyricView.h
//  NEChatroom-iOS-Objc
//
//  Created by WenchaoD on 2020/1/20.
//  Copyright © 2017年 Netease. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NTESLyricFrame.h"

@interface NTESLyricView : UIView

/**
 当前时间(s)
 */
@property (nonatomic, assign) uint64_t currentTime;

/**
 保存所有歌词帧
 */
@property (nonatomic, copy) NSArray<NTESLyricFrame *> *frames;


@end
