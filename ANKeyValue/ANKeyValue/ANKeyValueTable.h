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

/*! @brief 表创建的类方法
 
 * 通过传入的参数，创建、初始化并返回表
 * @param name 一般填写业务名称，不可以为空
 * @param version 版本号管理，默认为空
 * @param resumable 用于标记该表数据是否可恢复的，可恢复数据会存储到Library/Caches目录，否则会存储到Library/Application Support目录
 */
+ (id)tableWithName:(NSString *)name version:(NSString *)version resumable:(BOOL)resumable;

/*! @brief 表创建的类方法，数据会存储到Document目录
 *
 * 通过传入的参数，创建、初始化并返回表
 * @param name 一般填写业务名称，不可以为空
 * @param version 版本号管理，默认为空
 */
+ (id)tableForUser:(NSString *)name version:(NSString *)version;

/*! @brief 默认表创建的类方法，数据会存储到Document目录
 
 * 快速创建一张默认表，可用于App配置项或者状态保持
 */
+ (id)userDefaultTable;

/*! @brief
 
 * 清空低级别的文件，springox(20151127)
 */
+ (void)clearResumableTables;

/*! @brief
 
 * 清空所有级别的文件，springox(20160408)
 */
+ (void)clearAllLevelTables;

#pragma mark -
/*! @brief 表的初始化方法
 *
 * @param data 数据对象
 */
- (id)initWithData:(ANKeyValueData *)data;

/*! @brief 持久化操作
 *
 * 支持持久化操作，强制执行，springox(20150618)
 */
- (void)synchronize;

/*! @brief 持久化操作
 *
 * 支持持久化操作，可选择定时执行还是强制执行，atomically==YES为定时执行，定时执行对于频繁持久化操作更有效，减少重复持久化操作的浪费，springox(20150618)
 */
- (void)synchronize:(BOOL)atomically;

/*! @brief 持久化状态判断
 *
 */
- (BOOL)isArchiving;

/*! @brief 表清空操作
 *
 * 该操作会清空表内存和本地磁盘上存储的数据
 */
- (void)clear;

#pragma mark -
/*! @brief Value
 *
 * 最基础的set方法
 * @param key
 */
- (void)setValue:(id <NSCoding>)value withKey:(id <NSCopying>)key;

/*! @brief Int
 *
 * @param key
 */
- (void)setInt:(int)value withKey:(id <NSCopying>)key;

/*! @brief Integer
 *
 * @param key
 */
- (void)setInteger:(NSInteger)value withKey:(id <NSCopying>)key;

/*! @brief Float
 *
 * @param key
 */
- (void)setFloat:(float)value withKey:(id <NSCopying>)key;

/*! @brief Double
 *
 * @param key
 */
- (void)setDouble:(double)value withKey:(id <NSCopying>)key;

/*! @brief Bool
 *
 * @param key
 */
- (void)setBool:(BOOL)value withKey:(id <NSCopying>)key;

/*! @brief 字符串加密
 *
 * @param key
 */
- (void)encryptContent:(NSString *)content withKey:(id <NSCopying>)key;

/*! @brief 添加容器类数据
 *
 * @param key
 */
- (void)setContainer:(id)container withKey:(id <NSCopying>)key;

/*! @brief 添加资源类数据，会单独针对资源类数据做优化，springox(20150922)
 *
 * @param key
 */
- (void)setResource:(id)resource withKey:(id <NSCopying>)key;

#pragma mark -
/*! @brief value
 *
 * 最基础的get方法，该方法返回值默认是copy操作，如果支持“NSMutableCopying”协议是mutableCopy操作
 * @param key
 */
- (id)valueWithKey:(id <NSCopying>)key;

/*! @brief int
 *
 * @param key
 */
- (int)intWithKey:(id <NSCopying>)key;

/*! @brief integer
 *
 * @param key
 */
- (NSInteger)integerWithKey:(id <NSCopying>)key;

/*! @brief float
 *
 * @param key
 */
- (float)floatWithKey:(id <NSCopying>)key;

/*! @brief double
 *
 * @param key
 */
- (double)doubleWithKey:(id <NSCopying>)key;

/*! @brief bool
 *
 * @param key
 */
- (BOOL)boolWithKey:(id <NSCopying>)key;

/*! @brief 字符串解密
 *
 * @param key
 */
- (id)decryptContentWithKey:(id <NSCopying>)key;

/*! @brief get容器
 *
 * @param key
 */
- (id)containerWithKey:(id <NSCopying>)key;

/*! @brief value
 *
 * 获取资源文件的方法，该方法返回值默认是copy操作，如果支持“NSMutableCopying”协议是mutableCopy操作
 * @param key
 */
- (id)resourceWithKey:(id <NSCopying>)key;

#pragma mark -
/*! @brief 获取所有keys
 *
 */
- (NSArray *)allKeys;

/*! @brief 获取所有values
 *
 */
- (NSArray *)allValues;

/*! @brief 移除value
 *
 * @param key
 */
- (void)removeValueWithKey:(id <NSCopying>)key;

/*! @brief 移除所有value
 *
 */
- (void)removeAllValues;

@end
