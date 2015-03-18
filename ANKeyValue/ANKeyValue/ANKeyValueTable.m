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

static ANKeyValueCache *GlobalDataCache;

@interface ANKeyValueTable()
{
    __strong ANKeyValueData *_keyValueData;
    __strong NSString *_dataName;
    __strong NSString *_dataVersion;
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

    ANKeyValueCache *cache = [self dataCache];
    ANKeyValueData *data = [cache object:name version:version];
    if (nil == data) {
        data = [ANKeyValueData data:name version:version domain:PERSISTENT_DOMAIN];
        if (nil != data) {
            [cache setObject:data name:name version:version];
        }
    }
    return [[ANKeyValueTable alloc] initWithName:name version:version];
}

+ (ANKeyValueCache *)dataCache
{
    if (nil == GlobalDataCache) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            GlobalDataCache = [[ANKeyValueCache alloc] init];
            GlobalDataCache.delegate = GlobalDataCache;
            [GlobalDataCache preloadWithDomain:PERSISTENT_DOMAIN];
            
            /*
            [[NSNotificationCenter defaultCenter] addObserver:GlobalDataCache
                                                     selector:@selector(test:)
                                                         name:UIApplicationDidReceiveMemoryWarningNotification
                                                       object:nil];
             */
        });
    }
    return GlobalDataCache;
}

- (ANKeyValueData *)keyValueData
{
    if (nil != _keyValueData) {
        return _keyValueData;
    } else {
        if (![_dataName isKindOfClass:[NSString class]] || 0 == [_dataName length]) {
            return nil;
        }
        ANKeyValueCache *cache = [ANKeyValueTable dataCache];
        
        _keyValueData = [cache object:_dataName version:_dataVersion];
        if (nil == _keyValueData) {
            ANKeyValueData *data = [ANKeyValueData data:_dataName version:_dataVersion domain:PERSISTENT_DOMAIN];
            if (nil != data) {
                [cache setObject:data name:_dataName version:_dataVersion];
                // 在模拟器上，启用内存memory warning功能，可能会导致setObject后cache马上触发evict Object，
                // 所以这里刻意把_keyValueData和notification延后设置，这样，即使evict Object在这里
                // 被同步方式提前触发，_keyValueDatay也能因为是后面set而继续可用，不会导致_keyValueData为nil时，
                // 重新生成一个又被evict Object触发马上重新设置为nil，陷入不可用的循环，springox(20150316)
                _keyValueData = data;
            }
        }
        
        // 这里暂时不能做keyValueData的主动释放，由于keyValueData有timer和退入后台的监听，
        // 所以尽量谨慎对keyValueData的释放，tencent:jiachunke(20150318)
        /*
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(cacheWillEvictObjectNotification:)
                                                     name:kANKeyValueCacheWillEvictObjectNotification
                                                   object:nil];
         */
        
        return _keyValueData;
    }
}

- (id)initWithData:(ANKeyValueData *)data
{
    self = [super init];
    if (self) {
        _keyValueData = data;
    }
    return self;
}

- (id)initWithName:(NSString *)name version:(NSString *)version
{
    self = [super init];
    if (self) {
        _dataName = name;
        _dataVersion = version;
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [_keyValueData archiveNow];
}

- (void)cacheWillEvictObjectNotification:(NSNotification *)not
{
    if (nil != _keyValueData && not.object == _keyValueData) {
        _keyValueData = nil;
        [[NSNotificationCenter defaultCenter] removeObserver:self];
    }
}

- (void)synchronous
{
    [self synchronous:YES];
}

- (void)synchronous:(BOOL)atomically
{
    if (atomically) {
        [[self keyValueData] setNeedToArchive];
    } else {
        [[self keyValueData] syncArchive];
    }
}

- (BOOL)isArchiving
{
    return [[self keyValueData] isArchiving] || [[self keyValueData] isWillArchive];
}

- (void)clear
{
    [[self keyValueData] clearData];
}

- (void)setInt:(int)value withKey:(id <NSCopying>)key
{
    NSNumber *intNum = [NSNumber numberWithInt:value];
    [[self keyValueData] setValue:intNum withKey:key];
    
    [self synchronous];
}

- (void)setInteger:(NSInteger)value withKey:(id <NSCopying>)key
{
    NSNumber *integerNum = [NSNumber numberWithInteger:value];
    [[self keyValueData] setValue:integerNum withKey:key];
    
    [self synchronous];
}

- (void)setFloat:(float)value withKey:(id <NSCopying>)key
{
    NSNumber *floatNum = [NSNumber numberWithFloat:value];
    [[self keyValueData] setValue:floatNum withKey:key];
    
    [self synchronous];
}

- (void)setDouble:(double)value withKey:(id <NSCopying>)key
{
    NSNumber *doubleNum = [NSNumber numberWithDouble:value];
    [[self keyValueData] setValue:doubleNum withKey:key];
    
    [self synchronous];
}

- (void)setBool:(BOOL)value withKey:(id <NSCopying>)key
{
    NSNumber *boolNum = [NSNumber numberWithBool:value];
    [[self keyValueData] setValue:boolNum withKey:key];
    
    [self synchronous];
}

- (void)setValue:(id <NSCoding, ANKeyValue>)value withKey:(id <NSCopying>)key
{
    [[self keyValueData] setValue:value withKey:key];
    
    [self synchronous];
}

- (int)intWithKey:(id <NSCopying>)key
{
    NSNumber *value = [[self keyValueData] valueWithKey:key];
    if ([value respondsToSelector:@selector(intValue)]) {
        return [value intValue];
    }
    return 0;
}

- (NSInteger)integerWithKey:(id <NSCopying>)key
{
    NSNumber *value = [[self keyValueData] valueWithKey:key];
    if ([value respondsToSelector:@selector(integerValue)]) {
        return [value integerValue];
    }
    return 0;
}

- (float)floatWithKey:(id <NSCopying>)key
{
    NSNumber *value = [[self keyValueData] valueWithKey:key];
    if ([value respondsToSelector:@selector(floatValue)]) {
        return [value floatValue];
    }
    return 0;
}

- (double)doubleWithKey:(id <NSCopying>)key
{
    NSNumber *value = [[self keyValueData] valueWithKey:key];
    if ([value respondsToSelector:@selector(doubleValue)]) {
        return [value doubleValue];
    }
    return 0;
}

- (id)valueWithKey:(id <NSCopying>)key
{
    return [[self keyValueData] valueWithKey:key];
}

- (NSArray *)allKeys
{
    return [[self keyValueData] allKeys];
}

- (NSArray *)allValues
{
    return [[self keyValueData] allValues];
}

- (void)removeValueWithKey:(id <NSCopying>)key
{
    [[self keyValueData] removeValueWithKey:key];
    
    [self synchronous];
}

- (void)removeAllValues
{
    [self clear];
}

@end
