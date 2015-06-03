//
//  NSString+ANKeyValue.m
//  ANKeyValue
//
//  Created by SpringOx on 1/3/15.
//  Copyright (c) 2015 SpringOx. All rights reserved.
//

#import "NSString+ANKeyValue.h"

@implementation NSString (ANKeyValue)

- (BOOL)shouldEncodeWithDataBlock
{
    if (1024 < [self length]) {
        return YES;
    }
    return NO;
}

@end
