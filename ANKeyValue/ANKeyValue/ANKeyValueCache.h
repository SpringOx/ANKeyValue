//
//  ANKeyValueCache.h
//  Araneo
//
//  Created by SpringOx on 12/21/14.
//  Copyright (c) 2014 SpringOx. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString *const kANKeyValueCacheWillEvictObjectNotification;

@interface ANKeyValueCache : NSCache<NSCacheDelegate>

- (id)object:(NSString *)name version:(NSString *)version;

- (void)setObject:(id)obj name:(NSString *)name version:(NSString *)version;

- (NSString *)generateKey:(NSString *)name version:(NSString *)version;

@end
