//
//  TableHelper.m
//  ANKeyValue
//
//  Created by SpringOx on 8/4/15.
//  Copyright (c) 2015 SpringOx. All rights reserved.
//

#import "TableHelper.h"
#import "ANKeyValueTable.h"

@implementation TableHelper

+ (id)getUserDefaultTable
{
    return [ANKeyValueTable userDefaultTable];
}

+ (id)getSetItemTable
{
    return [ANKeyValueTable tableWithName:@"SetItem" version:@"1.0.0" resumable:YES];
}

@end
