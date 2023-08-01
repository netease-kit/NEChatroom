// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import "FUManager.h"

#import "authpack.h"

#import "FUTestRecorder.h"

static FUManager *shareManager = NULL;

@interface FUManager ()

@property (nonatomic, assign) FUDevicePerformanceLevel devicePerformanceLevel;

@end

@implementation FUManager

+ (FUManager *)shareManager
{
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    shareManager = [[FUManager alloc] init];
  });
  
  return shareManager;
}

- (void)setupRenderKit{
  
  CFAbsoluteTime startTime = CFAbsoluteTimeGetCurrent();
  FUSetupConfig *setupConfig = [[FUSetupConfig alloc] init];
  setupConfig.authPack = FUAuthPackMake(g_auth_package, sizeof(g_auth_package));
  
  // 初始化 FURenderKit
  [FURenderKit setupWithSetupConfig:setupConfig];
  
  [FURenderKit setLogLevel:FU_LOG_LEVEL_INFO];
  
  self.devicePerformanceLevel = [FURenderKit devicePerformanceLevel];
  
  dispatch_async(dispatch_get_global_queue(0, 0), ^{
    // 加载人脸 AI 模型
    NSString *faceAIPath = [[NSBundle mainBundle] pathForResource:@"ai_face_processor" ofType:@"bundle"];
    [FUAIKit loadAIModeWithAIType:FUAITYPE_FACEPROCESSOR dataPath:faceAIPath];
    
    // 加载身体 AI 模型，注意：高性能机型加载ai_human_processor_gpu.bundle
    NSString *humanBundleName = self.devicePerformanceLevel == FUDevicePerformanceLevelHigh ? @"ai_human_processor_gpu" : @"ai_human_processor";
    NSString *bodyAIPath = [[NSBundle mainBundle] pathForResource:humanBundleName ofType:@"bundle"];
    [FUAIKit loadAIModeWithAIType:FUAITYPE_HUMAN_PROCESSOR dataPath:bodyAIPath];
    
    CFAbsoluteTime endTime = (CFAbsoluteTimeGetCurrent() - startTime);
    NSLog(@"---%lf",endTime);
    
    // 设置人脸算法质量
    [FUAIKit shareKit].faceProcessorFaceLandmarkQuality = self.devicePerformanceLevel == FUDevicePerformanceLevelHigh ? FUFaceProcessorFaceLandmarkQualityHigh : FUFaceProcessorFaceLandmarkQualityMedium;
    
    // 设置小脸检测是否打开
    [FUAIKit shareKit].faceProcessorDetectSmallFace = self.devicePerformanceLevel == FUDevicePerformanceLevelHigh;
  });
  
  [[FUTestRecorder shareRecorder] setupRecord];
  
  [FUAIKit shareKit].maxTrackFaces = 4;
}

- (void)destoryItems {
  [FURenderKit shareRenderKit].beauty = nil;
  [FURenderKit shareRenderKit].bodyBeauty = nil;
  [FURenderKit shareRenderKit].makeup = nil;
  [[FURenderKit shareRenderKit].stickerContainer removeAllSticks];
  
  // 销毁FU美颜库, 按需加载
  [FURenderKit destroy];
}


- (void)onCameraChange {
  [FUAIKit resetTrackedResult];
}

- (void)updateBeautyBlurEffect {
  if (![FURenderKit shareRenderKit].beauty || ![FURenderKit shareRenderKit].beauty.enable) {
    return;
  }
  if (self.devicePerformanceLevel == FUDevicePerformanceLevelHigh) {
    // 根据人脸置信度设置不同磨皮效果
    CGFloat score = [FUAIKit fuFaceProcessorGetConfidenceScore:0];
    if (score > 0.95) {
      [FURenderKit shareRenderKit].beauty.blurType = 3;
      [FURenderKit shareRenderKit].beauty.blurUseMask = YES;
    } else {
      [FURenderKit shareRenderKit].beauty.blurType = 2;
      [FURenderKit shareRenderKit].beauty.blurUseMask = NO;
    }
  } else {
    // 设置精细磨皮效果
    [FURenderKit shareRenderKit].beauty.blurType = 2;
    [FURenderKit shareRenderKit].beauty.blurUseMask = NO;
  }
}


#pragma mark -  render
/**将道具绘制到pixelBuffer*/
- (CVPixelBufferRef)renderItemsToPixelBuffer:(CVPixelBufferRef)pixelBuffer{
  
  [[FUTestRecorder shareRecorder] processFrameWithLog];
  [self updateBeautyBlurEffect];
  if ([self.delegate respondsToSelector:@selector(faceUnityManagerCheckAI)]) {
    [self.delegate faceUnityManagerCheckAI];
  }
  
  if (self.origin) {
    return pixelBuffer;
  }
  
  FURenderInput *input = [[FURenderInput alloc] init];
  // 处理效果对比问题
  //    input.renderConfig.imageOrientation = FUImageOrientationLeft;
  input.renderConfig.imageOrientation = FUImageOrientationUP;
  input.pixelBuffer = pixelBuffer;
  
  //    input.renderConfig.stickerFlipH = self.flipx;
  //开启重力感应，内部会自动计算正确方向，设置fuSetDefaultRotationMode，无须外面设置
  input.renderConfig.gravityEnable = YES;
  input.renderConfig.readBackToPixelBuffer = YES;
  FURenderOutput *outPut = [[FURenderKit shareRenderKit] renderWithInput:input];
  pixelBuffer = outPut.pixelBuffer;
  return pixelBuffer;
}

@end
