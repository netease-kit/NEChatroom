//
//  NTESUnMuteListViewController.m
//  NERtcAudioChatroom
//
//  Created by Netease on 2019/3/7.
//  Copyright © 2019年 netease. All rights reserved.
//

#import "NTESUnMuteListViewController.h"
#import "NTESUserInfoCell.h"
#import "UIView+NTES.h"


@interface NTESUnMuteListViewController ()

@end

@implementation NTESUnMuteListViewController

- (instancetype)initWithMembers:(nullable NSMutableArray <NIMChatroomMember *> *)members {
    if (self = [super init]) {
        [self setupData:members];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self refreshList];
}

- (void)refreshList {
    [self.tableview reloadData];
    self.emptyView.hidden = (self.showMembers.count != 0);
}

- (void)setupData:(NSMutableArray <NIMChatroomMember *> *)members {
    NSMutableArray *ret = [NSMutableArray array];
    [members enumerateObjectsUsingBlock:^(NIMChatroomMember * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (!obj.isTempMuted) {
            [ret addObject:obj];
        }
    }];
    self.showMembers = ret;
    self.navBar.navType = NTESBanSpeakNavTypeArrow;
}

#pragma mark - <UITableViewDelegate, UITableViewDataSource>
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NIMChatroomMember *member = self.showMembers[indexPath.row];
    if (_delegate && [_delegate respondsToSelector:@selector(didSelectMember:)]) {
        [_delegate didSelectMember:member];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
