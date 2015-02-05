//
//  ANKeyValueCache.h
//  Araneo
//
//  Created by SpringOx on 12/21/14.
//  Copyright (c) 2014 SpringOx. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ANKeyValueCache : NSCache

- (void)preloadWithDomain:(NSString *)domain;

- (id)object:(NSString *)name version:(NSString *)version;

- (void)setObject:(id)obj name:(NSString *)name version:(NSString *)version;

@end
