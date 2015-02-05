//
//  ANKeyValueTable.m
//  Araneo
//
//  Created by SpringOx on 14/12/12.
//  Copyright (c) 2014年 SpringOx. All rights reserved.
//

#import "ANKeyValueTable.h"
#import "ANKeyValueCache.h"
#import "ANKeyValueData.h"

#define PERSISTENT_DOMAIN     @"KeyValueStorage"

static ANKeyValueCache *GlobalTableCache;

@interface ANKeyValueTable()
{
    __strong ANKeyValueData *_keyValueData;
}

@end

@implementation ANKeyValueTable

+ (id)tableWithName:(NSString *)name version:(NSString *)version
{
    if (![name isKindOfClass:[NSString class]] || 0 == [name length]) {
        return nil;
    }
    
    if (![version isKindOfClass:[NSString class]] || 0 == [version length]) {
        version = @"";
    }
    
    ANKeyValueCache *cache = [self tableCache];
    
    ANKeyValueTable *table = [cache object:name version:version];
    if (nil == table) {
        ANKeyValueData *data = [ANKeyValueData data:name version:version domain:PERSISTENT_DOMAIN];
        table = [[ANKeyValueTable alloc] initWithData:data];
        [cache setObject:table name:name version:version];
    }
    return table;
}

+ (ANKeyValueCache *)tableCache
{
    if (nil == GlobalTableCache) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            GlobalTableCache = [[ANKeyValueCache alloc] init];
            
            [GlobalTableCache preloadWithDomain:PERSISTENT_DOMAIN];
        });
    }
    return GlobalTableCache;
}

- (id)initWithData:(ANKeyValueData *)data
{
    self = [super init];
    if (self) {
        _keyValueData = data;
    }
    return self;
}

- (void)dealloc
{
    // do nothing
}

- (void)synchronous
{
    [self synchronous:YES];
}

- (void)synchronous:(BOOL)atomically
{
    if (atomically) {
        [_keyValueData setNeedToArchive];
    } else {
        [_keyValueData syncArchive];
    }
}

- (BOOL)isArchiving
{
    return [_keyValueData isArchiving] || [_keyValueData isWillArchive];
}

- (void)clear
{
    [_keyValueData clearData];
}

- (void)setInt:(int)value withKey:(id <NSCopying>)key
{
    NSNumber *intNum = [NSNumber numberWithInt:value];
    [_keyValueData setValue:intNum withKey:key];
    
    [self synchronous];
}

- (void)setInteger:(NSInteger)value withKey:(id <NSCopying>)key
{
    NSNumber *integerNum = [NSNumber numberWithInteger:value];
    [_keyValueData setValue:integerNum withKey:key];
    
    [self synchronous];
}

- (void)setFloat:(float)value withKey:(id <NSCopying>)key
{
    NSNumber *floatNum = [NSNumber numberWithFloat:value];
    [_keyValueData setValue:floatNum withKey:key];
    
    [self synchronous];
}

- (void)setDouble:(double)value withKey:(id <NSCopying>)key
{
    NSNumber *doubleNum = [NSNumber numberWithDouble:value];
    [_keyValueData setValue:doubleNum withKey:key];
    
    [self synchronous];
}

- (void)setBool:(BOOL)value withKey:(id <NSCopying>)key
{
    NSNumber *boolNum = [NSNumber numberWithBool:value];
    [_keyValueData setValue:boolNum withKey:key];
    
    [self synchronous];
}

- (void)setValue:(id <NSCoding, ANKeyValue>)value withKey:(id <NSCopying>)key
{
    [_keyValueData setValue:value withKey:key];
    
    [self synchronous];
}

- (int)intWithKey:(id <NSCopying>)key
{
    NSNumber *value = [_keyValueData valueWithKey:key];
    if ([value respondsToSelector:@selector(intValue)]) {
        return [value intValue];
    }
    return 0;
}

- (NSInteger)integerWithKey:(id <NSCopying>)key
{
    NSNumber *value = [_keyValueData valueWithKey:key];
    if ([value respondsToSelector:@selector(integerValue)]) {
        return [value integerValue];
    }
    return 0;
}

- (float)floatWithKey:(id <NSCopying>)key
{
    NSNumber *value = [_keyValueData valueWithKey:key];
    if ([value respondsToSelector:@selector(floatValue)]) {
        return [value floatValue];
    }
    return 0;
}

- (double)doubleWithKey:(id <NSCopying>)key
{
    NSNumber *value = [_keyValueData valueWithKey:key];
    if ([value respondsToSelector:@selector(doubleValue)]) {
        return [value doubleValue];
    }
    return 0;
}

- (id)valueWithKey:(id <NSCopying>)key
{
    return [_keyValueData valueWithKey:key];
}

- (NSArray *)allKeys
{
    return [_keyValueData allKeys];
}

- (NSArray *)allValues
{
    return [_keyValueData allValues];
}

- (void)removeValueWithKey:(id <NSCopying>)key
{
    [_keyValueData removeValueWithKey:key];
    
    [self synchronous];
}

- (void)removeAllValues
{
    [self clear];
}

@end
