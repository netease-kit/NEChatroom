//
//  NTESMuteListViewController.m
//  NERtcAudioChatroom
//
//  Created by Netease on 2019/3/6.
//  Copyright © 2019年 netease. All rights reserved.
//

#import "NTESMuteListViewController.h"
#import "UIView+NTES.h"
#import "NTESUserInfoCell.h"
#import "NTESUnMuteListViewController.h"

@interface NTESMuteListViewController ()<NTESUnMuteListVCDelegate>

@property (nonatomic, strong) NIMChatroom *chatroom;
@property (nonatomic, strong) UIView *actionWrapper;
@property (nonatomic, strong) UIButton *addMutePerson;
@property (nonatomic, strong) UIButton *muteAll;
@property (nonatomic, strong) UIView *bottomLineView;

@property (nonatomic, strong) NSMutableArray <NIMChatroomMember *> *members;
@property (nonatomic, assign) BOOL chatroomMute;
@end

@implementation NTESMuteListViewController

- (instancetype)initWithChatroom:(NIMChatroom *)chatroom
                    chatroomMute:(BOOL)chatroomMute {
    if (self = [super init]) {
        _chatroom = chatroom;
        _chatroomMute = chatroomMute;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self fetchChatroomMembers];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    _actionWrapper.frame = CGRectMake(0, self.navBar.bottom, self.navBar.width, 60.0);
    
    CGFloat width = (self.view.width -  3*16.0)/2;
    CGFloat height = _actionWrapper.height - 2*12.0;
    _addMutePerson.frame = CGRectMake(16.0, 12.0, width, height);
    _muteAll.frame = CGRectMake(_addMutePerson.right + 16.0,
                                _addMutePerson.top,
                                _addMutePerson.width,
                                _addMutePerson.height);
    _bottomLineView.frame = CGRectMake(0, _actionWrapper.height-0.5, _actionWrapper.width, 0.5);
    self.emptyView.frame = CGRectMake(0,
                                  _actionWrapper.bottom,
                                  self.view.width,
                                  self.view.height-_actionWrapper.bottom);
    self.tableview.frame = self.emptyView.frame;
    
    [_addMutePerson cutViewRounded:UIRectCornerAllCorners cornerRadii:CGSizeMake(20, 20)];
    [_muteAll cutViewRounded:UIRectCornerAllCorners cornerRadii:CGSizeMake(20, 20)];

}

- (CGSize)preferredContentSize
{
    CGFloat preferedHeight = UIScreenHeight * 0.8 + kSafeAreaHeight;
    return CGSizeMake(UIScreenWidth, preferedHeight);
}

- (void)didSetUpUI {
    [super didSetUpUI];
    self.emptyView.info = @"暂无禁言成员~";
    [self.view addSubview:self.actionWrapper];
    [self.actionWrapper addSubview:self.addMutePerson];
    [self.actionWrapper addSubview:self.muteAll];
    [self.actionWrapper addSubview:self.bottomLineView];

}

- (void)fetchChatroomMembers {
    NIMChatroomMemberRequest *request = [[NIMChatroomMemberRequest alloc] init];
    request.roomId = _chatroom.roomId;
    request.type  = NIMChatroomFetchMemberTypeTemp;
    request.lastMember = nil;
    request.limit  = 100;
    __weak typeof(self) weakSelf = self;
    [[NIMSDK sharedSDK].chatroomManager fetchChatroomMembers:request
                                                  completion:^(NSError * _Nullable error, NSArray<NIMChatroomMember *> * _Nullable members) {
          if (!error) {
              [weakSelf processMembers:members];
              [weakSelf refreshUI];
          } else {
              NELPLogInfo(@"成员信息拉取失败.[%@]", error);
          }
      }];
}

- (void)processMembers:(NSArray<NIMChatroomMember *> *)members {
    
    if (_chatroomMute) {
        self.showMembers = [NSMutableArray arrayWithArray:members];
    } else {
        NSMutableArray *ret = [NSMutableArray array];
        [members enumerateObjectsUsingBlock:^(NIMChatroomMember * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (obj.isTempMuted) {
                [ret addObject:obj];
            }
        }];
        self.showMembers = ret;
    }
    _members = [NSMutableArray arrayWithArray:members];
    
    if (self.showMembers.count == 0) {
        self.navBar.title = @"禁言成员";
    } else {
        self.navBar.title = [NSString stringWithFormat:@"禁言成员(%d)", (int)self.showMembers.count];
    }
    self.emptyView.hidden = (self.showMembers.count != 0);
}

