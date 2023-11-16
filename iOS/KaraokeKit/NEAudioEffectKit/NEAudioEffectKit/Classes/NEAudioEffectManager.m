// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import "NEAudioEffectManager.h"

static const int EARBACK_VOLUME = 50;
static const int RECORDING_SIGNAL_VOLUME = 80;
static const int AUDIO_MIXING_VOLUME = 50;
static const int AUDIO_EFFECT_VOLUME = 50;
static const int REVERB_INTENSITY = 50;
static const int EQUALIZE_INTENSITY = 100;

@interface NEAudioEffectModel : NSObject

@property(nonatomic, assign) bool earbackEnable;
@property(nonatomic, assign) bool canEarbackEnable;
@property(nonatomic, assign) int earbackVolume;
@property(nonatomic, assign) int recordingSignalVolume;
@property(nonatomic, assign) int audioMixingVolume;
@property(nonatomic, strong) NSMutableDictionary<NSNumber *, NSNumber *> *audioEffectVolume;
@property(nonatomic, assign) NERtcVoiceBeautifierType reverbPreset;
@property(nonatomic, assign) int reverbIntensity;
@property(nonatomic, assign) NERtcVoiceBeautifierType equalizePreset;
@property(nonatomic, strong) NSMutableDictionary<NSNumber *, NSNumber *> *customEqualization;
@property(nonatomic, assign) int equalizeIntensity;
@property(nonatomic, assign) NERtcVoiceChangerType voiceChangerPreset;
@property(nonatomic, strong) NSMutableArray<NSNumber *> *effectPitchArray;

@end

@implementation NEAudioEffectModel

+ (NEAudioEffectModel *)defaultModel {
  NEAudioEffectModel *model = [[NEAudioEffectModel alloc] init];
  model.canEarbackEnable = false;
  model.earbackEnable = false;
  model.earbackVolume = EARBACK_VOLUME;
  model.recordingSignalVolume = RECORDING_SIGNAL_VOLUME;
  model.audioMixingVolume = AUDIO_MIXING_VOLUME;
  model.audioEffectVolume = [NSMutableDictionary new];
  model.reverbPreset = kNERtcVoiceBeautifierOff;
  model.reverbIntensity = REVERB_INTENSITY;
  model.equalizePreset = kNERtcVoiceBeautifierOff;
  model.equalizeIntensity = EQUALIZE_INTENSITY;
  model.customEqualization = [NSMutableDictionary new];
  model.voiceChangerPreset = kNERtcVoiceChangerOff;
  model.effectPitchArray = [NSMutableArray new];
  return model;
}

@end

@interface NEAudioEffectManager ()

@property(nonatomic, strong) NEAudioEffectModel *model;

@end

@implementation NEAudioEffectManager

- (instancetype)init {
  if ([super init]) {
    self.model = [NEAudioEffectModel defaultModel];
  }
  return self;
}

- (void)setCanEarbackEnable:(BOOL)can {
  self.model.canEarbackEnable = can;
}

- (BOOL)canEarbackEnable {
  return self.model.canEarbackEnable;
}

- (int)enableEarback:(BOOL)enable {
  if (self.model.canEarbackEnable) {
    int code = [[NERtcEngine sharedEngine] enableEarback:enable volume:self.model.earbackVolume];
    if (code == 0) {
      if (enable) {
        [[NERtcEngine sharedEngine] setEarbackVolume:self.model.earbackVolume];
      }
      self.model.earbackEnable = enable;
      if (self.earbackEnableChanged) {
        self.earbackEnableChanged(enable);
      }
    }
    return code;
  } else {
    return -1;
  }
}

- (int)setEarbackVolume:(int)volume {
  self.model.earbackVolume = volume;
  return [[NERtcEngine sharedEngine] setEarbackVolume:volume];
}

- (int)getEarbackVolume {
  return self.model.earbackVolume;
}

- (BOOL)isEarbackEnable {
  return self.model.earbackEnable;
}

- (int)adjustRecordingSignalVolume:(int)volume {
  self.model.recordingSignalVolume = volume;
  return [[NERtcEngine sharedEngine] adjustRecordingSignalVolume:volume];
}

- (int)getRecordingSignalVolume {
  return self.model.recordingSignalVolume;
}

- (int)setAudioMixingVolume:(int)volume {
  self.model.audioMixingVolume = volume;
  [[NERtcEngine sharedEngine] setAudioMixingPlaybackVolume:volume];
  return [[NERtcEngine sharedEngine] setAudioMixingSendVolume:volume];
}

- (int)getAudioMixingVolume {
  uint32_t volume = 0;
  [[NERtcEngine sharedEngine] getAudioMixingSendVolume:&volume];
  //    [[NERtcEngine sharedEngine] getAudioMixingPlaybackVolume:&volume];
  if (self.model.audioMixingVolume != volume) {
    self.model.audioMixingVolume = volume;
  }
  return volume;
}

- (int)setAudioMixingPitch:(int)pitch {
  return [[NERtcEngine sharedEngine] setAudioMixingPitch:pitch];
}

- (int)getAudioMixingPitch {
  int32_t pitch = 0;
  [[NERtcEngine sharedEngine] getAudioMixingPitch:&pitch];
  return pitch;
}

- (int)setAudioEffectVolumeWithEffectId:(NSInteger)effectId voulme:(int)volume {
  [self.model.audioEffectVolume setObject:@(volume) forKey:@(effectId)];
  [[NERtcEngine sharedEngine] setEffectPlaybackVolumeWithId:(uint32_t)effectId volume:volume];
  return [[NERtcEngine sharedEngine] setEffectSendVolumeWithId:(uint32_t)effectId volume:volume];
}

