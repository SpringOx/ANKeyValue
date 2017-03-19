//
//  ANMemoryPage.h
//  QLBaseCore
//
//  Created by jiachunke on 20/02/2017.
//  Copyright © 2017 Tencent. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ANMemoryPage : NSCache

- (id)object:(NSString *)name version:(NSString *)version;

- (void)setObject:(id)obj name:(NSString *)name version:(NSString *)version;

- (NSString *)generateKey:(NSString *)name version:(NSString *)version;

@end
