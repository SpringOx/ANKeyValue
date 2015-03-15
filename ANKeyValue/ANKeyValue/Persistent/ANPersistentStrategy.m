//
//  ANPersistentStrategy.m
//  Araneo
//
//  Created by SpringOx on 14/12/12.
//  Copyright (c) 2014年 SpringOx. All rights reserved.
//

#import "ANPersistentStrategy.h"
#import <CommonCrypto/CommonDigest.h>

#define ARCHIVE_TIME_INTERVAL_DEFAULT    10.f
#define VERSION_DEFAULT          @"1.0.0"
#define DOMAIN_STRING_DEFAULT    @"PersistentData"

@implementation NSString (MD5)

- (NSString *)MD5String
{
    if(self == nil || [self length] == 0)
        return nil;
    
    const char *value = [self UTF8String];
    
    unsigned char outputBuffer[CC_MD5_DIGEST_LENGTH];
    CC_MD5(value, strlen(value), outputBuffer);
    
    NSMutableString *outputString = [[NSMutableString alloc] initWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for(NSInteger count = 0; count < CC_MD5_DIGEST_LENGTH; count++){
        [outputString appendFormat:@"%02X",outputBuffer[count]];
    }
    return outputString;
}

@end

@implementation ANPersistentStrategy

- (id)init
{
    self = [super init];
    if (self) {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
        self.rootDirectory = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
        
    }
    return self;
}

- (BOOL)shouldArchive:(ANPersistentData *)data name:(NSString *)name
{
    return YES;
}

- (NSString *)getDirectory:(NSString *)rootDir relativePath:(NSString *)relPath
{
    if (![rootDir isKindOfClass:[NSString class]] || 0 == [rootDir length]) {
        return nil;
    }
    
    NSString *dirPath = [rootDir stringByAppendingPathComponent:relPath];
    NSFileManager *fm = [NSFileManager defaultManager];
    if(![fm fileExistsAtPath:dirPath]){
        NSError *error;
        [fm createDirectoryAtPath:dirPath withIntermediateDirectories:YES attributes:nil error:&error];
        if (nil != error) {
            NSLog(@"create directory error : %@ %@", dirPath, error);
        } else {
            return dirPath;
        }
    }
    return dirPath;
}

- (NSString *)localDirectory:(NSString *)name domain:(NSString *)domain
{
    NSString *relPath = [NSString stringWithFormat:@"%@/%@", domain, [name MD5String]];
    return [self getDirectory:self.rootDirectory relativePath:relPath];
}

- (NSString *)localPath:(NSString *)name version:(NSString *)version domain:(NSString *)domain
{
    if (nil == self.rootDirectory) {
        return nil;
    }
    
    if ([name isKindOfClass:[NSString class]] && 0 < [name length]) {
        if (![version isKindOfClass:[NSString class]] || 0 == [version length]) {
            version = VERSION_DEFAULT;
        }
        if (![domain isKindOfClass:[NSString class]] || 0 == [domain length]) {
            domain = DOMAIN_STRING_DEFAULT;
        }
        
        NSString *dirPath = [self localDirectory:name domain:domain];
        if (nil != dirPath) {
            NSString *fileName = [NSString stringWithFormat:@"%@-%@", [name MD5String], version];
            return [dirPath stringByAppendingPathComponent:fileName];
        }
    }
    return nil;
}

- (NSArray *)localPathArrayWithDomain:(NSString *)domain
{
    if (nil == self.rootDirectory) {
        return nil;
    }
    
    if (![domain isKindOfClass:[NSString class]] || 0 == [domain length]) {
        return [NSArray array];
    }
    
    NSString *relPath = domain;
    NSString *dirPath = [self getDirectory:self.rootDirectory relativePath:relPath];
    NSFileManager *fm = [NSFileManager defaultManager];
    if (![fm fileExistsAtPath:dirPath]) {
        return [NSArray array];
    }
    
    NSError *error = nil;
    NSArray *contents = [fm contentsOfDirectoryAtPath:dirPath error:&error];
    if (nil != error) {
        return [NSArray array];
    }
    
    NSMutableArray *tempArr = [NSMutableArray arrayWithCapacity:[contents count]];
    for (NSString *content in contents) {
        NSString *path = [dirPath stringByAppendingPathComponent:content];
        [tempArr addObject:path];
    }
    return [NSArray arrayWithArray:tempArr];
}

@end
