// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import "NEListenTogetherReachability.h"

#import <arpa/inet.h>
#import <ifaddrs.h>
#import <netdb.h>
#import <netinet/in.h>
#import <netinet6/in6.h>
#import <sys/socket.h>
#import "NEListenTogetherLocalized.h"

NSString *const kNEListenTogetherReachabilityChangedNotification =
    @"kNEListenTogetherReachabilityChangedNotification";

@interface NEListenTogetherReachability ()

@property(nonatomic, assign) SCNetworkReachabilityRef reachabilityRef;
@property(nonatomic, strong) dispatch_queue_t reachabilitySerialQueue;
@property(nonatomic, weak) id reachabilityObject;

- (void)reachabilityChanged:(SCNetworkReachabilityFlags)flags;
- (BOOL)isReachableWithFlags:(SCNetworkReachabilityFlags)flags;

@end

static NSString *VoiceRoomReachabilityFlags(SCNetworkReachabilityFlags flags) {
  return [NSString
      stringWithFormat:@"%c%c %c%c%c%c%c%c%c",
#if TARGET_OS_IPHONE
                       (flags & kSCNetworkReachabilityFlagsIsWWAN) ? 'W' : '-',
#else
                       'X',
#endif
                       (flags & kSCNetworkReachabilityFlagsReachable) ? 'R' : '-',
                       (flags & kSCNetworkReachabilityFlagsConnectionRequired) ? 'c' : '-',
                       (flags & kSCNetworkReachabilityFlagsTransientConnection) ? 't' : '-',
                       (flags & kSCNetworkReachabilityFlagsInterventionRequired) ? 'i' : '-',
                       (flags & kSCNetworkReachabilityFlagsConnectionOnTraffic) ? 'C' : '-',
                       (flags & kSCNetworkReachabilityFlagsConnectionOnDemand) ? 'D' : '-',
                       (flags & kSCNetworkReachabilityFlagsIsLocalAddress) ? 'l' : '-',
                       (flags & kSCNetworkReachabilityFlagsIsDirect) ? 'd' : '-'];
}

// Start listening for reachability notifications on the current run loop
static void VoiceRoomReachabilityCallback(SCNetworkReachabilityRef target,
                                          SCNetworkReachabilityFlags flags, void *info) {
#pragma unused(target)

  NEListenTogetherReachability *reachability = ((__bridge NEListenTogetherReachability *)info);

  // We probably don't need an autoreleasepool here, as GCD docs state each
  // queue has its own autorelease pool, but what the heck eh?
  @autoreleasepool {
    [reachability reachabilityChanged:flags];
  }
}

@implementation NEListenTogetherReachability

#pragma mark - Class Constructor Methods

+ (instancetype)reachabilityWithHostName:(NSString *)hostname {
  return [NEListenTogetherReachability reachabilityWithHostname:hostname];
}

+ (instancetype)reachabilityWithHostname:(NSString *)hostname {
  SCNetworkReachabilityRef ref = SCNetworkReachabilityCreateWithName(NULL, [hostname UTF8String]);
  if (ref) {
    id reachability = [[self alloc] initWithReachabilityRef:ref];

    return reachability;
  }

  return nil;
}

+ (instancetype)reachabilityWithAddress:(void *)hostAddress {
  SCNetworkReachabilityRef ref = SCNetworkReachabilityCreateWithAddress(
      kCFAllocatorDefault, (const struct sockaddr *)hostAddress);
  if (ref) {
    id reachability = [[self alloc] initWithReachabilityRef:ref];

    return reachability;
  }

  return nil;
}

+ (instancetype)reachabilityForInternetConnection {
  struct sockaddr_in zeroAddress;
  bzero(&zeroAddress, sizeof(zeroAddress));
  zeroAddress.sin_len = sizeof(zeroAddress);
  zeroAddress.sin_family = AF_INET;

  return [self reachabilityWithAddress:&zeroAddress];
}

+ (instancetype)reachabilityForLocalWiFi {
  struct sockaddr_in localWifiAddress;
  bzero(&localWifiAddress, sizeof(localWifiAddress));
  localWifiAddress.sin_len = sizeof(localWifiAddress);
  localWifiAddress.sin_family = AF_INET;
  // IN_LINKLOCALNETNUM is defined in <netinet/in.h> as 169.254.0.0
  localWifiAddress.sin_addr.s_addr = htonl(IN_LINKLOCALNETNUM);

  return [self reachabilityWithAddress:&localWifiAddress];
}

