//
//  ANKeyValueTable.m
//  Araneo
//
//  Created by SpringOx on 14/12/12.
//  Copyright (c) 2014年 SpringOx. All rights reserved.
//

#import "ANKeyValueTable.h"
#import "ANKeyValueData.h"
#import "ANMemoryPage.h"
#import "AESCrypt.h"

#define PERSISTENT_DOMAIN     @"KeyValueStorage"
#define AES_CRYPT_PASSWORD    @"xq$\"1#.H"

static ANMemoryPage *GlobalDataCache;

@interface ANKeyValueTable()
{
@private
    __strong ANKeyValueData *_keyValueData;
    __strong NSString *_dataName;
    __strong NSString *_dataVersion;
    ANPersistentLevel _dataLevel;
}

@end

@implementation ANKeyValueTable

+ (id)tableWithName:(NSString *)name version:(NSString *)version resumable:(BOOL)resumable
{
    if (![name isKindOfClass:[NSString class]] || 0 == [name length]) {
        return nil;
    }
    
    if (![version isKindOfClass:[NSString class]] || 0 == [version length]) {
        version = @"";
    }

    // 预先加载共享核心data，springox(20151201)
    ANPersistentLevel level = ANPersistentLevelResumableCaches;
    if (!resumable) {
        level = ANPersistentLevelApplicationSupport;
    }
    NSString *cacheName = [NSString stringWithFormat:@"L%u-%@", level, name];
    ANMemoryPage *cache = [self dataCache];
    @synchronized (self) {
        ANKeyValueData *data = [cache object:cacheName version:version];
        if (nil == data) {
            data = [ANKeyValueData data:name version:version domain:PERSISTENT_DOMAIN level:level];
            [cache setObject:data name:cacheName version:version];
        }
    }

    // 创建一个表对象作为数据交互接口，springox(20151201)
    return [[ANKeyValueTable alloc] initWithName:name version:version level:level];
}

+ (id)tableForUser:(NSString *)name version:(NSString *)version
{
    if (![name isKindOfClass:[NSString class]] || 0 == [name length]) {
        return nil;
    }
    
    if (![version isKindOfClass:[NSString class]] || 0 == [version length]) {
        version = @"";
    }
    
    // 预先加载共享核心data，springox(20151201)
    ANPersistentLevel level = ANPersistentLevelUserDocument;
    NSString *cacheName = [NSString stringWithFormat:@"L%u-%@", level, name];
    ANMemoryPage *cache = [self dataCache];
    @synchronized (self) {
        ANKeyValueData *data = [cache object:cacheName version:version];
        if (nil == data) {
            data = [ANKeyValueData data:name version:version domain:PERSISTENT_DOMAIN level:level];
            [cache setObject:data name:cacheName version:version];
        }
    }
    
    // 创建一个表对象作为数据交互接口，springox(20151201)
    return [[ANKeyValueTable alloc] initWithName:name version:version level:level];
}

+ (id)userDefaultTable
{
    static ANKeyValueTable *defTable;
    @synchronized(self) {
        if (nil == defTable) {
            defTable = [self tableForUser:@"UserDefault" version:@"1.0.0"];
        }
    }
    return defTable;
}


+ (ANMemoryPage *)dataCache
{
    if (nil == GlobalDataCache) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            
            GlobalDataCache = [[ANMemoryPage alloc] init];
        });
    }
    return GlobalDataCache;
}

+ (void)clearResumableTables
{
    [ANKeyValueData clearCache:PERSISTENT_DOMAIN level:ANPersistentLevelResumableCaches];
}

+ (void)clearAllLevelTables
{
    [ANKeyValueData clearCache:PERSISTENT_DOMAIN level:ANPersistentLevelResumableCaches];
    [ANKeyValueData clearCache:PERSISTENT_DOMAIN level:ANPersistentLevelApplicationSupport];
    [ANKeyValueData clearCache:PERSISTENT_DOMAIN level:ANPersistentLevelUserDocument];
}

- (ANKeyValueData *)keyValueData
{
    if (nil != _keyValueData) {
        return _keyValueData;
    } else {
        if (![_dataName isKindOfClass:[NSString class]] || 0 == [_dataName length]) {
            return nil;
        }

        NSString *cacheName = [NSString stringWithFormat:@"L%u-%@", _dataLevel, _dataName];
        ANMemoryPage *cache = [[self class] dataCache];
        _keyValueData = [cache object:cacheName version:_dataVersion];
        if (nil == _keyValueData) {
            ANKeyValueData *data = [ANKeyValueData data:_dataName version:_dataVersion domain:PERSISTENT_DOMAIN level:_dataLevel];
            if (nil != data) {
                [cache setObject:data name:cacheName version:_dataVersion];
                // 在模拟器上，启用内存memory warning功能，可能会导致setObject后cache马上触发evict Object，
                // 所以这里刻意把_keyValueData和notification延后设置，这样，即使evict Object在这里
                // 被同步方式提前触发，_keyValueData也能因为是后面set而继续可用，不会导致_keyValueData为nil时，
                // 重新生成一个又被evict Object触发马上重新设置为nil，陷入不可用的循环，springox(20150316)
                _keyValueData = data;
            }
        }
        
        return _keyValueData;
    }
}

