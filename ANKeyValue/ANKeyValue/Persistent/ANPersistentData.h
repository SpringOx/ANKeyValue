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

+ (id)data:(NSString *)name version:(NSString *)version domain:(NSString *)domain level:(ANPersistentLevel)level;

+ (id)strategy:(ANPersistentLevel)level;

- (void)setNeedToArchive;

- (void)archiveNow;

- (void)syncArchive;

- (BOOL)isWillArchive;

- (BOOL)isArchiving;

- (void)clearData;

- (void)archiveWillStart;

- (void)archiveDidFinish;

@end
