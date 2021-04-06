//
//  SKVObject.m
//  SafeKVObject
//
//  Created by Gdier￼ Zhang on 1/14/15.
//  Copyright (c) 2015 gdier.zh(at)gmail.com. All rights reserved.
//

#import "SKVObject.h"
#import <objc/runtime.h>

@interface SKVDefaultValue : NSObject <SKVValue>

@end

@implementation SKVDefaultValue

+ (SKVDefaultValue *)defaultValue {
    static SKVDefaultValue *s_instance = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        s_instance = [[SKVDefaultValue alloc] init];
    });
    
    return s_instance;
}

- (int)intValue {
    return 0;
}

- (unsigned int)unsignedIntValue {
    return 0;
}

- (long)longValue {
    return 0;
}

- (unsigned long)unsignedLongValue {
    return 0;
}

- (long long)longLongValue {
    return 0;
}

- (unsigned long long)unsignedLongLongValue {
    return 0;
}

- (float)floatValue {
    return 0;
}

- (double)doubleValue {
    return 0;
}

- (BOOL)boolValue {
    return NO;
}

- (NSInteger)integerValue {
    return 0;
}

- (NSUInteger)unsignedIntegerValue {
    return 0;
}

@end

@interface SKVObject ()

@property(strong, nonatomic) id value;

@end

@implementation SKVObject

+ (nullable instancetype)of:(id)object {
    if (nil == object || [object isKindOfClass:[NSNull class]])
        return nil;
    
    return [[self alloc] initWithObject:object];
}

+ (nullable instancetype)ofJSON:(NSString *)jsonString {
    if (nil == jsonString)
        return nil;
    
    id obj = [NSJSONSerialization JSONObjectWithData:[jsonString dataUsingEncoding:NSUTF8StringEncoding] options:0 error:nil];
    
    return [self of:obj];
}

- (nullable id)initWithObject:(id)object {
    self = [super init];
    if (self) {
        self.value = object;
    }
    return self;
}

- (nullable id)objectAtIndex:(NSUInteger)idx {
    return [self objectAtIndexedSubscript:idx];
}

- (nullable id)objectForKey:(id)key {
    return [self objectForKeyedSubscript:key];
}

- (nullable id)objectAtIndexedSubscript:(NSUInteger)idx {
    if ([self.value isKindOfClass:[NSArray class]]) {
        
        if ([self.value count] <= idx)
            return nil;
        
        return [SKVObject of:[self.value objectAtIndex:idx]];
        
    } else if ([self.value isKindOfClass:[NSDictionary class]]) {
        
        id value = [self.value objectForKey:[@(idx) description]];
        if (nil == value)
            return nil;
        
        return [SKVObject of:value];
    }

    
    return nil;
}

- (id)objectForKeyedSubscript:(id)key {
    if ([self.value isKindOfClass:[NSDictionary class]]) {
        
        id value = [self.value objectForKey:key];
        if (nil == value)
            return nil;
        
        return [SKVObject of:value];
        
    } else if ([self.value isKindOfClass:[NSArray class]]) {
        
        if (![key respondsToSelector:@selector(integerValue)])
            return nil;
        
        NSUInteger idx = [key integerValue];
        
        if ([self.value count] <= idx)
            return nil;
        
        return [SKVObject of:[self.value objectAtIndex:idx]];
    }
    
    return nil;
}

- (void)enumerateKeysAndObjectsUsingBlock:(void (^)(id key, id obj, BOOL *stop))block
{
    if ([self.value isKindOfClass:[NSDictionary class]]) {
        
        [self.value enumerateKeysAndObjectsUsingBlock:^(id key, id object, BOOL *stop) {
            block(key, [SKVObject of:object], stop);
        }];
        
    }
}

- (void)enumerateObjectsUsingBlock:(void (^)(id obj, NSUInteger idx, BOOL *stop))block {
    if ([self.value isKindOfClass:[NSArray class]]) {
        
        [self.value enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            block([SKVObject of:obj], idx, stop);
        }];
        
    }
}

- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state objects:(__unsafe_unretained id [])buffer count:(NSUInteger)len {
    return [self.value countByEnumeratingWithState:state objects:buffer count:len];
}

- (NSUInteger)count {
    if ([self.value isKindOfClass:[NSArray class]] || [self.value isKindOfClass:[NSDictionary class]]) {
        return [self.value count];
    }
    
    return 0;
}

- (NSString *)description {
    if ([self.value isKindOfClass:[NSString class]]) {
        return self.value;
    }

    if ([self.value isKindOfClass:[NSNumber class]]) {
        return [self.value description];
    }
    
    if (nil == self.value || [self.value isKindOfClass:[NSNull class]]) {
        return @"null";
    }
    
    if ([self.value isKindOfClass:[NSArray class]]) {
        NSString *result = @"[";
        NSUInteger count = [self count];

        for (NSUInteger i = 0; i < count; i ++) {
            result = [result stringByAppendingString:[self[i] description]];
            if (i != count - 1)
                result = [result stringByAppendingString:@","];
        }
        
        result = [result stringByAppendingString:@"]"];
        
        return result;
    }
    
    if ([self.value isKindOfClass:[NSDictionary class]]) {
        NSString *result = @"{";
        NSArray *keys = [self.value allKeys];
        NSUInteger count = [keys count];
        
        for (NSUInteger i = 0; i < count; i ++) {
            result = [result stringByAppendingFormat:@"%@:%@", keys[i], self[keys[i]]];
            if (i != count - 1)
                result = [result stringByAppendingString:@","];
        }
        
        result = [result stringByAppendingString:@"}"];
        
        return result;
    }
    
    return [super description];
}

- (BOOL)respondsToSelector:(SEL)aSelector {
    if ([super respondsToSelector:aSelector])
        return YES;
    
    struct objc_method_description hasMethod = protocol_getMethodDescription(@protocol(SKVValue), aSelector, NO, YES);
    
    if (NULL == hasMethod.name)
        return NO;

    return YES;
}

- (void)forwardInvocation:(NSInvocation *)anInvocation {
    SEL aSelector = [anInvocation selector];
    
    struct objc_method_description hasMethod = protocol_getMethodDescription(@protocol(SKVValue), aSelector, NO, YES);
    
    if (NULL != hasMethod.name) {
        if ([self.value respondsToSelector:aSelector]) {
            [anInvocation invokeWithTarget:self.value];
            
            return;
        }
    }
    
    [anInvocation invokeWithTarget:[SKVDefaultValue defaultValue]];
}

- (NSString *)stringValue {
    if ([self.value respondsToSelector:@selector(stringValue)])
        return [self.value stringValue];

    return [self description];
}

- (NSArray *)arrayValue {
    if ([self.value isKindOfClass:[NSArray class]])
        return self.value;
    
    return nil;
}

- (NSDictionary *)dictionaryValue {
    if ([self.value isKindOfClass:[NSDictionary class]])
        return self.value;
    
    return nil;
}

- (NSNumber *)numberValue {
    if ([self.value isKindOfClass:[NSNumber class]]) {
        return self.value;
    }
    return nil;
}

@end
