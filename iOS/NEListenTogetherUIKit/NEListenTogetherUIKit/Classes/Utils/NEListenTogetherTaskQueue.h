// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, NEListenTogetherTaskType) {
  // 主唱等待合唱加入
  NEListenTogetherTaskChorusMatch,
  // 独唱等待
  NEListenTogetherTaskSoloWait,
  // 等待副唱加载资源
  NEListenTogetherTaskLoadSource,
};

@interface NEListenTogetherTask : NSObject

@property(nonatomic, assign) NEListenTogetherTaskType type;
@property(nonatomic, assign) NSTimeInterval addTime;
@property(nonatomic, assign) long wholeLeftTime;
@property(nonatomic, assign) long currentLeftTime;

+ (NEListenTogetherTask *)defaultChorusMatchTask;
+ (NEListenTogetherTask *)defaultSoloWaitTask;
+ (NEListenTogetherTask *)defaultLoadSourceTask;

@end

@interface NEListenTogetherTaskQueue : NSObject

@property(nonatomic, copy) void (^taskCompleteBlock)(NEListenTogetherTask *task);
@property(nonatomic, copy) void (^taskProgressBlock)(NEListenTogetherTask *task);
@property(nonatomic, copy) void (^taskCanceledBlock)(NEListenTogetherTask *task);

- (void)start;

- (void)stop;

- (void)addTask:(NEListenTogetherTask *)task;

- (void)removeTask;

@end

NS_ASSUME_NONNULL_END
