// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import <UIKit/UIKit.h>

@interface FUSlider : UISlider

/// 零点是否在中间，默认为NO
@property (nonatomic, assign, getter=isBidirection) BOOL bidirection;

@end
