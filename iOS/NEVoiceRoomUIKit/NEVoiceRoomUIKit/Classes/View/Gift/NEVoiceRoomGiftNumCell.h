//// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface NEVoiceRoomGiftNumCell : UITableViewCell

+ (NEVoiceRoomGiftNumCell *)cellWithTableView:(UITableView *)tableView
                                    indexPath:(NSIndexPath *)indexPath
                                currentNumber:(NSString *)number
                                        datas:(NSArray *)datas;

@end

NS_ASSUME_NONNULL_END
