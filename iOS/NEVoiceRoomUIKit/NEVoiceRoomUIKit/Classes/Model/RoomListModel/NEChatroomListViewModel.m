// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import "NEChatroomListViewModel.h"
#import <YXAlog_iOS/YXAlog.h>
@interface NEChatroomListViewModel ()
@property(nonatomic, strong, readwrite) NSArray<NEVoiceRoomInfo *> *datas;
@property(nonatomic, assign, readwrite) BOOL isEnd;
@property(nonatomic, assign, readwrite) BOOL isLoading;
@property(nonatomic, assign, readwrite) NSError *error;

@property(nonatomic, assign) int32_t pageNum;
@property(nonatomic, assign) int32_t pageSize;
@end

@implementation NEChatroomListViewModel

- (instancetype)init {
  self = [super init];
  if (self) {
    _pageNum = 1;
    _pageSize = 20;
    _datas = @[];
  }
  return self;
}

- (void)requestNewDataWithLiveType:(NELiveRoomType)roomType {
  self.isLoading = YES;
  [[NEVoiceRoomKit getInstance]
      getVoiceRoomListWithLiveState:NEVoiceRoomLiveStateLive
                            pageNum:self.pageNum
                           pageSize:20
                           callback:^(NSInteger code, NSString *_Nullable msg,
                                      NEVoiceRoomList *_Nullable data) {
                             if (code != 0) {
                               self.datas = @[];
                               self.error =
                                   [NSError errorWithDomain:NSCocoaErrorDomain
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
                           }];
}

//加载更多
- (void)requestMoreDataWithLiveType:(NELiveRoomType)roomType {
  if (_isEnd) {
    return;
  }
  self.isLoading = YES;
  self.pageNum += 1;
  [[NEVoiceRoomKit getInstance]
      getVoiceRoomListWithLiveState:NEVoiceRoomLiveStateLive
                            pageNum:self.pageNum
                           pageSize:20
                           callback:^(NSInteger code, NSString *_Nullable msg,
                                      NEVoiceRoomList *_Nullable data) {
                             if (code != 0) {
                               self.datas = @[];
                               self.error =
                                   [NSError errorWithDomain:NSCocoaErrorDomain
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
                           }];
}

@end
