//
//  ANMemoryPage.m
//  QLBaseCore
//
//  Created by jiachunke on 20/02/2017.
//  Copyright © 2017 Tencent. All rights reserved.
//

#import "ANMemoryPage.h"
#import <UIKit/UIKit.h>
#import <pthread.h>
#import "ANPersistentData.h"

@interface ANMemoryPage()
{
    //增加永久性内存cache的结构，用于支持一些有必要永久cache的情况
    NSMutableDictionary *_permanentCache;
    pthread_mutex_t _mutex;
    NSHashTable *_activeDataList;
}

@end

@implementation ANMemoryPage

- (instancetype)init
{
    self = [super init];
    if (self) {
        NSString *version = [UIDevice currentDevice].systemVersion;
        if (version.doubleValue < 9.0) {
            //由于iOS7和iOS8均发现有NSCache导致的crash，出于规避的目的，在iOS7和iOS8上面启动备用cache结构
            _permanentCache = [NSMutableDictionary dictionary];
            
            pthread_mutexattr_t attr;
            pthread_mutexattr_init(&attr);
            //设置锁的属性为可递归
            //pthread_mutexattr_settype(&attr, PTHREAD_MUTEX_NORMAL);
            pthread_mutex_init(&_mutex, &attr);
            pthread_mutexattr_destroy(&attr);
        }

        _activeDataList = [NSHashTable weakObjectsHashTable];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(applicationWillTerminate:)
                                                     name:UIApplicationWillTerminateNotification
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(applicationDidEnterBackground:)
                                                     name:UIApplicationDidEnterBackgroundNotification
                                                   object:nil];
    }
    return self;
}

- (id)object:(NSString *)name version:(NSString *)version
{
    if (![name isKindOfClass:[NSString class]] || 0 == [name length]) {
        return nil;
    }
    
    NSString *key = [self generateKey:name version:version];
    if (nil != key) {
        if (_permanentCache) {
            pthread_mutex_lock(&_mutex);
            id object = [_permanentCache objectForKey:key];
            pthread_mutex_unlock(&_mutex);
            return object;
        } else {
            return [self objectForKey:key];
        }
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
        if (_permanentCache) {
            pthread_mutex_lock(&_mutex);
            [_permanentCache setObject:obj forKey:key];
            pthread_mutex_unlock(&_mutex);
        } else {
            [self setObject:obj forKey:key];
        }
        [_activeDataList addObject:obj];
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

- (void)dataArchiveNow
{
    NSArray *dataObjects = [_activeDataList allObjects];
    for (ANPersistentData *pData in dataObjects) {
        [pData archiveNow];
    }
}

- (void)applicationWillTerminate:(NSNotification *)not
{
    [self dataArchiveNow];
}

- (void)applicationDidEnterBackground:(NSNotification *)not
{
    [self dataArchiveNow];
}

@end
