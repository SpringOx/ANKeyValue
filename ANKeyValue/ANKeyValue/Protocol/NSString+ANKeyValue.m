//
//  NSString+ANKeyValue.m
//  ANKeyValue
//
//  Created by SpringOx on 1/3/15.
//  Copyright (c) 2015 SpringOx. All rights reserved.
//

#import "NSString+ANKeyValue.h"

#define STRING_ENCODE_WITHOUT_DATA_BLOCK    1024

@implementation NSString (ANKeyValue)

- (BOOL)shouldEncodeWithDataBlock
{
    if (STRING_ENCODE_WITHOUT_DATA_BLOCK < [self length]) {
        return YES;
    }
    return NO;
}

@end
