//
//  NTESAudioPanelView.h
//  NERtcAudioChatroom
//
//  Created by He on 2019/5/29.
//  Copyright © 2019 netease. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, NTESButtonType) {
    NTESButtonTypeMusic1        = 0,
    NTESButtonTypeMusic2        = 1,
    NTESButtonTypeMusicEffect1  = 2,
    NTESButtonTypeMusicEffect2  = 3,
};

typedef NS_ENUM(NSUInteger, NTESValueChangeType) {
   NTESValueChangeTypeMusicVolumn   = 0,
    NTESValueChangeTypeMusicEffect  = 1,
};

@protocol NTESAudioPanelViewDelegate <NSObject>
@optional
- (void)onButtonSelected:(NTESButtonType)type;
- (void)onValueChangeOfType:(NTESValueChangeType)type value:(CGFloat)value;
@end

@interface NTESAudioPanelView : UIView


@property(nonatomic,weak) id<NTESAudioPanelViewDelegate> delegate;

- (void)setMusicButtonSelectedAtIndex:(NSInteger)index;
@end

NS_ASSUME_NONNULL_END
