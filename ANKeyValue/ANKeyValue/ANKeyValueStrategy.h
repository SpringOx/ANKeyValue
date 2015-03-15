//
//  ANKeyValueStrategy.h
//  Araneo
//
//  Created by SpringOx on 14/12/17.
//  Copyright (c) 2014年 SpringOx. All rights reserved.
//

#import "ANPersistentStrategy.h"

@class ANKeyValueData;

@interface ANKeyValueStrategy : ANPersistentStrategy

- (NSString *)dataBlockPath:(ANKeyValueData *)data primaryKey:(NSString *)key;

@end
