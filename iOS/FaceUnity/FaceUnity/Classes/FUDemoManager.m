// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import "FUDemoManager.h"

#import "FUBeautyFunctionView.h"
#import "FUOthersFunctionView.h"

#import "FUBeautySkinViewModel.h"
#import "FUBeautyShapeViewModel.h"
#import "FUFilterViewModel.h"

#import "FUSegmentBar.h"

@interface FUDemoManager ()<FUFunctionViewDelegate, FUManagerProtocol, FUSegmentBarDelegate>

/// 底部功能选择栏
@property (nonatomic, strong) FUSegmentBar *bottomBar;
/// 美肤功能视图
@property (nonatomic, strong) FUBeautyFunctionView *skinView;
/// 美型功能视图
@property (nonatomic, strong) FUBeautyFunctionView *shapeView;
/// 滤镜功能视图
@property (nonatomic, strong) FUOthersFunctionView *filterView;

@property (nonatomic, strong) UIView *lineView;

@property (nonatomic, strong) UIButton *originButton;

/// 提示标签
@property (nonatomic, strong) UILabel *trackTipLabel;

@property (nonatomic, strong) FUBeautySkinViewModel *beautySkinViewModel;
@property (nonatomic, strong) FUBeautyShapeViewModel *beautyShapeViewModel;
@property (nonatomic, strong) FUFilterViewModel *filterViewModel;

/// 全部模块
@property (nonatomic, copy) NSArray<FUViewModel *> *viewModels;

/// 全部功能视图数组
@property (nonatomic, copy) NSArray<FUFunctionView *> *moduleViews;

/// 当前正在显示的模块类型
@property (nonatomic, assign) FUModuleType showingModuleType;

/// 当前是否显示子功能视图
@property (nonatomic, assign) BOOL isShowingFunctionView;

@property (nonatomic, weak) UIViewController *targetController;
@property (nonatomic, assign) CGFloat demoOriginY;

@property (nonatomic, strong) UISwitch *renderSwitch;

@end

static FUDemoManager *shareManager = NULL;

@implementation FUDemoManager

+ (FUDemoManager *)shareManager
{
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    shareManager = [[FUDemoManager alloc] init];
  });
  
  return shareManager;
}

#pragma mark - Initialization

- (instancetype)init {
  self = [super init];
  if (self) {
    [FUManager shareManager].flipx = YES;
    [[FUManager shareManager] setupRenderKit];
    [FUManager shareManager].delegate = self;
    
    // 加载默认效果
    NSString *path = [[NSBundle mainBundle] pathForResource:@"face_beautification" ofType:@"bundle"];
    FUBeauty *beauty = [[FUBeauty alloc] initWithPath:path name:@"FUBeauty"];
    // 默认均匀磨皮
    beauty.heavyBlur = 0;
    beauty.blurType = 3;
    // 默认自定义脸型
    beauty.faceShape = 4;
    // 高性能设备设置去黑眼圈、去法令纹、大眼、嘴型最新效果
    if ([FUManager shareManager].devicePerformanceLevel == FUDevicePerformanceLevelHigh) {
      [beauty addPropertyMode:FUBeautyPropertyMode2 forKey:FUModeKeyRemovePouchStrength];
      [beauty addPropertyMode:FUBeautyPropertyMode2 forKey:FUModeKeyRemoveNasolabialFoldsStrength];
      [beauty addPropertyMode:FUBeautyPropertyMode3 forKey:FUModeKeyEyeEnlarging];
      [beauty addPropertyMode:FUBeautyPropertyMode3 forKey:FUModeKeyIntensityMouth];
    }
    [FURenderKit shareRenderKit].beauty = beauty;
    
    // 默认美肤、美型、滤镜
    [self.beautySkinViewModel startRender];
    [self.beautyShapeViewModel startRender];
    [self.filterViewModel startRender];
  }
  return self;
}

- (void)showInTargetController:(UIViewController *)controller originY:(CGFloat)originY {
  NSAssert(controller != nil, @"目标控制器不能为空");
  self.targetController = controller;
  self.demoOriginY = originY;
  
  [controller.view addSubview:self.bottomBar];
  [controller.view addSubview:self.skinView];
  [controller.view addSubview:self.shapeView];
  [controller.view addSubview:self.filterView];
  
  [controller.view addSubview:self.trackTipLabel];
  
  [controller.view addSubview:self.lineView];
  [controller.view addSubview:self.originButton];
  //        [controller.view addSubview:self.renderSwitch];
}

