//
//  NTESDemoServiceTask.h
//  NERtcAudioChatroom
//
//  Created by Simon Blue on 2019/1/15.
//  Copyright © 2019年 netease. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol NTESDemoServiceTask <NSObject>
- (NSURLRequest *)taskRequest;
- (void)onGetResponse:(id)jsonObject
                error:(NSError *)error;
@end


