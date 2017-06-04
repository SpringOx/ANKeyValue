ANKeyValue(键值存储)
=========

A advanced "NSUserDefault" with key-value-based, a flexible and efficient object storage solution.

一个基于key-value方式的NSUserDefault加强版，一种灵活又快捷的对象存储方案。

With features:
1, multi-service, using the memory completely isolated;

2, support automatic serialization and de-serialization simplifies persistence;

3, long-lasting semi-automatic operation, refresh, Special Scene enforced;

4, supports concurrent execution of task execution queue;

6, support for policy control, multi-level storage;

7, support encryption / decryption operations;

具备特性：
1、支持多业务，使用到存储完全隔离；

2、支持自动序列化和反序列化，简化持久化；

3、持久化操作半自动，定时刷新，特殊场景强制执行；

4、支持任务执行队列化并发执行；

6、支持策略控制，多级存储；

7、支持加密/解密操作；


![Screenshot](https://github.com/SpringOx/ANKeyValue/blob/master/ANKeyValue-1.png)

![Screenshot](https://github.com/SpringOx/ANKeyValue/blob/master/ANKeyValue-2.png)

![Screenshot](https://github.com/SpringOx/ANKeyValue/blob/master/ANKeyValue-3.png)



### Usage(用法)

``` objective-c
    // 支持容器存储
    self.itemList = [[TableHelper getSetItemTable] containerWithKey:@"setItemList"];
    
    - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
    {
        [self.itemList removeObjectAtIndex:indexPath.row];
        [[TableHelper getSetItemTable] synchronize];
        
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationLeft];
    }
```

``` objective-c
    // 支持key-value值存储
    @autoreleasepool {
        NSMutableArray *tableArr = [NSMutableArray array];
        int num = 0;
        do {
            
            NSString *key = [NSString stringWithFormat:@"SetOperation-%d", num];
            ANKeyValueTable *table = [_tableDict objectForKey:key];
            if (nil == table) {
                table = [ANKeyValueTable tableWithName:key version:@"0.0.9" resumable:YES];
                [_tableDict setObject:table forKey:key];
            }
            [tableArr addObject:table];
            
        } while (10 > ++num);
        
        NSInteger total = 10000;
        NSInteger count = total;
        while (count) {
            
            for (ANKeyValueTable *t in tableArr) {
                //int randNum = arc4random();
                int randNum = (int)count;
                NSString *key = [NSString stringWithFormat:@"Key-%d", randNum];
                
                if (0 == type) {
                    
                    [t setInt:randNum withKey:key];
                
                } else {
                
                    [t setValue:@"ABCDEFGHIJKLMNOPQRSTVUWXYZ" withKey:key];
                    
                }
                
            }
            
            count--;
        }
    }
```

``` objective-c
    // 支持加解密
    ANKeyValueTable *cTable = [ANKeyValueTable tableWithName:@"CryptContentTest" version:@"0.0.1" resumable:YES];
    NSString *c1 = @"Content-CryptTest";
    [cTable encryptContent:c1 withKey:@"Key-CryptTest"];
    NSString *c2 = [cTable decryptContentWithKey:@"Key-CryptTest"];
    NSAssert([c1 isEqualToString:c2], @"crypt test is not passed");
```

## Contact(联系)

- [https://github.com/SpringOx](https://github.com/SpringOx)(GitHub)
- [jiachunke@gmail.com](jiachunke@gmail.com)(Email)



