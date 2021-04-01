//
//  SKVObject.h
//  SafeKVObject
//
//  Created by Gdier￼ Zhang on 1/14/15.
//  Copyright (c) 2015 gdier.zh(at)gmail.com. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol SKVValue <NSObject>

@optional
- (int)intValue;
- (unsigned int)unsignedIntValue;
- (long)longValue;
- (unsigned long)unsignedLongValue;
- (long long)longLongValue;
- (unsigned long long)unsignedLongLongValue;
- (float)floatValue;
- (double)doubleValue;
- (BOOL)boolValue;
- (NSInteger)integerValue;
- (NSUInteger)unsignedIntegerValue;
- (NSString *)stringValue;

@end

@interface SKVObject : NSObject <SKVValue, NSFastEnumeration>

+ (nullable instancetype)of:(id)object;
+ (nullable instancetype)ofJSON:(NSString *)jsonString;

- (nullable id)objectAtIndex:(NSUInteger)idx;
- (nullable id)objectForKey:(id)key;

- (nullable id)objectAtIndexedSubscript:(NSUInteger)idx;
- (nullable id)objectForKeyedSubscript:(id)key;
- (void)enumerateKeysAndObjectsUsingBlock:(void (^)(id key, id obj, BOOL *stop))block;
- (void)enumerateObjectsUsingBlock:(void (^)(id obj, NSUInteger idx, BOOL *stop))block;

// For array & dictionary
@property (readonly) NSUInteger count;

@property (readonly, copy) NSArray *arrayValue;
@property (readonly, copy) NSDictionary *dictionaryValue;
@property (readonly, copy) NSNumber     *numberValue;

@end

NS_ASSUME_NONNULL_END
