//
//  NTESLiveListMainViewController.m
//  NEChatroom-iOS-ObjC
//
//  Created by vvj on 2021/2/2.
//  Copyright © 2021 netease. All rights reserved.
//

#import "NTESLiveListMainViewController.h"

#import "NELiveListMainPageNavView.h"


@interface NTESLiveListMainViewController ()<UIScrollViewDelegate>
@property(nonatomic, strong) NELiveListMainPageNavView *navView;
@property (nonatomic, strong) UIScrollView *segmentScrollView;

@property (nonatomic, strong) NSArray *childVcArray;

@property(nonatomic, assign) NTESCreateRoomType selectType;
@end

@implementation NTESLiveListMainViewController


- (instancetype)initWithSelectType:(NTESCreateRoomType)selectType {
    if (self = [super init]) {
        _selectType = selectType;
    }
    return self;
}

- (instancetype)init {
    return [self initWithSelectType:NTESCreateRoomTypeChatRoom];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)ntes_addSubViews {
    [self.view addSubview:self.navView];
    [self.view addSubview:self.segmentScrollView];
    [self addChildSubViewControllers];
}

- (void)ntes_bindViewModel {
    [super ntes_bindViewModel];
    
    @weakify(self)
    self.navView.selectMenuSubject = [RACSubject subject];
    [self.navView.selectMenuSubject subscribeNext:^(NSNumber *selectIndex) {
        @strongify(self)
        [self switchSubViewController:selectIndex.integerValue];
    }];
    self.navView.backSubject = [RACSubject subject];
    [self.navView.backSubject subscribeNext:^(id  _Nullable x) {
        @strongify(self)
        if (self.eventBlcok) {
            self.eventBlcok(nil);
        }
        [self.navigationController popViewControllerAnimated:YES];
    }];
}

#pragma mark - Private Method
//添加子控制器
- (void)addChildSubViewControllers {
    NSString *childVc = self.childVcArray.firstObject;
    Class cls = NSClassFromString(childVc);
    NTESBaseViewController *baseVc = [[cls alloc]init];
    [self addChildViewController:baseVc];
    baseVc.view.frame = CGRectMake(0, 0, UIScreenWidth, self.segmentScrollView.bounds.size.height);
    [self.segmentScrollView addSubview:baseVc.view];
    if (self.selectType == NTESCreateRoomTypeKTV) {
        self.navView.selectIndex = 1;
        [self switchSubViewController:1];
    }
}

//切换子控制器
- (void)switchSubViewController:(NSInteger)index {

    [self.segmentScrollView setContentOffset:CGPointMake(index*UIScreenWidth, 0) animated:YES ];
    NSString *childVc = self.childVcArray[index];
    Class cls = NSClassFromString(childVc);
    NTESBaseViewController *baseVc = [[cls alloc]init];
    for (NSInteger i = 0; i < self.childViewControllers.count; i ++) {
        NTESBaseViewController *vc = self.childViewControllers[i];
        if ([baseVc isMemberOfClass:[vc class]]) {
            return ;
        }
    }
    [self addChildViewController:baseVc];
    baseVc.view.frame = CGRectMake(UIScreenWidth*index, 0, UIScreenWidth, self.segmentScrollView.bounds.size.height);
    [self.segmentScrollView addSubview:baseVc.view];
}

#pragma mark -UIScrollViewDelegate
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    NSInteger index = scrollView.contentOffset.x / scrollView.bounds.size.width;
    self.navView.selectIndex = index;
    [self switchSubViewController:index];
}

#pragma mark - lazyMethod
- (NELiveListMainPageNavView *)navView {
    if (!_navView) {
        _navView = [[NELiveListMainPageNavView alloc] initWithFrame:CGRectMake(0, 0, UIScreenWidth, [NTESDeviceSizeInfo get_iPhoneNavBarHeight])];
    }
    return _navView;
}

- (UIScrollView *)segmentScrollView {
    if (!_segmentScrollView) {
        _segmentScrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, self.currentNavHeight, UIScreenWidth, UIScreenHeight-self.currentNavHeight)];
        _segmentScrollView.contentSize = CGSizeMake(UIScreenWidth*self.childVcArray.count, UIScreenHeight -self.currentNavHeight);
        _segmentScrollView.delegate = self;
        _segmentScrollView.showsHorizontalScrollIndicator = NO;
        _segmentScrollView.pagingEnabled = YES;
        _segmentScrollView.scrollEnabled = YES;
        _segmentScrollView.bounces = YES;
    }
    return _segmentScrollView;
}

- (NSArray *)childVcArray {
    if (!_childVcArray) {
        _childVcArray = @[@"NTESChatRoomListViewController",@"NTESKtvListViewController"];
    }
    return _childVcArray;
}


@end
