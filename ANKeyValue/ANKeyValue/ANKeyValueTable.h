//
//  ANKeyValueTable.h
//  Araneo
//
//  Created by SpringOx on 14/12/12.
//  Copyright (c) 2014年 SpringOx. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ANKeyValueData.h"

@interface ANKeyValueTable : NSObject

+ (id)tableWithName:(NSString *)name version:(NSString *)version;

- (id)initWithData:(ANKeyValueData *)data;

- (void)synchronous;

- (void)synchronous:(BOOL)atomically;

- (BOOL)isArchiving;

- (void)clear;

- (void)setInt:(int)value withKey:(id <NSCopying>)key;

- (void)setInteger:(NSInteger)value withKey:(id <NSCopying>)key;

- (void)setFloat:(float)value withKey:(id <NSCopying>)key;

- (void)setDouble:(double)value withKey:(id <NSCopying>)key;

- (void)setBool:(BOOL)value withKey:(id <NSCopying>)key;

- (void)setValue:(id <NSCoding>)value withKey:(id <NSCopying>)key;

- (int)intWithKey:(id <NSCopying>)key;

- (NSInteger)integerWithKey:(id <NSCopying>)key;

- (float)floatWithKey:(id <NSCopying>)key;

- (double)doubleWithKey:(id <NSCopying>)key;

- (id)valueWithKey:(id <NSCopying>)key;

- (NSArray *)allKeys;

- (NSArray *)allValues;

- (void)removeValueWithKey:(id <NSCopying>)key;

- (void)removeAllValues;

@end
