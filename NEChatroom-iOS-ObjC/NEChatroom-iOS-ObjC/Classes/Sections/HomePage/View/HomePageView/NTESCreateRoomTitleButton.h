//
//  NTESCreateRoomTitleButton.h
//  NEChatroom-iOS-ObjC
//
//  Created by vvj on 2021/2/2.
//  Copyright © 2021 netease. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface NTESCreateRoomTitleButton : UIButton

- (instancetype)initWithImage:(NSString *)imageName content:(NSString *)content;

- (void)setLableFont:(UIFont *)lableFont;
//设置内容
- (void)setContent:(NSString *)content;

- (void)setLeftMargin:(CGFloat)leftMargin imageSize:(CGSize)imageSize;
@end

NS_ASSUME_NONNULL_END
