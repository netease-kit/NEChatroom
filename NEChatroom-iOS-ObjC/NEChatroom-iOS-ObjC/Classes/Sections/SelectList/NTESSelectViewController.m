//
//  NTESSelectViewController.m
//  NERtcAudioChatroom
//
//  Created by Netease on 2019/3/22.
//  Copyright © 2019年 netease. All rights reserved.
//

#import "NTESSelectViewController.h"
#import "NTESUserInfoCell.h"
#import "UIView+NTES.h"

@interface NTESSelectViewController ()

@end

@implementation NTESSelectViewController

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self didSetUpUI];
    [self setUpNotications];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    CGFloat top = (IPHONE_X ? IPHONE_X_HairHeight : 20);
    _navBar.frame = CGRectMake(0, top, self.view.width, 40.0);
    _emptyView.frame = CGRectMake(0,
                                  _navBar.bottom,
                                  self.view.width,
                                  self.view.height-_navBar.bottom);
    _tableview.frame = _emptyView.frame;
}

- (void)didSetUpUI {
    self.navigationController.navigationBarHidden = YES;
    [self.view addSubview:self.navBar];
    [self.view addSubview:self.tableview];
    [self.view addSubview:self.emptyView];
}

- (void)setUpNotications {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didMemberEnter:)
                                                 name:kChatroomUserEnter
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didMemberLeave:)
                                                 name:kChatroomUserLeave
                                               object:nil];
}
#pragma mark - Notciations
- (void)didMemberEnter:(NSNotification *)note {
    NIMChatroomNotificationMember *member = note.object;
    [self didMemberChanged:YES member:member];
}

- (void)didMemberLeave:(NSNotification *)note {
    NIMChatroomNotificationMember *member = note.object;
    [self didMemberChanged:NO member:member];
    [self deleteMemberWithUserId:member.userId];
}

- (void)didMemberChanged:(BOOL)enter member:(NIMChatroomMember *)member {}

- (void)deleteMemberWithUserId:(NSString *)userId {
    if (!userId) {
        return;
    }
    
    __block NSInteger index = -1;
    [self.showMembers enumerateObjectsUsingBlock:^(NIMChatroomMember * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([userId isEqualToString:obj.userId]) {
            index = idx;
            *stop = YES;
        }
    }];
    
    if (index >= 0) {
        [self.showMembers removeObjectAtIndex:index];
        [self.tableview reloadData];
    }
}
#pragma mark - <UITableViewDelegate,UITableViewDataSource>
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _showMembers.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NTESUserInfoCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[NTESUserInfoCell alloc] initWithStyle:UITableViewCellStyleDefault
                                       reuseIdentifier:@"cell"];
    }
    NIMChatroomMember *member = _showMembers[indexPath.row];
    [cell refresh:member];
    return cell;
}

#pragma mark - Getter
- (UITableView *)tableview {
    if (!_tableview) {
        _tableview =[[UITableView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)
                                                 style:UITableViewStylePlain];
        _tableview.delegate = self;
        _tableview.dataSource = self;
        _tableview.rowHeight = 56.0;
        _tableview.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
        _tableview.backgroundView = nil;
        _tableview.backgroundColor = [UIColor blackColor];
    }
    return _tableview;
}

- (NTESNavBar *)navBar {
    if (!_navBar) {
        _navBar = [[NTESNavBar alloc] init];
        __weak typeof(self) weakSelf = self;
        _navBar.backBlock = ^(){
            [weakSelf dismissViewControllerAnimated:YES completion:nil];
        };
        _navBar.title = @"选择成员";
    }
    return _navBar;
}

- (NTESChatroomStateView *)emptyView {
    if (!_emptyView) {
        _emptyView = [[NTESChatroomStateView alloc] initWithInfo:@"暂无群成员～"];
    }
    return _emptyView;
}

@end