- (int)getAudioEffectVolumeWithEffectId:(NSInteger)effectId {
  uint32_t volume = AUDIO_EFFECT_VOLUME;
  int code = [[NERtcEngine sharedEngine] getEffectSendVolumeWithId:(uint32_t)effectId
                                                            volume:&volume];
  if (code == 0) {
    if ([[self.model.audioEffectVolume objectForKey:@(effectId)] intValue] != volume) {
      [self.model.audioEffectVolume setObject:@(volume) forKey:@(effectId)];
    }
    return volume;
  } else {
    if ([self.model.audioEffectVolume.allKeys containsObject:@(effectId)]) {
      return [[self.model.audioEffectVolume objectForKey:@(effectId)] intValue];
    } else {
      return AUDIO_EFFECT_VOLUME;
    }
  }
}

- (int)setEffectPitchWithEffectId:(NSInteger)effectId pitch:(int)pitch {
  [self.model.effectPitchArray addObject:@(pitch)];
  if (self.effectPitchChanged) {
    self.effectPitchChanged(effectId, pitch);
  }
  return [[NERtcEngine sharedEngine] setEffectPitchWithId:(uint32_t)effectId pitch:pitch];
}

- (int)getEffectPitchWithEffectId:(NSInteger)effectId {
  int32_t pitch = 0;
  [[NERtcEngine sharedEngine] getEffectPitchWithId:(uint32_t)effectId pitch:&pitch];
  return pitch;
}

- (int)setReverbPreset:(NERtcVoiceBeautifierType)present {
  self.model.reverbPreset = present;
  return [[NERtcEngine sharedEngine] setVoiceBeautifierPreset:present];
}

- (NERtcVoiceBeautifierType)getReverbPreset {
  return self.model.reverbPreset;
}

- (int)setReverbIntensity:(int)intensity {
  self.model.reverbIntensity = intensity;
  NERtcReverbParam *param = [[NERtcReverbParam alloc] init];
  param.wetGain = intensity / 100.0f;
  return [[NERtcEngine sharedEngine] setLocalVoiceReverbParam:param];
}

- (int)getReverbIntensity {
  return self.model.reverbIntensity;
}

- (int)setEqualizePreset:(NERtcVoiceBeautifierType)present {
  self.model.equalizePreset = present;
  return [[NERtcEngine sharedEngine] setVoiceBeautifierPreset:present];
}

- (NERtcVoiceBeautifierType)getEqualizePreset {
  return self.model.equalizePreset;
}

- (int)setCustomEqualization:(NERtcAudioEqualizationBandFrequency)bandFrequency
                    bandGain:(int)bandGain {
  [self.model.customEqualization setObject:@(bandGain) forKey:@(bandFrequency)];
  [[NERtcEngine sharedEngine] setVoiceBeautifierPreset:kNERtcVoiceBeautifierMuffled];
  return [[NERtcEngine sharedEngine] setLocalVoiceEqualizationOfBandFrequency:bandFrequency
                                                                     withGain:bandGain];
}

- (int)getCustomBandGain:(NERtcAudioEqualizationBandFrequency)bandFrequency {
  return [[self.model.customEqualization objectForKey:@(bandFrequency)] intValue];
}

- (int)setEqualizeIntensity:(int)intensity {
  self.model.equalizeIntensity = intensity;
  // [0,100]之间的数转成[-15,15]之间的数
  int bandGain = (intensity * 30.0f) / 100.0f - 15;
  for (int i = NERtcAudioEqualizationBand31; i <= NERtcAudioEqualizationBand16K; i++) {
    [[NERtcEngine sharedEngine] setLocalVoiceEqualizationOfBandFrequency:i withGain:bandGain];
  }
  return 1;
}

- (int)getEqualizeIntensity {
  return self.model.equalizeIntensity;
}

- (int)setVoiceChangerPreset:(NERtcVoiceChangerType)preset {
  self.model.voiceChangerPreset = preset;
  return [[NERtcEngine sharedEngine] setAudioEffectPreset:preset];
}

- (NERtcVoiceChangerType)getVoiceChangerPreset {
  return self.model.voiceChangerPreset;
}

- (void)resetAll {
  NSDictionary *temp = self.model.customEqualization;
  NSDictionary *temp1 = self.model.audioEffectVolume;
  bool canEarbackEnable = self.model.canEarbackEnable;
  bool earbackEnable = self.model.earbackEnable;
  NSArray *temp2 = self.model.effectPitchArray;

  self.model = [NEAudioEffectModel defaultModel];
  self.model.earbackEnable = earbackEnable;
  self.model.canEarbackEnable = canEarbackEnable;
  [self setEarbackVolume:self.model.earbackVolume];
  [self adjustRecordingSignalVolume:self.model.recordingSignalVolume];
  [self setAudioMixingVolume:self.model.audioMixingVolume];
  for (NSNumber *key in temp.allKeys) {
    [self setCustomEqualization:[key intValue] bandGain:0];
  }
  for (NSNumber *key in temp1.allKeys) {
    [self setAudioEffectVolumeWithEffectId:[key intValue] voulme:AUDIO_EFFECT_VOLUME];
  }
  [self setReverbPreset:self.model.reverbPreset];
  [self setReverbIntensity:self.model.reverbIntensity];
  [self setEqualizePreset:self.model.equalizePreset];
  [self setEqualizeIntensity:self.model.equalizeIntensity];
  [self setVoiceChangerPreset:self.model.voiceChangerPreset];
  [self setAudioMixingPitch:0];
  for (NSNumber *effId in temp2) {
    [self setEffectPitchWithEffectId:effId.integerValue pitch:0];
  }
}

@end
