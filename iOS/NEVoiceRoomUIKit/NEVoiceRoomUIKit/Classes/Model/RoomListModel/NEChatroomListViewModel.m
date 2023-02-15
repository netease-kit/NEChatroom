// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import "NEChatroomListViewModel.h"

@interface NEChatroomListViewModel ()
@property(nonatomic, strong, readwrite) NSArray<NEVoiceRoomInfo *> *datas;
@property(nonatomic, assign, readwrite) BOOL isEnd;
@property(nonatomic, assign, readwrite) BOOL isLoading;
@property(nonatomic, strong, readwrite) NSError *error;

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

- (void)requestNewDataWithLiveType:(NEVoiceRoomLiveRoomType)roomType {
  self.isLoading = YES;
  [[NEVoiceRoomKit getInstance]
      getVoiceRoomList:NEVoiceRoomLiveRoomTypeMultiAudio
             liveState:NEVoiceRoomLiveStateLive
               pageNum:self.pageNum
              pageSize:20
              callback:^(NSInteger code, NSString *_Nullable msg, NEVoiceRoomList *_Nullable data) {
                dispatch_async(dispatch_get_main_queue(), ^{
                  if (code != 0) {
                    self.datas = @[];
                    self.error = [NSError errorWithDomain:NSCocoaErrorDomain
                                                     code:code
                                                 userInfo:@{NSLocalizedDescriptionKey : msg}];
                    self.isEnd = YES;
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
- (void)requestMoreDataWithLiveType:(NEVoiceRoomLiveRoomType)roomType {
  if (_isEnd) {
    return;
  }
  self.isLoading = YES;
  self.pageNum += 1;
  [[NEVoiceRoomKit getInstance]
      getVoiceRoomList:NEVoiceRoomLiveRoomTypeMultiAudio
             liveState:NEVoiceRoomLiveStateLive
               pageNum:self.pageNum
              pageSize:20
              callback:^(NSInteger code, NSString *_Nullable msg, NEVoiceRoomList *_Nullable data) {
                dispatch_async(dispatch_get_main_queue(), ^{
                  if (code != 0) {
                    self.datas = @[];
                    self.error = [NSError errorWithDomain:NSCocoaErrorDomain
                                                     code:code
                                                 userInfo:@{NSLocalizedDescriptionKey : msg}];
                    self.isEnd = YES;
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
