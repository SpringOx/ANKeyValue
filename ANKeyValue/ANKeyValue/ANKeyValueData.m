//
//  ANKeyValueData.m
//  Araneo
//
//  Created by SpringOx on 14/12/17.
//  Copyright (c) 2014年 SpringOx. All rights reserved.
//

#import "ANKeyValueData.h"
#import "ANKeyValueCache.h"
#import "ANKeyValueStrategy.h"

NSString *const GlobalDataBlockArchivePathPrefix = @"$$PATH=";

@interface ANKeyValueData()
{
@private
    __strong NSCache *_dataBlockCache;
    __strong NSMutableDictionary *_removedDataPathMap;
}

@end

@implementation ANKeyValueData

+ (id)data:(NSString *)name version:(NSString *)version domain:(NSString *)domain level:(ANPersistentLevel)level
{
    id data = [super data:name version:version domain:domain level:level];
    // 容错处理，确保key-value的容器ready，springox(20141225)
    if ([data respondsToSelector:@selector(keyValueMap)]) {
        ANKeyValueData *kvData = (ANKeyValueData *)data;
        if (nil == kvData.keyValueMap) {
            kvData.keyValueMap = [NSMutableDictionary dictionary];
        }
        return data;
    }
    return nil;
}

+ (id)strategy:(ANPersistentLevel)level
{
    return [[ANKeyValueStrategy alloc] initWithLevel:level];
}

- (id)init
{
    self = [super init];
    if (self) {
        _keyValueMap = [NSMutableDictionary dictionary];
        _dataBlockCache = [[NSCache alloc] init];
        _removedDataPathMap = [NSMutableDictionary dictionary];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        _dataBlockCache = [[NSCache alloc] init];
        _removedDataPathMap = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [super encodeWithCoder:aCoder];
}

- (void)dealloc
{
    // do nothing
}

- (void)clearData
{
    [_dataLock lock];
    [_keyValueMap removeAllObjects];
    [_dataBlockCache removeAllObjects];
    [_removedDataPathMap removeAllObjects];
    [_dataLock unlock];
    
    [super clearData];
}

- (void)archiveWillStart
{
    [super archiveWillStart];
}

- (void)archiveDidFinish
{
    [_dataLock lock];
    NSFileManager *fm = [NSFileManager defaultManager];
    NSError *error = nil;
    @autoreleasepool {
        for (NSString *path in _removedDataPathMap.allValues) {
            if ([path isKindOfClass:[NSString class]]) {
                error = nil;
                [fm removeItemAtPath:path error:&error];
                if (nil != error) {
                    NSLog(@"Key Value Data remove data block %@ fail:%@\n", path, error);
                } else {
                    NSLog(@"Key Value Data remove data block %@ success\n", path);
                }
            }
        }
    }
    [_dataLock unlock];
    
    [super archiveDidFinish];
}

- (void)setValue:(id <NSCoding, ANKeyValue>)aValue withKey:(id <NSCopying>)aKey
{
    if ([aValue respondsToSelector:@selector(shouldEncodeWithDataBlock)]) {
        if ([aValue shouldEncodeWithDataBlock]) {
            [_dataLock lock];
            [_dataBlockCache setObject:aValue forKey:aKey];
            // 给Map写入一个索引值，即归档前缀和key组成，springox(20150105)
            NSString *newValue = [NSString stringWithFormat:@"%@%@", GlobalDataBlockArchivePathPrefix, aKey];
            [_keyValueMap setObject:newValue forKey:aKey];
            // 如果一个被remove的key重新被使用，那么删除列表里面的节点将变得不合理，springox(20150105)
            [_removedDataPathMap removeObjectForKey:aKey];
            [_dataLock unlock];
            
            // 做好data block的归档任务，springox(20150105)
            NSString *dataPath = [(ANKeyValueStrategy *)self.strategy dataBlockPath:self primaryKey:(NSString *)aKey];
            if (nil != dataPath) {
                NSLog(@"Data block archive %@", dataPath);
                [NSKeyedArchiver archiveRootObject:aValue toFile:dataPath];
                return;
            }
        }
    }
    
    [_dataLock lock];
    [_keyValueMap setObject:aValue forKey:aKey];
    [_dataLock unlock];
}

- (id)valueWithKey:(id)aKey
{
    [_dataLock lock];
    id value = [_keyValueMap objectForKey:aKey];
    // 判断是否有data block，springox(20150105)
    if ([value isKindOfClass:[NSString class]]) {
        NSString *valueStr = (NSString *)value;
        if ([valueStr hasPrefix:GlobalDataBlockArchivePathPrefix]) {
            NSString *tempValue = [_dataBlockCache objectForKey:aKey];
            if (nil == tempValue) {
                NSString *tempKey = [valueStr stringByReplacingOccurrencesOfString:GlobalDataBlockArchivePathPrefix withString:@""];
                NSString *dataPath = [(ANKeyValueStrategy *)self.strategy dataBlockPath:self primaryKey:(NSString *)tempKey];
                if (nil != dataPath) {
                    tempValue = [NSKeyedUnarchiver unarchiveObjectWithFile:dataPath];
                    if (nil != tempValue) {
                        value = tempValue;
                        [_dataBlockCache setObject:value forKey:aKey];
                    }
                }
            } else {
                value = tempValue;
            }
        }
    }
    [_dataLock unlock];
    return value;
}

- (NSArray *)allKeys
{
    return [_keyValueMap allKeys];
}

- (NSArray *)allValues
{
    return [_keyValueMap allValues];
}

- (void)removeValueWithKey:(id <NSCopying>)aKey
{
    [_dataLock lock];
    id value = [_keyValueMap objectForKey:aKey];
    
    // 判断是否有data block，springox(20150105)
    if ([value isKindOfClass:[NSString class]]) {
        NSString *valueStr = (NSString *)value;
        if ([valueStr hasPrefix:GlobalDataBlockArchivePathPrefix]) {
            NSString *tempKey = [valueStr stringByReplacingOccurrencesOfString:GlobalDataBlockArchivePathPrefix withString:@""];
            NSString *dataPath = [(ANKeyValueStrategy *)self.strategy dataBlockPath:self primaryKey:(NSString *)tempKey];
            if (nil != dataPath) {
                [_removedDataPathMap setObject:dataPath forKey:aKey];
            }
        }
    }
    
    [_keyValueMap removeObjectForKey:aKey];
    [_dataLock unlock];
}

- (void)removeAllValues
{
    [self clearData];
}

@end
