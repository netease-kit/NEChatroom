//
//  NTESMusicPanelLyricLoader.m
//  NEChatroom-iOS-ObjC
//
//  Created by Wenchao Ding on 2021/2/3.
//  Copyright © 2021 netease. All rights reserved.
//

#import "NTESMusicPanelLyricLoader.h"

@interface NTESMusicPanelLyricLoader ()

@property (nonatomic, strong) NSCache *cache;

@end

@implementation NTESMusicPanelLyricLoader

- (instancetype)init {
    self = [super init];
    if (self) {
        self.cache = [[NSCache alloc] init];
        self.cache.countLimit = 100;
    }
    return self;
}

- (void)loadWithURL:(NSURL *)URL completion:(NTESMusicPanelLoadLyricCompletionBlock)completion {
    NSString *content = [self.cache objectForKey:URL];
    if (content) {
        return completion(content);
    }
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSError *error;
        NSString *content = [NSString stringWithContentsOfURL:URL encoding:NSUTF8StringEncoding error:&error];
        if (error) {
            return NELPLogError(@"Error load lyric: %@", error);
        }
        [self.cache setObject:content forKey:URL];
        dispatch_async(dispatch_get_main_queue(), ^{
            completion(content);
        });
    });
}

@end