- (void)show {
  self.bottomBar.hidden = false;
  self.skinView.hidden = false;
  self.shapeView.hidden = false;
  self.filterView.hidden = false;
  self.lineView.hidden = false;
  self.originButton.hidden = false;
}

- (void)hide {
  self.bottomBar.hidden = true;
  self.skinView.hidden = true;
  self.shapeView.hidden = true;
  self.filterView.hidden = true;
  self.lineView.hidden = true;
  self.originButton.hidden = true;
}

#pragma mark - Private methods
- (void)resolveModuleOperations:(NSInteger)item {
  NSInteger count = self.moduleViews.count;
  if (item >= count) {
    return;
  }
  if (item == -1) {
    // 隐藏当前视图
    [self hideFunctionView:self.moduleViews[self.showingModuleType] animated:YES];
    _isShowingFunctionView = NO;
    // 隐藏效果开关
    self.renderSwitch.hidden = YES;
  } else {
    if (_isShowingFunctionView) {
      // 当前已经有显示的视图时，需要先隐藏当前视图，再显示目标视图
      [self hideFunctionView:self.moduleViews[self.showingModuleType] animated:NO];
      [self showFunctionView:self.moduleViews[item]];
    } else {
      // 当前无显示的视图时，直接显示目标视图
      [self showFunctionView:self.moduleViews[item]];
      _isShowingFunctionView = YES;
    }
    // 保存显示的类型
    self.showingModuleType = item;
    
    if (self.viewModels[item].model.type == FUModuleTypeBeautySkin || self.viewModels[item].model.type == FUModuleTypeBeautyShape) {
      // 显示效果开关
      self.renderSwitch.hidden = NO;
      if (self.viewModels[item].model.type == FUModuleTypeBeautySkin || self.viewModels[item].model.type == FUModuleTypeBeautyShape) {
        // 美肤和美型效果同开同关
        self.renderSwitch.on = self.viewModels[FUModuleTypeBeautySkin].isRendering && self.viewModels[FUModuleTypeBeautyShape].isRendering;
      }
      if (self.moduleViews[item].slider.hidden) {
        self.renderSwitch.frame = CGRectMake(5, self.demoOriginY - FUFunctionViewHeight - FUFunctionSliderHeight - 10, 50, 30);
      } else {
        self.renderSwitch.frame = CGRectMake(5, self.demoOriginY - FUFunctionViewHeight - FUFunctionSliderHeight - 40, 50, 30);
      }
      
    } else {
      // 隐藏效果开关
      self.renderSwitch.hidden = YES;
    }
  }
}


/// 显示功能视图
/// @param functionView 功能视图
- (void)showFunctionView:(FUFunctionView *)functionView {
  if (!functionView) {
    return;
  }
  functionView.hidden = NO;
  [UIView animateWithDuration:0.15 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
    functionView.transform = CGAffineTransformMakeScale(1, 1);
    functionView.alpha = 1;
  } completion:^(BOOL finished) {
  }];
}


/// 隐藏功能视图
/// @param functionView 功能视图
/// @param animated 是否需要动画（切换功能时先隐藏当前显示的视图不需要动画，直接隐藏时需要动画）
- (void)hideFunctionView:(FUFunctionView *)functionView animated:(BOOL)animated {
  if (!functionView) {
    return;
  }
  if (animated) {
    [UIView animateWithDuration:0.15 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
      functionView.transform = CGAffineTransformMakeScale(1, 0.001);
      functionView.alpha = 0;
    } completion:^(BOOL finished) {
      functionView.hidden = YES;
    }];
  } else {
    functionView.transform = CGAffineTransformMakeScale(1, 0.001);
    functionView.alpha = 0;
    functionView.hidden = YES;
  }
}

#pragma mark - Event response
- (void)renderSwitchAction:(UISwitch *)sender {
  if (self.showingModuleType == FUModuleTypeBeautySkin || self.showingModuleType == FUModuleTypeBeautyShape) {
    // 美肤和美型共用一个开关
    if (sender.isOn) {
      [self.viewModels[FUModuleTypeBeautySkin] startRender];
      [self.viewModels[FUModuleTypeBeautyShape] startRender];
    } else {
      [self.viewModels[FUModuleTypeBeautySkin] stopRender];
      [self.viewModels[FUModuleTypeBeautyShape] stopRender];
    }
  } else {
    if (sender.isOn) {
      [self.viewModels[self.showingModuleType] startRender];
    } else {
      [self.viewModels[self.showingModuleType] stopRender];
    }
  }
}

