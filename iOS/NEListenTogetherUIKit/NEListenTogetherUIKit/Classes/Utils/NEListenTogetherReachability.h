// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import <Foundation/Foundation.h>
#import <SystemConfiguration/SystemConfiguration.h>

/**
 * Create NS_ENUM macro if it does not exist on the targeted version of iOS or
 *OS X.
 *
 * @see http://nshipster.com/ns_enum-ns_options/
 **/
#ifndef NS_ENUM
#define NS_ENUM(_type, _name) \
  enum _name : _type _name;   \
  enum _name : _type
#endif

extern NSString *const kNEListenTogetherReachabilityChangedNotification;

typedef NS_ENUM(NSInteger, NEListenTogetherNetworkStatus) {
  // Apple NEListenTogetherNetworkStatus Compatible Names.
  NotReachable = 0,
  ReachableViaWiFi = 2,
  ReachableViaWWAN = 1
};

@class NEListenTogetherReachability;

typedef void (^NEKaraokeNetworkReachable)(NEListenTogetherReachability *reachability);
typedef void (^NEKaraokeNetworkUnreachable)(NEListenTogetherReachability *reachability);
typedef void (^NEKaraokeNetworkReachability)(NEListenTogetherReachability *reachability,
                                             SCNetworkConnectionFlags flags);

@interface NEListenTogetherReachability : NSObject

@property(nonatomic, copy) NEKaraokeNetworkReachable reachableBlock;
@property(nonatomic, copy) NEKaraokeNetworkUnreachable unreachableBlock;
@property(nonatomic, copy) NEKaraokeNetworkReachability reachabilityBlock;

@property(nonatomic, assign) BOOL reachableOnWWAN;

+ (instancetype)reachabilityWithHostname:(NSString *)hostname;
// This is identical to the function above, but is here to maintain
// compatibility with Apples original code. (see .m)
+ (instancetype)reachabilityWithHostName:(NSString *)hostname;
+ (instancetype)reachabilityForInternetConnection;
+ (instancetype)reachabilityWithAddress:(void *)hostAddress;
+ (instancetype)reachabilityForLocalWiFi;
+ (instancetype)reachabilityWithURL:(NSURL *)url;

- (instancetype)initWithReachabilityRef:(SCNetworkReachabilityRef)ref;

- (BOOL)startNotifier;
- (void)stopNotifier;

- (BOOL)isReachable;
- (BOOL)isReachableViaWWAN;
- (BOOL)isReachableViaWiFi;

// WWAN may be available, but not active until a connection has been
// established. WiFi may require a connection for VPN on Demand.
- (BOOL)isConnectionRequired;  // Identical DDG variant.
- (BOOL)connectionRequired;    // Apple's routine.
// Dynamic, on demand connection?
- (BOOL)isConnectionOnDemand;
// Is user intervention required?
- (BOOL)isInterventionRequired;

- (NEListenTogetherNetworkStatus)currentReachabilityStatus;
- (SCNetworkReachabilityFlags)reachabilityFlags;
- (NSString *)currentReachabilityString;
- (NSString *)currentReachabilityFlags;

@end
