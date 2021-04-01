//
//  NETSLiveListVM.h
//  NLiteAVDemo
//
//  Created by Ease on 2020/11/9.
//  Copyright © 2020 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class NTESChatroomInfo;

///
/// 直播列表页 VM
///

@interface NETSLiveListViewModel : NSObject

/// 数据源集合
@property (nonatomic, strong, readonly) NSArray <NTESChatroomInfo *> *datas;
/// 是否结束
@property (nonatomic, assign, readonly) BOOL    isEnd;
/// 是否正在加载
@property (nonatomic, assign, readonly) BOOL    isLoading;
/// 加载error
@property (nonatomic, assign, readonly) NSError *error;

/// 加载新数据
- (void)loadNewDataWithLiveType:(NTESCreateRoomType)liveType;

/// 加载更多
- (void)loadMoreWithLiveType:(NTESCreateRoomType)liveType;

@end

NS_ASSUME_NONNULL_END
