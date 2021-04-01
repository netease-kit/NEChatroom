//
//  NETSLiveListVM.m
//  NLiteAVDemo
//
//  Created by Ease on 2020/11/9.
//  Copyright © 2020 Netease. All rights reserved.
//

#import "NETSLiveListViewModel.h"
#import "NTESChatroomApi.h"

#import "NTESChatroomInfo.h"

@interface NETSLiveListViewModel ()

@property (nonatomic, strong, readwrite)    NSArray <NTESChatroomInfo *> *datas;
@property (nonatomic, assign, readwrite)    BOOL    isEnd;
@property (nonatomic, assign, readwrite)    BOOL    isLoading;
@property (nonatomic, assign, readwrite)    NSError *error;

@property (nonatomic, assign)   int32_t   pageNum;
@property (nonatomic, assign)   int32_t   pageSize;

@end

@implementation NETSLiveListViewModel

- (instancetype)init
{
    self = [super init];
    if (self) {
        _pageNum = 0;
        _pageSize = 20;
        _datas = @[];
    }
    return self;
}

- (void)loadNewDataWithLiveType:(NTESCreateRoomType)liveType {
    self.pageNum = 0;
    self.isLoading = YES;

    [NTESChatroomApi fetchListWithRoomType:liveType offset:_pageNum limit:_pageSize completionHandle:^(NSDictionary * _Nonnull response) {
        NSDictionary *listDict = response[@"/data"];
        NSArray* list = [NSArray yy_modelArrayWithClass:[NTESChatroomInfo class] json:listDict[@"list"]];
        if (list && [list isKindOfClass:[NSArray class]]) {
            self.datas = list;
        } else {
            self.datas = @[];
        }
        self.isLoading = NO;
        self.isEnd = ([list count] < self.pageSize);
        self.error = nil;
    } errorHandle:^(NSError * _Nonnull error, NSDictionary * _Nullable response) {
        self.datas = @[];
        self.isLoading = NO;
        self.isEnd = YES;
        self.error = error;
    }];
  
}

- (void)loadMoreWithLiveType:(NTESCreateRoomType)liveType {
    if (_isEnd) {
        return;
    }
    
    self.pageNum += 20;
    self.isLoading = YES;

    [NTESChatroomApi fetchListWithRoomType:liveType offset:_pageNum limit:_pageSize completionHandle:^(NSDictionary * _Nonnull response) {
        NSDictionary *listDict = response[@"/data"];
        NSArray* list = [NSArray yy_modelArrayWithClass:[NTESChatroomInfo class] json:listDict[@"list"]];
        if (list && [list isKindOfClass:[NSArray class]]) {
            NSMutableArray *temp = [NSMutableArray arrayWithArray:self.datas];
            [temp addObjectsFromArray:list];
            self.datas = [temp copy];

            self.isLoading = NO;
            self.isEnd = ([list count] < self.pageSize);
            self.error = nil;
        }
    } errorHandle:^(NSError * _Nonnull error, NSDictionary * _Nullable response) {
        self.isLoading = NO;
        self.isEnd = YES;
        self.error = error;
    }];
}

@end