#pragma mark - FUManagerProtocol
- (void)faceUnityManagerCheckAI {
  dispatch_async(dispatch_get_main_queue(), ^{
    NSString *tipString = self.viewModels[self.showingModuleType].model.tip;
    self.trackTipLabel.hidden = [FUAIKit shareKit].trackedFacesCount > 0;
    self.trackTipLabel.text = tipString;
  });
}

#pragma mark - FUSegmentBarDelegate
- (void)segmentBar:(FUSegmentBar *)segmentBar didSelectItemAtIndex:(NSUInteger)index {
  [self resolveModuleOperations:index];
}

#pragma mark - FUFunctionViewDelegate
- (void)functionView:(FUFunctionView *)functionView didSelectFunctionAtIndex:(NSInteger)index {
  if (functionView.viewModel.isNeedSlider) {
    if (functionView.slider.hidden) {
      self.renderSwitch.frame = CGRectMake(5, self.demoOriginY - FUFunctionViewHeight - FUFunctionSliderHeight - 10, 50, 30);
    } else {
      self.renderSwitch.frame = CGRectMake(5, self.demoOriginY - FUFunctionViewHeight - FUFunctionSliderHeight - 40, 50, 30);
    }
  }
  FUViewModel *viewModel = functionView.viewModel;
  viewModel.selectedIndex = index;
  
  if (!viewModel.isRendering) {
    [viewModel startRender];
  }
  [viewModel updateData:viewModel.model.moduleData[index]];
}

- (void)functionView:(FUFunctionView *)functionView didChangeSliderValue:(CGFloat)value {
  FUSubModel *subModel = functionView.viewModel.model.moduleData[functionView.viewModel.selectedIndex];
  subModel.currentValue = value * subModel.ratio;
  [functionView.viewModel updateData:subModel];
}

- (void)functionViewDidEndSlide:(FUFunctionView *)functionView {
  switch (functionView.viewModel.model.type) {
    case FUModuleTypeBeautySkin:{
      [self.skinView refreshSubviews];
    }
      break;
    case FUModuleTypeBeautyShape:{
      [self.shapeView refreshSubviews];
    }
      break;
    default:
      break;
  }
}

- (void)functionViewDidClickRecover:(FUFunctionView *)functionView {
  UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:FaceUnityLocalizedString(@"是否将所有参数恢复到默认值") preferredStyle:UIAlertControllerStyleAlert];
  UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:FaceUnityLocalizedString(@"取消") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
  }];
  [cancelAction setValue:[UIColor colorWithRed:44/255.0 green:46/255.0 blue:48/255.0 alpha:1.0] forKey:@"titleTextColor"];
  
  UIAlertAction *certainAction = [UIAlertAction actionWithTitle:FaceUnityLocalizedString(@"确定") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
    FUViewModel *viewModel = functionView.viewModel;
    [viewModel recover];
    [functionView refreshSubviews];
  }];
  
  [certainAction setValue:[UIColor colorWithRed:31/255.0 green:178/255.0 blue:255/255.0 alpha:1.0] forKey:@"titleTextColor"];
  
  [alert addAction:cancelAction];
  [alert addAction:certainAction];
  
  [self.targetController presentViewController:alert animated:YES completion:^{
    
  }];
}

#pragma mark - Getters
- (FUSegmentBar *)bottomBar {
  if (!_bottomBar) {
    NSMutableArray *segments = [[NSMutableArray alloc] init];
    for (FUViewModel *viewModel in self.viewModels) {
      [segments addObject:viewModel.model.name];
    }
    _bottomBar = [[FUSegmentBar alloc] initWithFrame:CGRectMake(0, self.demoOriginY, CGRectGetWidth(self.targetController.view.bounds), 49) titles:[segments copy] configuration:[FUSegmentBarConfigurations new]];
    _bottomBar.segmentDelegate = self;
  }
  return _bottomBar;
}

- (FUBeautyFunctionView *)skinView {
  if (!_skinView) {
    _skinView = [[FUBeautyFunctionView alloc] initWithFrame:CGRectMake(0, self.demoOriginY - FUFunctionViewHeight, CGRectGetWidth(self.targetController.view.bounds), FUFunctionViewHeight) viewModel:self.viewModels[FUModuleTypeBeautySkin]];
    _skinView.delegate = self;
  }
  return _skinView;
}

