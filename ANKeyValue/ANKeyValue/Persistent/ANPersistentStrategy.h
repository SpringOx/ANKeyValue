//
//  ANPersistentStrategy.h
//  Araneo
//
//  Created by SpringOx on 14/12/12.
//  Copyright (c) 2014年 SpringOx. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (MD5)

- (NSString *)MD5String;

@end

@class ANPersistentData;

@interface ANPersistentStrategy : NSObject

@property (nonatomic, strong) NSString *rootDirectory;

- (BOOL)shouldArchive:(ANPersistentData *)data name:(NSString *)name;

- (NSString *)getDirectory:(NSString *)rootDir relativePath:(NSString *)relPath;

- (NSString *)localDirectory:(NSString *)name domain:(NSString *)domain;

- (NSString *)localPath:(NSString *)name version:(NSString *)version domain:(NSString *)domain;

- (NSArray *)localPathArrayWithDomain:(NSString *)domain;

@end
