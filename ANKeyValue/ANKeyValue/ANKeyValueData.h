//
//  ANKeyValueData.h
//  Araneo
//
//  Created by SpringOx on 14/12/17.
//  Copyright (c) 2014年 SpringOx. All rights reserved.
//

#import "ANPersistentData.h"
#import "ANKeyValueProtocol.h"

@interface ANKeyValueData : ANPersistentData

@property (nonatomic, strong) NSMutableDictionary *keyValueMap;

- (void)setValue:(id)aValue withKey:(id <NSCopying>)aKey;

- (id)valueWithKey:(id)aKey;

- (NSArray *)allKeys;

- (NSArray *)allValues;

- (void)removeValueWithKey:(id <NSCopying>)aKey;

- (void)removeAllValues;

@end
