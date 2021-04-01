//
//  NTESMicInviteeListViewController.m
//  NERtcAudioChatroom
//
//  Created by Simon Blue on 2019/1/29.
//  Copyright © 2019年 netease. All rights reserved.
//

#import "NTESMicInviteeListViewController.h"
#import "NTESMicInfo.h"
#import "NSDictionary+NTESJson.h"
#import "NSString+NTES.h"
#import "NTESChatroomQueueHelper.h"
#import "UIView+NTES.h"


#import "NTESUserInfoCell.h"


@interface NTESMicInviteeListViewController ()

@property (nonatomic, strong) NIMChatroom *chatroom;
@property (nonatomic, strong) NSMutableArray <NTESMicInfo *> *micMembers; //上麦成员
@property (nonatomic, strong) NTESMicInfo *dstMicInfo; //目标麦位

@end

@implementation NTESMicInviteeListViewController

- (instancetype)initWithChatroom:(NIMChatroom *)chatroom
                      micMembers:(NSMutableArray <NTESMicInfo *> *)micMembers
                      dstMicInfo:(NTESMicInfo *)dstMicInfo {
    if (self = [super init]) {
        _chatroom = chatroom;
        _dstMicInfo = dstMicInfo;
        _micMembers = micMembers;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navBar.title = @"选择成员";
    self.emptyView.info = @"暂无群成员～";
    [self fetchChatroomMembers];
}

- (void)setUpUI {
    self.navigationController.navigationBarHidden = YES;
    [self.view addSubview:self.navBar];
    [self.view addSubview:self.tableview];
    [self.view addSubview:self.emptyView];
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
              [weakSelf.tableview reloadData];
              weakSelf.emptyView.hidden = (weakSelf.showMembers.count != 0);
          } else {
              NELPLogInfo(@"成员信息拉取失败.[%@]", error);
          }
    }];
}

- (void)processMembers:(NSArray<NIMChatroomMember *> *)members {
    NSMutableArray *ret = [NSMutableArray array];
    __weak typeof(self) weakSelf = self;
    [members enumerateObjectsUsingBlock:^(NIMChatroomMember * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NTESMicInfo *info = [weakSelf macInfoWithMember:obj];
        if (!info || info.micStatus == NTESMicStatusConnecting) {
            [ret addObject:obj];
        }
    }];
    self.showMembers = ret;
}

- (NTESMicInfo *)macInfoWithMember:(NIMChatroomMember *)member {
    __block NTESMicInfo *ret = nil;
    [_micMembers enumerateObjectsUsingBlock:^(NTESMicInfo * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        BOOL userIdEqual = [member.userId isEqualToString:obj.userInfo.account];
        BOOL userOnMic = ![NTESChatroomQueueHelper checkMicEmptyWithMicInfo:obj];
        if (userIdEqual && userOnMic) {
            ret = obj;
            *stop = YES;
        }
    }];
    return ret;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

#pragma mark - <UITableViewDelegate,UITableViewDataSource>
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NIMChatroomMember *member = [self.showMembers objectAtIndex:indexPath.row];
    NTESUserInfo *userInfo = [[NTESUserInfo alloc] init];
    userInfo.account = member.userId;
    userInfo.nickName = member.roomNickname;
    userInfo.icon = member.roomAvatarThumbnail;
    _dstMicInfo.userInfo = userInfo;
    if (_delegate && [_delegate respondsToSelector:@selector(onSelectInviteeUserWithMicInfo:)]) {
        [_delegate onSelectInviteeUserWithMicInfo:_dstMicInfo];
    }
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}
@end
