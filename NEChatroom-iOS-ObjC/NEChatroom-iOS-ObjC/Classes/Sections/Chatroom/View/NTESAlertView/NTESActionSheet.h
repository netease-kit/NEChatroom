//
//  NTESActionSheet.h
//  AlertSheetView
//
//  Created by Simon Blue on 2019/1/31.
//  Copyright © 2019年 netease. All rights reserved.
//

#import <UIKit/UIKit.h>
/**
 item的类型
 
 - LNNTESActionSheetItemNoraml: 默认都是普通类型的
 */
typedef  NS_OPTIONS(NSUInteger,NTESActionSheetItemType){
    NTESActionSheetItemNoraml = 0,    //普通
    NTESActionSheetItemDelete,        //删除
    NTESActionSheetItemSure,          //确定
};

@interface NTESActionSheetModel : NSObject
/**
 标题
 */
@property (nonatomic, copy) NSString *title;

/**
 介绍，可为空
 */
@property (nonatomic, copy) NSString *subTitle;

/**
 标示id
 */
@property (nonatomic, assign) int sheetId;

/**
 选择item的类型
 */
@property (nonatomic, assign) NTESActionSheetItemType itemType;


/**
 这个model所在的item被点击了触发这个block
 */
@property (nonatomic, copy) void(^actionBlock)(void);

@end

@interface NTESActionSheet : UIView

/**
 显示sheetView
 
 @param desc 头部描述
 @param models 操作的item数据
 @param action 操作每个item时触发的事件
 */
+ (void)showWithDesc:(NSString*)desc actionModels:(NSArray<NTESActionSheetModel*> *)models action:(void(^)(NTESActionSheetModel *model))action;

+ (void)showWithDesc:(NSString *)desc
        actionModels:(NSArray<NTESActionSheetModel *> *)models
              action:(void (^)(NTESActionSheetModel *))action
              cancel:(dispatch_block_t)cancel ;

/**
 隐藏
 */
+ (void)hide;

@end