+ (instancetype)reachabilityWithURL:(NSURL *)url {
  id reachability;

  NSString *host = url.host;
  BOOL isIpAddress = [self isIpAddress:host];

  if (isIpAddress) {
    NSNumber *port = url.port ?: [url.scheme isEqualToString:@"https"] ? @(443) : @(80);

    struct sockaddr_in address;
    address.sin_len = sizeof(address);
    address.sin_family = AF_INET;
    address.sin_port = htons([port intValue]);
    address.sin_addr.s_addr = inet_addr([host UTF8String]);

    reachability = [self reachabilityWithAddress:&address];
  } else {
    reachability = [self reachabilityWithHostname:host];
  }

  return reachability;
}

+ (BOOL)isIpAddress:(NSString *)host {
  struct in_addr pin;
  return 1 == inet_aton([host UTF8String], &pin);
}

// Initialization methods

- (instancetype)initWithReachabilityRef:(SCNetworkReachabilityRef)ref {
  self = [super init];
  if (self != nil) {
    self.reachableOnWWAN = YES;
    self.reachabilityRef = ref;

    // We need to create a serial queue.
    // We allocate this once for the lifetime of the notifier.

    self.reachabilitySerialQueue = dispatch_queue_create("com.tonymillion.reachability", NULL);
  }

  return self;
}

- (void)dealloc {
  [self stopNotifier];

  if (self.reachabilityRef) {
    CFRelease(self.reachabilityRef);
    self.reachabilityRef = nil;
  }

  self.reachableBlock = nil;
  self.unreachableBlock = nil;
  self.reachabilityBlock = nil;
  self.reachabilitySerialQueue = nil;
}

#pragma mark - Notifier Methods

// Notifier
// NOTE: This uses GCD to trigger the blocks - they *WILL NOT* be called on THE
// MAIN THREAD
// - In other words DO NOT DO ANY UI UPDATES IN THE BLOCKS.
//   INSTEAD USE dispatch_async(dispatch_get_main_queue(), ^{UISTUFF}) (or
//   dispatch_sync if you want)

- (BOOL)startNotifier {
  // allow start notifier to be called multiple times
  if (self.reachabilityObject && (self.reachabilityObject == self)) {
    return YES;
  }

  SCNetworkReachabilityContext context = {0, NULL, NULL, NULL, NULL};
  context.info = (__bridge void *)self;

  if (SCNetworkReachabilitySetCallback(self.reachabilityRef, VoiceRoomReachabilityCallback,
                                       &context)) {
    // Set it as our reachability queue, which will retain the queue
    if (SCNetworkReachabilitySetDispatchQueue(self.reachabilityRef, self.reachabilitySerialQueue)) {
      // this should do a retain on ourself, so as long as we're in notifier
      // mode we shouldn't disappear out from under ourselves woah
      self.reachabilityObject = self;
      return YES;
    } else {
#ifdef DEBUG
      NSLog(@"SCNetworkReachabilitySetDispatchQueue() failed: %s", SCErrorString(SCError()));
#endif

      // UH OH - FAILURE - stop any callbacks!
      SCNetworkReachabilitySetCallback(self.reachabilityRef, NULL, NULL);
    }
  } else {
#ifdef DEBUG
    NSLog(@"SCNetworkReachabilitySetCallback() failed: %s", SCErrorString(SCError()));
#endif
  }

  // if we get here we fail at the internet
  self.reachabilityObject = nil;
  return NO;
}

- (void)stopNotifier {
  // First stop, any callbacks!
  SCNetworkReachabilitySetCallback(self.reachabilityRef, NULL, NULL);

  // Unregister target from the GCD serial dispatch queue.
  SCNetworkReachabilitySetDispatchQueue(self.reachabilityRef, NULL);

  self.reachabilityObject = nil;
}

#pragma mark - reachability tests

// This is for the case where you flick the airplane mode;
// you end up getting something like this:
// Reachability: WR ct-----
// Reachability: -- -------
// Reachability: WR ct-----
// Reachability: -- -------
// We treat this as 4 UNREACHABLE triggers - really apple should do better than
// this

#define testcase \
  (kSCNetworkReachabilityFlagsConnectionRequired | kSCNetworkReachabilityFlagsTransientConnection)

- (BOOL)isReachableWithFlags:(SCNetworkReachabilityFlags)flags {
  BOOL connectionUP = YES;

  if (!(flags & kSCNetworkReachabilityFlagsReachable)) connectionUP = NO;

  if ((flags & testcase) == testcase) connectionUP = NO;

#if TARGET_OS_IPHONE
  if (flags & kSCNetworkReachabilityFlagsIsWWAN) {
    // We're on 3G.
    if (!self.reachableOnWWAN) {
      // We don't want to connect when on 3G.
      connectionUP = NO;
    }
  }
#endif

  return connectionUP;
}

