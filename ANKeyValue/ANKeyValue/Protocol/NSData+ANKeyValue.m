//
//  NSData+ANKeyValue.m
//  ANKeyValue
//
//  Created by SpringOx on 1/3/15.
//  Copyright (c) 2015 SpringOx. All rights reserved.
//

#import "NSData+ANKeyValue.h"

#define DATA_ENCODE_WITHOUT_DATA_BLOCK    1024

@implementation NSData (ANKeyValue)

- (BOOL)shouldEncodeWithDataBlock
{
    if (DATA_ENCODE_WITHOUT_DATA_BLOCK < [self length]) {
        return YES;
    }
    return NO;
}

@end