- (void)refreshUI {
    self.emptyView.hidden = (self.showMembers.count != 0);
    [self.tableview reloadData];
    if (self.showMembers.count == 0) {
        self.navBar.title = @"禁言成员";
    } else {
        self.navBar.title = [NSString stringWithFormat:@"禁言成员(%d)", (int)self.showMembers.count];
    }
}

- (void)reloadWithChatroomMute:(BOOL)chatroomMute {
    _chatroomMute = chatroomMute;
    [self processMembers:_members];
    [self.tableview reloadData];
}

#pragma mark - Action
- (void)mutePersionAction:(UIButton *)sender {
    NTESUnMuteListViewController *vc = nil;
    if (!_chatroomMute) {
        vc = [[NTESUnMuteListViewController alloc] initWithMembers:_members];
    } else {
        vc = [[NTESUnMuteListViewController alloc] initWithMembers:nil];
    }
    vc.delegate = self;
    [self.navigationController pushViewController:vc animated:YES];
//    [self presentViewController:vc animated:YES completion:nil];
}

- (void)muteAllAciton:(UIButton *)sender {
    [_delegate didMuteAll:!sender.selected vc:self];
    sender.selected = !sender.selected;
}

#pragma mark - <UITableViewDelegate, UITableViewDataSource>
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return !_chatroomMute;
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
    return @"解除禁言";
}

-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleDelete;
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        // 解除禁言
        NIMChatroomMember *member = self.showMembers[indexPath.row];
        [_delegate didMuteMember:member mute:NO];
        member.isTempMuted = NO;  // UI刷新
        [self.showMembers removeObject:member];
        [self refreshUI];
    }
}

#pragma mark - <NTESUnMuteListVCDelegate>
- (void)didSelectMember:(NIMChatroomMember *)member {
    [_delegate didMuteMember:member mute:YES];
    [self.showMembers addObject:member]; // UI刷新
    [self refreshUI];
    member.isTempMuted = YES; 
}

#pragma mark - Super Class Reload
- (void)didMemberChanged:(BOOL)enter member:(NIMChatroomNotificationMember *)member {
    if (!enter) {
        [self deleteMemberWithUserId:member.userId];
    }
}

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

#pragma mark - Getter
- (UIView *)actionWrapper {
    if (!_actionWrapper) {
        _actionWrapper = [[UIView alloc] init];
        _actionWrapper.backgroundColor = [UIColor whiteColor];
    }
    return _actionWrapper;
}

- (UIButton *)addMutePerson {
    if (!_addMutePerson) {
        _addMutePerson = [UIButton buttonWithType:UIButtonTypeCustom];
        [_addMutePerson setTitle:@"添加禁言成员" forState:UIControlStateNormal];
        [_addMutePerson setTitleColor:UIColorFromRGB(0x222222) forState:UIControlStateNormal];
        _addMutePerson.titleLabel.font = TextFont_14;
        _addMutePerson.backgroundColor = UIColorFromRGBA(0xF2F3F5, 1.0);
        [_addMutePerson addTarget:self action:@selector(mutePersionAction:)
                 forControlEvents:UIControlEventTouchUpInside];
    }
    return _addMutePerson;
}

- (UIButton *)muteAll {
    if (!_muteAll) {
        _muteAll = [UIButton buttonWithType:UIButtonTypeCustom];
        [_muteAll setTitle:@"全部禁言" forState:UIControlStateNormal];
        [_muteAll setTitle:@"解除全部禁言" forState:UIControlStateSelected];
        [_muteAll setTitleColor:UIColorFromRGB(0x222222) forState:UIControlStateNormal];
        _muteAll.titleLabel.font = TextFont_14;
        _muteAll.backgroundColor = UIColorFromRGBA(0xF2F3F5, 1.0);
        [_muteAll addTarget:self action:@selector(muteAllAciton:)
                 forControlEvents:UIControlEventTouchUpInside];
        _muteAll.selected = _chatroomMute;
    }
    return _muteAll;
}

- (UIView *)bottomLineView {
    if (!_bottomLineView) {
        _bottomLineView = [[UIView alloc]init];
        _bottomLineView.backgroundColor = UIColorFromRGB(0xE6E7EB);
    }
    return _bottomLineView;
}
@end
