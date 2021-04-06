//
//  NTESLyricFrame.m
//  NEChatroom-iOS-ObjC
//
//  Created by Wenchao Ding on 2021/1/25.
//  Copyright © 2021 netease. All rights reserved.
//

#import "NTESLyricFrame.h"

@implementation NTESLyricFrame

- (BOOL)isEqual:(id)object {
    if (![object isKindOfClass:NTESLyricFrame.class]) {
        return NO;
    }
    NTESLyricFrame *other = object;
    if (other.time != self.time) return NO;
    if (other.content != self.content) return NO;
    if (![other.content isEqual:self.content]) return NO;
    return YES;
}

- (NSUInteger)hash {
    return @(self.time).hash ^ self.content.hash;
}

+ (NSArray<NTESLyricFrame *> *)arrayWithContentsOfFile:(NSString *)path {
    // 创建可变数组存放歌词模型
    NSMutableArray<NTESLyricFrame *> *lyrics = NSMutableArray.array;
    
    NSError *error;
    NSString *lyricStr = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:&error];
    
    if (error)  {
        NSLog(@"Parse lyrics file error: %@", error);
        return [NSArray arrayWithArray:lyrics];
    }
    if (!lyricStr.length) return [NSArray arrayWithArray:lyrics];
    return [self arrayWithContents:lyricStr];
}

+ (NSArray<NTESLyricFrame *> *)arrayWithContents:(NSString *)content {
    
    NSMutableArray<NTESLyricFrame *> *lyrics = NSMutableArray.array;
    // 将歌词总体字符串按行拆分开，每句都作为一个数组元素存放到数组中
    NSArray *lineStrs = [content componentsSeparatedByString:@"\n"];
    
    // 设置歌词时间正则表达式格式
    NSString *pattern = @"\\[[0-9]{2}:[0-9]{2}.[0-9]{2}\\]";
    NSRegularExpression *reg = [NSRegularExpression regularExpressionWithPattern:pattern options:0 error:NULL];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"[mm:ss.SS]";
    NSDate *initDate = [formatter dateFromString:@"[00:00.00]"];
    // 遍历歌词字符串数组
    for (NSString *lineStr in lineStrs) {
        
        NSArray *results = [reg matchesInString:lineStr options:0 range:NSMakeRange(0, lineStr.length)];
        
        // 歌词内容
        NSTextCheckingResult *lastResult = [results lastObject];
        NSString *content = [[lineStr substringFromIndex:lastResult.range.location + lastResult.range.length] stringByReplacingOccurrencesOfString:@"\r" withString:@""]; // 去掉多余换行
        
        // 每一个结果的range
        for (NSTextCheckingResult *result in results) {
            NSString *time = [lineStr substringWithRange:result.range];
            NSDate *timeDate = [formatter dateFromString:time];
            
            if (content.length && timeDate) {
                // 创建模型
                NTESLyricFrame *lyric = [[NTESLyricFrame alloc] init];
                lyric.content = content;
                // 歌词的开始时间
                lyric.time = [timeDate timeIntervalSinceDate:initDate];
                
                // 将歌词对象添加到模型数组汇总
                [lyrics addObject:lyric];
            }
        }
    }
    
    // 按照时间正序排序
    NSSortDescriptor *sortDes = [NSSortDescriptor sortDescriptorWithKey:@"time" ascending:YES];
    [lyrics sortUsingDescriptors:@[sortDes]];
    return [NSArray arrayWithArray:lyrics];
}

@end
