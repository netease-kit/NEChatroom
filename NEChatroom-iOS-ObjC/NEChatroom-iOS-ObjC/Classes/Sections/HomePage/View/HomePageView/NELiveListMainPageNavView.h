//
//  NELiveListMainPageNavView.h
//  NEChatroom-iOS-ObjC
//
//  Created by vvj on 2021/2/2.
//  Copyright © 2021 netease. All rights reserved.
//

#import "NTESBaseView.h"


@interface NELiveListMainPageNavView : NTESBaseView

@property(nonatomic, strong) RACSubject *selectMenuSubject;
//@property(nonatomic, strong) RACSubject *screeningSubject;
@property(nonatomic, strong) RACSubject *backSubject;

@property(nonatomic, assign) NSInteger selectIndex;

/// 是否显示返回(默认不显示)
@property(nonatomic, assign) BOOL isShowBack;

@end

