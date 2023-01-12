// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import "NEListenTogetherRoomListViewModel.h"
#import <YXAlog_iOS/YXAlog.h>
@interface NEListenTogetherRoomListViewModel ()
@property(nonatomic, strong, readwrite) NSArray<NEListenTogetherInfo *> *datas;
@property(nonatomic, assign, readwrite) BOOL isEnd;
@property(nonatomic, assign, readwrite) BOOL isLoading;
@property(nonatomic, strong, readwrite) NSError *error;

@property(nonatomic, assign) int32_t pageNum;
@property(nonatomic, assign) int32_t pageSize;
@end

@implementation NEListenTogetherRoomListViewModel

- (instancetype)init {
  self = [super init];
  if (self) {
    _pageNum = 1;
    _pageSize = 20;
    _datas = @[];
  }
  return self;
}

- (void)requestNewDataWithLiveType:(NEListenTogetherLiveRoomType)roomType {
  self.isLoading = YES;
  [[NEListenTogetherKit getInstance]
      getVoiceRoomList:NEListenTogetherLiveRoomTypeListen_together
             liveState:NEListenTogetherLiveStateLive
               pageNum:self.pageNum
              pageSize:20
              callback:^(NSInteger code, NSString *_Nullable msg,
                         NEListenTogetherList *_Nullable data) {
                dispatch_async(dispatch_get_main_queue(), ^{
                  if (code != 0) {
                    self.datas = @[];
                    self.error = [NSError errorWithDomain:NSCocoaErrorDomain
                                                     code:code
                                                 userInfo:@{NSLocalizedDescriptionKey : msg}];
                    self.isEnd = YES;
                    YXAlogError(@"request roomList failed,error: %@", msg.description);
                  } else {
                    self.datas = data.list;
                    self.error = nil;
                    self.isEnd = ([data.list count] < self.pageSize);
                  }
                  self.isLoading = NO;
                });
              }];
}

// 加载更多
- (void)requestMoreDataWithLiveType:(NEListenTogetherLiveRoomType)roomType {
  if (_isEnd) {
    return;
  }
  self.isLoading = YES;
  self.pageNum += 1;
  [[NEListenTogetherKit getInstance]
      getVoiceRoomList:NEListenTogetherLiveRoomTypeListen_together
             liveState:NEListenTogetherLiveStateLive
               pageNum:self.pageNum
              pageSize:20
              callback:^(NSInteger code, NSString *_Nullable msg,
                         NEListenTogetherList *_Nullable data) {
                dispatch_async(dispatch_get_main_queue(), ^{
                  if (code != 0) {
                    self.datas = @[];
                    self.error = [NSError errorWithDomain:NSCocoaErrorDomain
                                                     code:code
                                                 userInfo:@{NSLocalizedDescriptionKey : msg}];
                    self.isEnd = YES;
                    YXAlogError(@"request roomList failed,error: %@", msg.description);

                  } else {
                    NSMutableArray *temp = [NSMutableArray arrayWithArray:self.datas];
                    [temp addObjectsFromArray:data.list];
                    self.datas = [temp copy];
                    self.isEnd = ([data.list count] < self.pageSize);
                    self.error = nil;
                  }
                  self.isLoading = NO;
                });
              }];
}

@end
