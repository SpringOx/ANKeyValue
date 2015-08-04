//
//  TableHelper.h
//  ANKeyValue
//
//  Created by SpringOx on 8/4/15.
//  Copyright (c) 2015 SpringOx. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ANKeyValueTable.h"

@interface TableHelper : NSObject

+ (ANKeyValueTable *)getUserDefaultTable;

+ (ANKeyValueTable *)getSetItemTable;

@end