- (FUBeautyFunctionView *)shapeView {
  if (!_shapeView) {
    _shapeView = [[FUBeautyFunctionView alloc] initWithFrame:CGRectMake(0, self.demoOriginY - FUFunctionViewHeight, CGRectGetWidth(self.targetController.view.bounds), FUFunctionViewHeight) viewModel:self.viewModels[FUModuleTypeBeautyShape]];
    _shapeView.delegate = self;
  }
  return _shapeView;
}

- (FUOthersFunctionView *)filterView {
  if (!_filterView) {
    _filterView = [[FUOthersFunctionView alloc] initWithFrame:CGRectMake(0, self.demoOriginY - FUFunctionViewHeight, CGRectGetWidth(self.targetController.view.bounds), FUFunctionViewHeight) viewModel:self.viewModels[FUModuleTypeFilter]];
    _filterView.delegate = self;
  }
  return _filterView;
}

- (UIView *)lineView {
  // 分割线
  if (!_lineView) {
    _lineView = [[UIView alloc] initWithFrame:CGRectMake(0, self.demoOriginY, CGRectGetWidth(self.targetController.view.bounds), 1)];
    _lineView.backgroundColor = [UIColor colorWithRed:229/ 255.f green:229/255.f blue:229/255.f alpha:0.2];
  }
  return _lineView;
}

- (UIButton *)originButton {
  if (!_originButton) {
    _originButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _originButton.frame = CGRectMake(self.targetController.view.frame.size.width - 50, self.demoOriginY - FUFunctionViewHeight - FUFunctionSliderHeight - 50, 40, 40);
    [_originButton setImage:[UIImage imageNamed:@"beauty_origin" inBundle:[NSBundle bundleForClass:self.class] compatibleWithTraitCollection:nil] forState:UIControlStateNormal];
    UILongPressGestureRecognizer *tap = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longTap:)];
    [_originButton addGestureRecognizer:tap];
  }
  return _originButton;
}

- (void)longTap:(UILongPressGestureRecognizer *)gesture {
  if (gesture.state == UIGestureRecognizerStateBegan) {
    FUManager.shareManager.origin = true;
  } else if (gesture.state == UIGestureRecognizerStateEnded) {
    FUManager.shareManager.origin = false;
  }
}

- (UISwitch *)renderSwitch {
  if (!_renderSwitch) {
    _renderSwitch = [[UISwitch alloc] init];
    [_renderSwitch addTarget:self action:@selector(renderSwitchAction:) forControlEvents:UIControlEventValueChanged];
    _renderSwitch.hidden = YES;
  }
  return _renderSwitch;
}

- (UILabel *)trackTipLabel {
  if (!_trackTipLabel) {
    _trackTipLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMidX(self.targetController.view.frame) - 70, CGRectGetMidY(self.targetController.view.frame) - 12, 140, 24)];
    _trackTipLabel.textColor = [UIColor whiteColor];
    _trackTipLabel.font = [UIFont systemFontOfSize:17];
    _trackTipLabel.textAlignment = NSTextAlignmentCenter;
    _trackTipLabel.hidden = YES;
  }
  return _trackTipLabel;
}

- (NSArray<FUViewModel *> *)viewModels {
  if (!_viewModels) {
    _viewModels = [@[self.beautySkinViewModel, self.beautyShapeViewModel, self.filterViewModel] copy];
  }
  return _viewModels;
}

- (NSArray<FUFunctionView *> *)moduleViews {
  if (!_moduleViews) {
    _moduleViews = [@[self.skinView, self.shapeView, self.filterView] copy];
  }
  return _moduleViews;
}

- (FUBeautySkinViewModel *)beautySkinViewModel {
  if (!_beautySkinViewModel) {
    _beautySkinViewModel = [[FUBeautySkinViewModel alloc] initWithSelectedIndex:-1 needSlider:YES];
  }
  return _beautySkinViewModel;
}

- (FUBeautyShapeViewModel *)beautyShapeViewModel {
  if (!_beautyShapeViewModel) {
    _beautyShapeViewModel = [[FUBeautyShapeViewModel alloc] initWithSelectedIndex:-1 needSlider:YES];
  }
  return _beautyShapeViewModel;
}

- (FUFilterViewModel *)filterViewModel {
  if (!_filterViewModel) {
    _filterViewModel = [[FUFilterViewModel alloc] initWithSelectedIndex:1 needSlider:YES];
  }
  return _filterViewModel;
}

@end
