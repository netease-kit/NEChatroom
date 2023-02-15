// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import "NEListenTogetherCustomTimer.h"

@interface NEListenTogetherCustomTimer ()

@property(nonatomic, weak) id target;

@end

@implementation NEListenTogetherCustomTimer

- (instancetype)initWithTimeInterval:(NSTimeInterval)interval
                              target:(id)target
                            selector:(SEL)selector
                             repeats:(BOOL)repeat {
  self = [super init];
  if (self) {
    NSMethodSignature *methodSignature = [target methodSignatureForSelector:selector];
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:methodSignature];
    invocation.selector = selector;
    invocation.target = target;
    self.target = target;
    self.timer = [NSTimer scheduledTimerWithTimeInterval:interval
                                                  target:self
                                                selector:@selector(handler:)
                                                userInfo:invocation
                                                 repeats:repeat];
  }
  return self;
}

- (void)handler:(NSTimer *)timer {
  NSInvocation *invocation = [timer userInfo];
  if (self.target) {
    [invocation invoke];
  } else {
    [self invalidate];
  }
}

- (void)invalidate {
  [self.timer invalidate];
  self.timer = nil;
}

@end
