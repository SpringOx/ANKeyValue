//
//  ANPersistentStrategy.h
//  Araneo
//
//  Created by SpringOx on 14/12/12.
//  Copyright (c) 2014年 SpringOx. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_OPTIONS(unsigned, ANPersistentLevel) {
    ANPersistentLevelResumableCaches = 0,      // 当系统回收存储空间时，数据能够自动完整的恢复
    ANPersistentLevelApplicationSupport = 1,   // App运行时依赖的资源，同时不能够自动完整的恢复
    ANPersistentLevelUserDocument = 2,         // 记录用户特定行为和隐私信息，同时不能够自动完整的恢复
};

@interface NSString (MD5)

- (NSString *)MD5String;

@end

@class ANPersistentData;

@interface ANPersistentStrategy : NSObject

@property (nonatomic, strong) NSString *rootDirectory;

- (id)initWithLevel:(ANPersistentLevel)level;

- (BOOL)shouldArchive:(ANPersistentData *)data name:(NSString *)name;

- (NSTimeInterval)timeIntervalOfArchiveTimer;

- (NSString *)localDirectory:(NSString *)rootDir relativePath:(NSString *)relPath;

- (NSString *)localDirectoryWithRelativePath:(NSString *)relPath;

- (NSString *)localDirectory:(NSString *)name domain:(NSString *)domain;

- (NSString *)localPath:(NSString *)name version:(NSString *)version domain:(NSString *)domain;

- (NSArray *)localPathArrayWithDomain:(NSString *)domain;

@end