#pragma mark -
- (id)initWithData:(ANKeyValueData *)data
{
    self = [super init];
    if (self) {
        _keyValueData = data;
    }
    return self;
}

- (id)initWithName:(NSString *)name version:(NSString *)version level:(ANPersistentLevel)level
{
    self = [super init];
    if (self) {
        _dataName = name;
        _dataVersion = version;
        _dataLevel = level;
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

- (void)synchronize
{
    // 默认强制持久化操作，springox(20150618)
    [self synchronize:NO];
}

- (void)synchronize:(BOOL)atomically
{
    if (atomically) {
        [[self keyValueData] setNeedToArchive:self];
    } else {
        [[self keyValueData] fireArchive];
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

#pragma mark -
- (void)setValue:(id <NSCoding, ANKeyValue>)value withKey:(id <NSCopying>)key
{
    [[self keyValueData] setValue:value withKey:key];
    
    [self synchronize:YES];
}

- (void)setInt:(int)value withKey:(id <NSCopying>)key
{
    NSNumber *intNum = [NSNumber numberWithInt:value];
    [[self keyValueData] setValue:intNum withKey:key];
    
    [self synchronize:YES];
}

- (void)setInteger:(NSInteger)value withKey:(id <NSCopying>)key
{
    NSNumber *integerNum = [NSNumber numberWithInteger:value];
    [[self keyValueData] setValue:integerNum withKey:key];
    
    [self synchronize:YES];
}

- (void)setFloat:(float)value withKey:(id <NSCopying>)key
{
    NSNumber *floatNum = [NSNumber numberWithFloat:value];
    [[self keyValueData] setValue:floatNum withKey:key];
    
    [self synchronize:YES];
}

- (void)setDouble:(double)value withKey:(id <NSCopying>)key
{
    NSNumber *doubleNum = [NSNumber numberWithDouble:value];
    [[self keyValueData] setValue:doubleNum withKey:key];
    
    [self synchronize:YES];
}

- (void)setBool:(BOOL)value withKey:(id <NSCopying>)key
{
    NSNumber *boolNum = [NSNumber numberWithBool:value];
    [[self keyValueData] setValue:boolNum withKey:key];
    
    [self synchronize:YES];
}

- (void)encryptContent:(NSString *)content withKey:(id <NSCopying>)key
{
    if (nil == content || ![content isKindOfClass:[NSString class]]) {
        return;
    }
    
    NSString *cryptedContent = [AESCrypt encrypt:content password:AES_CRYPT_PASSWORD];
    [[self keyValueData] setValue:cryptedContent withKey:key];
    
    [self synchronize:YES];
}

- (void)setContainer:(id)container withKey:(id <NSCopying>)key
{
    if ([container isKindOfClass:[NSSet class]] ||
        [container isKindOfClass:[NSArray class]] ||
        [container isKindOfClass:[NSDictionary class]]) {
        
        [self setValue:container withKey:key];
    }
}

- (void)setResource:(id)resource withKey:(id <NSCopying>)key
{
    [[self keyValueData] setDataValue:resource withKey:key];
    
    [self synchronize:YES];
}

#pragma mark -
- (id)valueWithKey:(id <NSCopying>)key
{
    return [[self keyValueData] valueWithKey:key];
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

- (BOOL)boolWithKey:(id <NSCopying>)key
{
    NSNumber *value = [[self keyValueData] valueWithKey:key];
    if ([value respondsToSelector:@selector(boolValue)]) {
        return [value boolValue];
    }
    return 0;
}

- (id)decryptContentWithKey:(id <NSCopying>)key
{
    NSString *value = [[self keyValueData] valueWithKey:key];
    return [AESCrypt decrypt:value password:AES_CRYPT_PASSWORD];
}

- (id)containerWithKey:(id <NSCopying>)key
{
    id value = [[self keyValueData] valueWithKey:key];
    if ([value isKindOfClass:[NSSet class]] ||
        [value isKindOfClass:[NSArray class]] ||
        [value isKindOfClass:[NSDictionary class]]) {
        
        return value;
    }
    return nil;
}

- (id)resourceWithKey:(id <NSCopying>)key
{
    return [[self keyValueData] dataValueWithKey:key];
}

#pragma mark -
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
    
    [self synchronize:YES];
}

- (void)removeAllValues
{
    [self clear];
}

@end
