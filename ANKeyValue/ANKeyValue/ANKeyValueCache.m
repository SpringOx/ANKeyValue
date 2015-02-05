//
//  ANKeyValueCache.m
//  Araneo
//
//  Created by SpringOx on 12/21/14.
//  Copyright (c) 2014 SpringOx. All rights reserved.
//

#import "ANKeyValueCache.h"
#import "ANKeyValueTable.h"

@implementation ANKeyValueCache

- (void)preloadWithDomain:(NSString *)domain
{
    [ANKeyValueData datasWithDomain:domain dataBlock:^(id data, NSUInteger idx, BOOL *stop) {
        ANKeyValueData *keyData = (ANKeyValueData *)data;
        ANKeyValueTable *table = [[ANKeyValueTable alloc] initWithData:keyData];
        
        [self setObject:table name:keyData.name version:keyData.version];
    }];
}

- (id)object:(NSString *)name version:(NSString *)version
{
    if (![name isKindOfClass:[NSString class]] || 0 == [name length]) {
        return nil;
    }
    
    NSString *tempVersion = nil!=version ? version : @"";
    NSString *key = [NSString stringWithFormat:@"%@-%@", name, tempVersion];
    return [self objectForKey:key];
}

- (void)setObject:(id)obj name:(NSString *)name version:(NSString *)version
{
    if (![name isKindOfClass:[NSString class]] || 0 == [name length]) {
        return;
    }
    
    NSString *tempVersion = nil!=version ? version : @"";
    NSString *key = [NSString stringWithFormat:@"%@-%@", name, tempVersion];
    [self setObject:obj forKey:key];
}

@end
