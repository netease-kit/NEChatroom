// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import <Foundation/Foundation.h>
#import <NERtcSDK/NERtcSDK.h>

NS_ASSUME_NONNULL_BEGIN

@interface NEAudioEffectManager : NSObject

@property(nonatomic, copy) void (^earbackEnableChanged)(BOOL);

@property(nonatomic, copy) void (^effectPitchChanged)(NSInteger effectId, int pitch);

/// 打开关闭耳返
/// @param enable TRUE打开，FALSE关闭
- (int)enableEarback:(BOOL)enable;

/// 耳返是否打开
- (BOOL)isEarbackEnable;

/// 当前是否可以启用耳返（依赖外部监听RTC回调来设置）
/// @param can 是否可以启用
- (void)setCanEarbackEnable:(BOOL)can;

/// 当前是否可以启用耳返
- (BOOL)canEarbackEnable;

/// 设置耳返音量
/// @param volume 耳返音量
- (int)setEarbackVolume:(int)volume;

/// 获取耳返音量
- (int)getEarbackVolume;

/// 设置采集音量 [0,400]， 80为原始音量
/// @param volume 采集音量
- (int)adjustRecordingSignalVolume:(int)volume;

/// 获取采集音量
- (int)getRecordingSignalVolume;

/// 设置混音音量
/// @param volume 混音音量
- (int)setAudioMixingVolume:(int)volume;

/// 获取混音音量
- (int)getAudioMixingVolume;

/// 调节伴音升降key。
/// @note
/// 发起伴音后可调解。伴音结束后再发起需要重新设置。
/// 音调pitch取值范围为
/// [-12,12]，每相邻两个值的音高距离相差半音。取值的绝对值越大，音调升高或降低得越多。
/// @param pitch 按半音音阶调整本地播放音乐的音调，默认值为0，即不调整音调。取值范围为 [-12,12]
- (int)setAudioMixingPitch:(int)pitch;

/// 获取当前调节伴音升降key。
/// @note
/// 发起伴音后可调解。伴音结束后再发起需要重新设置。
/// 音调pitch取值范围为
/// [-12,12]，每相邻两个值的音高距离相差半音。取值的绝对值越大，音调升高或降低得越多。
- (int)getAudioMixingPitch;

/// 设置音效音量
/// @param effectId 音效id
/// @param volume 音效音量
- (int)setAudioEffectVolumeWithEffectId:(NSInteger)effectId voulme:(int)volume;

/// 获取音效音量
/// @param effectId 音效id
- (int)getAudioEffectVolumeWithEffectId:(NSInteger)effectId;

/// 调节音效升降key。
/// @note
/// 发起音效后可调解。伴音结束后再发起需要重新设置。
/// 音调pitch取值范围为
/// [-12,12]，每相邻两个值的音高距离相差半音。取值的绝对值越大，音调升高或降低得越多。
/// @param effectId 指定音效的 ID。每个音效均有唯一的 ID。
/// @param pitch 按半音音阶调整本地播放音乐的音调，默认值为0，即不调整音调。取值范围为 [-12,12]。
- (int)setEffectPitchWithEffectId:(NSInteger)effectId pitch:(int)pitch;

/// 获取当前调节音效升降key。
/// @param effectId 指定音效的 ID。每个音效均有唯一的 ID。
- (int)getEffectPitchWithEffectId:(NSInteger)effectId;

/// 设置美声
/// @param present 美声效果
- (int)setReverbPreset:(NERtcVoiceBeautifierType)present;

/// 获取美声
- (NERtcVoiceBeautifierType)getReverbPreset;

/// 设置本地语音混响参数
/// @param intensity 混响参数
- (int)setReverbIntensity:(int)intensity;

/// 获取混响参数
- (int)getReverbIntensity;

/// 设置 SDK 预设的美声效果
/// @param present 美声效果
- (int)setEqualizePreset:(NERtcVoiceBeautifierType)present;

/// 获取美声
- (NERtcVoiceBeautifierType)getEqualizePreset;

/// 设置本地语音音效均衡，即自定义设置本地人声均衡波段的中心频率
/// @param bandFrequency bandFrequency 频谱子带索引，取值范围是 [0-9]，分别代表
/// 10 个频带，对应的中心频率是 [31，62，125，250，500，1k，2k，4k，8k，16k] Hz
/// @param bandGain  每个 band 的增益，单位是 dB，每一个值的范围是
/// [-15，15]，默认值为 0
- (int)setCustomEqualization:(NERtcAudioEqualizationBandFrequency)bandFrequency
                    bandGain:(int)bandGain;

/// 获取本地语音音效均衡
/// @param bandFrequency 频谱子带索引
- (int)getCustomBandGain:(NERtcAudioEqualizationBandFrequency)bandFrequency;

/// 设置所有频段的语音音效均衡
/// @param intensity 0-100
- (int)setEqualizeIntensity:(int)intensity;

/// 获取所有频段的语音音效均衡
- (int)getEqualizeIntensity;

/// 设置变声
/// @param preset 变声效果
- (int)setVoiceChangerPreset:(NERtcVoiceChangerType)preset;

/// 获取变声效果
- (NERtcVoiceChangerType)getVoiceChangerPreset;

/// 重置所有效果
- (void)resetAll;

@end

NS_ASSUME_NONNULL_END
