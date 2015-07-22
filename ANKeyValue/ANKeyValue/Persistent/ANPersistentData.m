//
//  ANPersistentData.m
//  Araneo
//
//  Created by SpringOx on 14/12/12.
//  Copyright (c) 2014年 SpringOx. All rights reserved.
//

#import "ANPersistentData.h"

void *const GlobalArchiveQueueIdentityKey = (void *)&GlobalArchiveQueueIdentityKey;

@interface ANPersistentData()
{
@private
    BOOL _isArchiving;
    __strong NSTimer *_archiveTimer;
}

@end

@implementation ANPersistentData

+ (id)data:(NSString *)name version:(NSString *)version domain:(NSString *)domain level:(ANPersistentLevel)level
{
    ANPersistentStrategy *strategy = [self strategy:level];
    
    NSString *path = [strategy localPath:name version:version domain:domain];
    ANPersistentData *data = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
    if (nil == data || ![data respondsToSelector:@selector(strategy)]) {
        data = [[[self class] alloc] init];
        data.createdTime = [NSDate date];
    }
    data.domain = domain;
    data.version = version;
    data.name = name;
    data.modifiedTime = [NSDate date];
    data.strategy = strategy;

    return data;
}

+ (id)strategy:(ANPersistentLevel)level
{
    return [[ANPersistentStrategy alloc] initWithLevel:level];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (id)init
{
    self = [super init];
    if (self) {
        
        _dataLock = [[NSRecursiveLock alloc] init];
        
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

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        
        _dataLock = [[NSRecursiveLock alloc] init];
        
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

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [super encodeWithCoder:aCoder];
}

- (id)copyWithZone:(NSZone *)zone
{
    return self;
}

- (void)setNeedToArchive
{
    [_dataLock lock];
    if ([self.strategy shouldArchive:self name:self.name]) {
        if (nil == _archiveTimer) {
            NSTimeInterval timeInterval = [self.strategy timeIntervalOfArchiveTimer];
            _archiveTimer = [NSTimer scheduledTimerWithTimeInterval:timeInterval target:self selector:@selector(archiveTimerOperation) userInfo:nil repeats:NO];
            
        }
    }
    [_dataLock unlock];
}

- (void)archiveNow
{
    // _archiveTimer会影响self的计数，因此先自己做好保护，springox(20150318)
    __strong ANPersistentData *strongSelf = self;
    
    [_dataLock lock];
    if (nil != _archiveTimer) {
        [self syncArchive];
    }
    [_dataLock unlock];
    
    strongSelf = nil;
}

- (void)syncArchive
{
    // _archiveTimer会影响self的计数，因此先自己做好保护，springox(20150318)
    __strong ANPersistentData *strongSelf = self;
    
    [_dataLock lock];
    [_archiveTimer invalidate];
    @autoreleasepool {
        [self archive:self];
    }
    _archiveTimer = nil;
    [_dataLock unlock];
    
    strongSelf = nil;
}

- (BOOL)isWillArchive
{
    [_dataLock lock];
    BOOL flag = (nil != _archiveTimer);
    [_dataLock unlock];
    return flag;
}

- (BOOL)isArchiving
{
    [_dataLock lock];
    BOOL flag = (_isArchiving || (nil != _archiveTimer));
    [_dataLock unlock];
    return flag;
}

- (void)clearData
{
    // _archiveTimer会影响self的计数，因此先自己做好保护，springox(20150318)
    __strong ANPersistentData *strongSelf = self;
    
    [_dataLock lock];
    NSString *path = [self.strategy localDirectory:self.name domain:self.domain];
    NSFileManager *fm = [NSFileManager defaultManager];
    NSError *error = nil;
    [fm removeItemAtPath:path error:&error];
    if (nil != error) {
        NSLog(@"Persistent Data remove local directory %@ fail:%@\n", path, error);
    } else {
        NSLog(@"Persistent Data remove local directory %@ success\n", path);
    }
    
    [self syncArchive];
    [_dataLock unlock];
    
    strongSelf = nil;
}

- (void)archiveWillStart
{
    // do nothing
}

- (void)archiveDidFinish
{
    // do nothing
}

#pragma mark - Private Method

- (void)archiveTimerOperation
{
    // _archiveTimer会影响self的计数，因此先自己做好保护，springox(20150318)
    __strong ANPersistentData *strongSelf = self;
    
    [_dataLock lock];
    [_archiveTimer invalidate];
    [self archiveOperation:self];
    _archiveTimer = nil;
    [_dataLock unlock];
    
    strongSelf = nil;
}

- (void)archiveOperation:(id)rootObject
{
    [_dataLock lock];
    id obj = [rootObject copy];
    dispatch_block_t archiveBlock = ^{
        @autoreleasepool {
            [self archive:obj];
        }
    };
    dispatch_async([self archiveQueue], archiveBlock);
    [_dataLock unlock];
}

- (dispatch_queue_t)archiveQueue
{
    // added by springox(20150105)
    static dispatch_queue_t archiveQueue;
    if (NULL == archiveQueue) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            const char *archiveQueueName = NULL;
            archiveQueueName = [@"GlobalArchiveQueueName" UTF8String];
            // 这里需要特别说明虽然全局使用一个并行的任务队列，同时也认为有频控的持久化实现
            // 对于并发任务的要求并不高，即使存在多个持久化目标，单个子线程串行执行也能满足需要，springox(20150105)
            //archiveQueue = dispatch_queue_create(archiveQueueName, NULL);
            archiveQueue = dispatch_queue_create(archiveQueueName, DISPATCH_QUEUE_CONCURRENT);

            void *key = GlobalArchiveQueueIdentityKey;
            void *nonNullValue = GlobalArchiveQueueIdentityKey;
            dispatch_queue_set_specific(archiveQueue, key, nonNullValue, NULL);
        });
    }
    return archiveQueue;
}

- (void)archive:(id)rootObject
{
    [_dataLock lock];
    [self archiveWillStart];
    _isArchiving = YES;
    
    NSString *dataPath = [self.strategy localPath:_name version:_version domain:_domain];
    if (nil != dataPath) {
        NSLog(@"Persistent Data archive %@\n", dataPath);
        [NSKeyedArchiver archiveRootObject:rootObject toFile:dataPath];
        self.modifiedTime = [NSDate date];
    }
    
    _isArchiving = NO;
    [self archiveDidFinish];
    [_dataLock unlock];
}

- (void)applicationWillTerminate:(NSNotification *)not
{
    [self archiveNow];
}

- (void)applicationDidEnterBackground:(NSNotification *)not
{
    [self archiveNow];
}

@end
