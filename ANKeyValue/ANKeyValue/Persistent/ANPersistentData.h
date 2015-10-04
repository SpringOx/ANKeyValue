//
//  ANPersistentData.h
//  Araneo
//
//  Created by SpringOx on 14/12/12.
//  Copyright (c) 2014年 SpringOx. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "AutoCoding.h"
#import "ANPersistentStrategy.h"

@interface ANPersistentData : NSObject<NSCoding, NSCopying>
{
@protected
    __strong NSRecursiveLock *_dataLock;
}

@property (nonatomic, strong) NSString *domain;

@property (nonatomic, strong) NSString *version;

@property (nonatomic, strong) NSString *name;

@property (nonatomic, strong) NSDate *createdTime;

@property (nonatomic, strong) NSDate *modifiedTime;

@property (nonatomic, strong) ANPersistentStrategy *strategy;

// 加强内部对sender(调用者)的内存管理，避免sender被提前释放导致的各种稳定性问题，
// 包括sender在dealloc调用强制归档(archiveNow)也是不合适的，springox(20151004)
@property (nonatomic, strong) NSMutableArray *observers;

+ (id)data:(NSString *)name version:(NSString *)version domain:(NSString *)domain level:(ANPersistentLevel)level;

+ (id)strategy:(ANPersistentLevel)level;

- (void)setNeedToArchive:(id)observer;

- (void)archiveNow;

- (void)syncArchive;

- (BOOL)isWillArchive;

- (BOOL)isArchiving;

- (void)clearData;

- (void)archiveWillStart;

- (void)archiveDidFinish;

@end
