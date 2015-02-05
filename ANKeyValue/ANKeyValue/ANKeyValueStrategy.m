//
//  ANKeyValueStrategy.m
//  Araneo
//
//  Created by SpringOx on 14/12/17.
//  Copyright (c) 2014年 SpringOx. All rights reserved.
//

#import "ANKeyValueStrategy.h"
#import "ANKeyValueData.h"

@implementation ANKeyValueStrategy

- (id)init
{
    self = [super init];
    if (self) {
        
        // do nothing
        
    }
    return self;
}

- (void)dealloc
{
    // do nothing
}

- (NSString *)createDataBlockPath:(ANKeyValueData *)data primaryKey:(NSString *)key
{
    if ([key isKindOfClass:[NSString class]] && 0 < [key length]) {
        NSString *localDirPath = [self getLocalDirectory:data.name domain:data.domain];
        NSString *dirPath = [self getDirectory:localDirPath relativePath:@"Data"];
        if (nil != dirPath) {
            return [dirPath stringByAppendingPathComponent:[key MD5String]];
        }
    }
    return nil;
}

@end
