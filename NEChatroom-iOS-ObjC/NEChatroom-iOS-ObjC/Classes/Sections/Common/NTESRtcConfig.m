//
//  NTESRtcConfig.m
//  NEChatroom-iOS-ObjC
//
//  Created by Wenchao Ding on 2021/2/3.
//  Copyright © 2021 netease. All rights reserved.
//

#import "NTESRtcConfig.h"
#import <NERtcSDK/NERtcSDK.h>

#define kDefaultEarbackVolume 80

@implementation NTESRtcConfig

+ (instancetype)sharedConfig {
    static dispatch_once_t onceToken;
    static NTESRtcConfig *instance;
    dispatch_once(&onceToken, ^{
        instance = [[NTESRtcConfig alloc] init];
    });
    return instance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _earbackOn = NO;
        _micOn = YES;
        _speakerOn = YES;
        _effectVolume = 50;
        _audioMixingVolume = 50;
        _audioRecordVolume = 100;
    }
    return self;
}

- (void)setEarbackOn:(BOOL)earbackOn {
    int ret = [NERtcEngine.sharedEngine enableEarback:earbackOn volume:kDefaultEarbackVolume];
    if (ret != kNERtcNoError) {
        return NELPLogError(@"Error: %@", NERtcErrorDescription(ret));
    }
    _earbackOn = earbackOn;
}

- (void)setMicOn:(BOOL)micOn {
    int ret = [[NERtcEngine sharedEngine] setRecordDeviceMute:!micOn];
    if (ret != kNERtcNoError) {
        return NELPLogError(@"Error: %@", NERtcErrorDescription(ret));
    }
    _micOn = micOn;
}

- (void)setSpeakerOn:(BOOL)speakerOn {
    int ret = [NERtcEngine.sharedEngine setPlayoutDeviceMute:!speakerOn];
    if (ret != kNERtcNoError) {
        return NELPLogError(@"Error: %@", NERtcErrorDescription(ret));
    }
    _speakerOn = speakerOn;
}

- (void)setAudioRecordVolume:(uint32_t)audioRecordVolume {
    int ret = [NERtcEngine.sharedEngine adjustRecordingSignalVolume:audioRecordVolume];
    if (ret != kNERtcNoError) {
        return NELPLogError(@"Error: %@", NERtcErrorDescription(ret));
    }
    _audioRecordVolume = audioRecordVolume;
}

@end