- (BOOL)isReachable {
  SCNetworkReachabilityFlags flags;

  if (!SCNetworkReachabilityGetFlags(self.reachabilityRef, &flags)) return NO;

  return [self isReachableWithFlags:flags];
}

- (BOOL)isReachableViaWWAN {
#if TARGET_OS_IPHONE

  SCNetworkReachabilityFlags flags = 0;

  if (SCNetworkReachabilityGetFlags(self.reachabilityRef, &flags)) {
    // Check we're REACHABLE
    if (flags & kSCNetworkReachabilityFlagsReachable) {
      // Now, check we're on WWAN
      if (flags & kSCNetworkReachabilityFlagsIsWWAN) {
        return YES;
      }
    }
  }
#endif

  return NO;
}

- (BOOL)isReachableViaWiFi {
  SCNetworkReachabilityFlags flags = 0;

  if (SCNetworkReachabilityGetFlags(self.reachabilityRef, &flags)) {
    // Check we're reachable
    if ((flags & kSCNetworkReachabilityFlagsReachable)) {
#if TARGET_OS_IPHONE
      // Check we're NOT on WWAN
      if ((flags & kSCNetworkReachabilityFlagsIsWWAN)) {
        return NO;
      }
#endif
      return YES;
    }
  }

  return NO;
}

// WWAN may be available, but not active until a connection has been
// established. WiFi may require a connection for VPN on Demand.
- (BOOL)isConnectionRequired {
  return [self connectionRequired];
}

- (BOOL)connectionRequired {
  SCNetworkReachabilityFlags flags;

  if (SCNetworkReachabilityGetFlags(self.reachabilityRef, &flags)) {
    return (flags & kSCNetworkReachabilityFlagsConnectionRequired);
  }

  return NO;
}

// Dynamic, on demand connection?
- (BOOL)isConnectionOnDemand {
  SCNetworkReachabilityFlags flags;

  if (SCNetworkReachabilityGetFlags(self.reachabilityRef, &flags)) {
    return ((flags & kSCNetworkReachabilityFlagsConnectionRequired) &&
            (flags & (kSCNetworkReachabilityFlagsConnectionOnTraffic |
                      kSCNetworkReachabilityFlagsConnectionOnDemand)));
  }

  return NO;
}

// Is user intervention required?
- (BOOL)isInterventionRequired {
  SCNetworkReachabilityFlags flags;

  if (SCNetworkReachabilityGetFlags(self.reachabilityRef, &flags)) {
    return ((flags & kSCNetworkReachabilityFlagsConnectionRequired) &&
            (flags & kSCNetworkReachabilityFlagsInterventionRequired));
  }

  return NO;
}

#pragma mark - reachability status stuff

- (NEListenTogetherNetworkStatus)currentReachabilityStatus {
  if ([self isReachable]) {
    if ([self isReachableViaWiFi]) return ReachableViaWiFi;

#if TARGET_OS_IPHONE
    return ReachableViaWWAN;
#endif
  }

  return NotReachable;
}

- (SCNetworkReachabilityFlags)reachabilityFlags {
  SCNetworkReachabilityFlags flags = 0;

  if (SCNetworkReachabilityGetFlags(self.reachabilityRef, &flags)) {
    return flags;
  }

  return 0;
}

- (NSString *)currentReachabilityString {
  NEListenTogetherNetworkStatus temp = [self currentReachabilityStatus];

  if (temp == ReachableViaWWAN) {
    // Updated for the fact that we have CDMA phones now!
    return NELocalizedString(@"Cellular");
  }
  if (temp == ReachableViaWiFi) {
    return NELocalizedString(@"WiFi");
  }

  return NELocalizedString(@"网络似乎断开了");
}

- (NSString *)currentReachabilityFlags {
  return VoiceRoomReachabilityFlags([self reachabilityFlags]);
}

#pragma mark - Callback function calls this method

- (void)reachabilityChanged:(SCNetworkReachabilityFlags)flags {
  if ([self isReachableWithFlags:flags]) {
    if (self.reachableBlock) {
      self.reachableBlock(self);
    }
  } else {
    if (self.unreachableBlock) {
      self.unreachableBlock(self);
    }
  }

  if (self.reachabilityBlock) {
    self.reachabilityBlock(self, flags);
  }

  // this makes sure the change notification happens on the MAIN THREAD
  dispatch_async(dispatch_get_main_queue(), ^{
    [[NSNotificationCenter defaultCenter]
        postNotificationName:kNEListenTogetherReachabilityChangedNotification
                      object:self];
  });
}

#pragma mark - Debug Description

- (NSString *)description {
  NSString *description =
      [NSString stringWithFormat:@"<%@: %p (%@)>", NSStringFromClass([self class]), self,
                                 [self currentReachabilityFlags]];
  return description;
}

@end
