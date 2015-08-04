//
//  SetDemoItem.h
//  ANKeyValue
//
//  Created by SpringOx on 6/11/15.
//  Copyright (c) 2015 SpringOx. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AutoCoding.h"
#import "ANKeyValueProtocol.h"

@interface SetDemoItem : NSObject<ANKeyValue>

@property (nonatomic, strong) NSString *timeStr;

@property (nonatomic, assign) int randNum;

@end
