//
//  NTESLiveChatView.m
//  NIMLiveDemo
//
//  Created by chris on 16/3/28.
//  Copyright © 2016年 Netease. All rights reserved.
//

#import "NTESLiveChatView.h"
#import "UIView+NTES.h"
#import "NTESMessageModel.h"
#import "NTESLiveChatTextCell.h"

@interface NTESLiveChatView()<UITableViewDelegate,UITableViewDataSource,UIGestureRecognizerDelegate>
{
    CGRect _preRect;
}
@property (nonatomic,strong) NSMutableArray<NTESMessageModel *> *messages;

@property (nonatomic,strong) NSMutableArray *pendingMessages;   //缓存的插入消息,聊天室需要在另外个线程计算高度,减少UI刷新

@end

@implementation NTESLiveChatView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _messages = [[NSMutableArray alloc] init];
        _pendingMessages = [[NSMutableArray alloc] init];
        [self addSubview:self.tableView];
        
        UITapGestureRecognizer *tap=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doTap:)];
        tap.delegate=self;
        [self addGestureRecognizer:tap];

    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    if (!CGRectEqualToRect(_preRect, self.bounds)) {
        _tableView.frame = self.bounds;
        _tableView.contentInset = UIEdgeInsetsMake(_tableView.height, 0, 0, 0);
        _preRect = self.bounds;
    }
}

-(void)doTap:(UITapGestureRecognizer*)recognizer
{
    CGPoint point = [recognizer locationInView:self.superview];
    if (self.delegate && [self.delegate respondsToSelector:@selector(onTapChatView:)]) {
        [self.delegate onTapChatView:point];
    }
}

-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if ([NSStringFromClass([touch.view class]) isEqualToString:@"UITableViewCellContentView"]) {
        return NO;//关闭手势
    }
    return YES;
}

- (void)addMessages:(NSArray<NIMMessage *> *)messages
{
    if (messages.count) {
        [self caculateHeight:messages];
    }
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.messages.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NTESMessageModel *model = self.messages[indexPath.row];
    return (model.size.height + 8.0 + 9.0);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NTESLiveChatTextCell *cell = [tableView dequeueReusableCellWithIdentifier:@"chat"];
    NTESMessageModel *model = self.messages[indexPath.row];
    [cell refresh:model];
    return cell;
}

#pragma mark - Get
- (UITableView *)tableView
{
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:self.bounds style:UITableViewStylePlain];
        [_tableView registerClass:[NTESLiveChatTextCell class] forCellReuseIdentifier:@"chat"];
        _tableView.delegate = self;
        _tableView.showsVerticalScrollIndicator = NO;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.dataSource = self;
        _tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
        _tableView.backgroundColor = [UIColor clearColor];
    }
    return _tableView;
}


#pragma mark - Private

- (void)caculateHeight:(NSArray<NIMMessage *> *)messages
{
    dispatch_async(NTESMessageDataPrepareQueue(), ^{
        //后台线程处理宽度计算，处理完之后同步抛到主线程插入
        BOOL noPendingMessage = self.pendingMessages.count == 0;
        [self.pendingMessages addObjectsFromArray:messages];
        if (noPendingMessage)
        {
            [self processPendingMessages];
        }
    });
}

- (void)processPendingMessages
{
    __weak typeof(self) weakSelf = self;
    __block CGFloat width = 0;
    NSUInteger pendingMessageCount = self.pendingMessages.count;
    if (!weakSelf || pendingMessageCount== 0) {
        return;
    }
    
    ntes_main_sync_safe(^{
        if (weakSelf.tableView.isDecelerating || weakSelf.tableView.isDragging)
        {
            //滑动的时候为保证流畅，暂停插入
            NSTimeInterval delay = 1;
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC)), NTESMessageDataPrepareQueue(), ^{
                [weakSelf processPendingMessages];
            });
            return;
        }
        width = self.width;
    });

    //获取一定量的消息计算高度，并扔回到主线程
    static NSInteger NTESMaxInsert = 2;
    NSArray *insert = nil;
    NSRange range;
    if (pendingMessageCount > NTESMaxInsert)
    {
        range = NSMakeRange(0, NTESMaxInsert);
    }
    else
    {
        range = NSMakeRange(0, pendingMessageCount);
    }
    insert = [self.pendingMessages subarrayWithRange:range];
    [self.pendingMessages removeObjectsInRange:range];
    
    NSMutableArray *models = [[NSMutableArray alloc] init];
    for (NIMMessage *message in insert)
    {
        NTESMessageModel *model = [[NTESMessageModel alloc] init];
        model.message = message;
        if ([message.remoteExt[@"type"] integerValue] == 1) {
            model.type = NTESMessageNotication;
        }
        [model caculate:width - 2*8.0];
        [models addObject:model];
    }
    
    NSUInteger leftPendingMessageCount = self.pendingMessages.count;
    dispatch_sync(dispatch_get_main_queue(), ^{
        [weakSelf addModels:models];
    });
    
    if (leftPendingMessageCount)
    {
        NSTimeInterval delay = 0.1;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC)), NTESMessageDataPrepareQueue(), ^{
            [weakSelf processPendingMessages];
        });
    }
}

- (void)addModels:(NSArray<NTESMessageModel *> *)models
{
    NSInteger count = self.messages.count;
    [self.messages addObjectsFromArray:models];
    
    NSMutableArray *insert = [[NSMutableArray alloc] init];
    for (NSInteger index = count; index < count+models.count; index++) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
        [insert addObject:indexPath];
    }
    
    [self.tableView beginUpdates];
    [self.tableView insertRowsAtIndexPaths:insert withRowAnimation:UITableViewRowAnimationFade];
    [self.tableView endUpdates];
    [self.tableView layoutIfNeeded];
    [self scrollToBottom:models];
}

- (void)scrollToBottom:(NSArray<NTESMessageModel *> *)newModels
{
    UIEdgeInsets insets = self.tableView.contentInset;
    if (insets.top != 0 ) {
        CGFloat height = 0;
        for (NTESMessageModel *model in newModels) {
            height += (model.size.height + 8.0 + 9.0);
        }
        CGFloat top = insets.top - height;
        insets.top = MAX(top, 0);
        [UIView animateWithDuration:0.25 animations:^{
            self.tableView.contentInset = insets;
        }];
    } else {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:_messages.count - 1 inSection:0];
        [_tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }
}

static const void * const NTESDispatchMessageDataPrepareSpecificKey = &NTESDispatchMessageDataPrepareSpecificKey;
dispatch_queue_t NTESMessageDataPrepareQueue()
{
    static dispatch_queue_t queue;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        queue = dispatch_queue_create("nim.live.demo.message.queue", 0);
        dispatch_queue_set_specific(queue, NTESDispatchMessageDataPrepareSpecificKey, (void *)NTESDispatchMessageDataPrepareSpecificKey, NULL);
    });
    return queue;
}


@end



