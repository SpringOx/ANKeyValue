//
//  ANKeyValueCache.m
//  Araneo
//
//  Created by SpringOx on 12/21/14.
//  Copyright (c) 2014 SpringOx. All rights reserved.
//

#import "ANKeyValueCache.h"
#import "ANKeyValueTable.h"

NSString *const kANKeyValueCacheWillEvictObjectNotification = @"kANKeyValueCacheWillEvictObjectNotification";

@implementation ANKeyValueCache

- (id)object:(NSString *)name version:(NSString *)version
{
    if (![name isKindOfClass:[NSString class]] || 0 == [name length]) {
        return nil;
    }
    
    NSString *key = [self generateKey:name version:version];
    if (nil != key) {
        return [self objectForKey:key];
    }
    return nil;
}

- (void)setObject:(id)obj name:(NSString *)name version:(NSString *)version
{
    if (![name isKindOfClass:[NSString class]] || 0 == [name length]) {
        return;
    }
    
    NSString *key = [self generateKey:name version:version];
    if (nil != obj && nil != key) {
        [self setObject:obj forKey:key];
    }
}

- (NSString *)generateKey:(NSString *)name version:(NSString *)version
{
    if (![name isKindOfClass:[NSString class]] || 0 == [name length]) {
        return nil;
    }
    
    if (![version isKindOfClass:[NSString class]] || 0 == [version length]) {
        return [NSString  stringWithFormat:@"%@", name];
    }
    return [NSString stringWithFormat:@"%@-%@", name, version];
}

#pragma mark - NSCacheDelegate

- (void)cache:(NSCache *)cache willEvictObject:(id)obj
{
    NSLog(@"KeyValue Cache will evict obj %zd\n", obj);
    // 对外的通知间接使用 obj 作为 notification的sender, springox(20150316)
    [[NSNotificationCenter defaultCenter] postNotificationName:kANKeyValueCacheWillEvictObjectNotification object:obj];
}

@end
