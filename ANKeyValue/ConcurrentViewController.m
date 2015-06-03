//
//  ConcurrentViewController.m
//  ANKeyValue
//
//  Created by SpringOx on 3/24/15.
//  Copyright (c) 2015 SpringOx. All rights reserved.
//

#import "ConcurrentViewController.h"
#import "ANKeyValueTable.h"

@interface ConcurrentViewController ()
{
    __strong NSMutableDictionary *_tableDict;
}

@end

@implementation ConcurrentViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    _tableDict = [NSMutableDictionary dictionary];
    
    _thread1Label.text = @"Thread 1";
    _thread2Label.text = @"Thread 2";
    _thread3Label.text = @"Thread 3";
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)didPressStartButtonAction:(id)sender {
    [NSThread detachNewThreadSelector:@selector(subThreadSelector1:)
                             toTarget:self
                           withObject:nil];
    
    [NSThread detachNewThreadSelector:@selector(subThreadSelector2:)
                             toTarget:self
                           withObject:nil];
    
    [NSThread detachNewThreadSelector:@selector(subThreadSelector3:)
                             toTarget:self
                           withObject:nil];
}

- (void)subThreadSelector1:(id)object
{
    [self executeSetOperation:0];
}

- (void)subThreadSelector2:(id)object
{
    [self executeSetOperation:1];
}

- (void)subThreadSelector3:(id)object
{
    [self executeGetOperation];
}

- (void)executeSetOperation:(int)type
{
    @autoreleasepool {
        NSMutableArray *tableArr = [NSMutableArray array];
        int num = 0;
        do {
            
            NSString *key = [NSString stringWithFormat:@"SetOperation-%d", num];
            ANKeyValueTable *table = [_tableDict objectForKey:key];
            if (nil == table) {
                table = [ANKeyValueTable tableWithName:key version:@"0.0.9" resumable:NO];
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
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if (1 == randNum) {
                            _thread1Label.text = [NSString stringWithFormat:@"Thread 1 Completed"];
                        } else {
                            _thread1Label.text = [NSString stringWithFormat:@"Thread 1 %d", randNum];
                        }
                    });
                } else {
                    
                    [t setValue:@"ABCDEFGHIJKLMNOPQRSTVUWXYZ" withKey:key];

                    dispatch_async(dispatch_get_main_queue(), ^{
                        if (1 == randNum) {
                            _thread2Label.text = [NSString stringWithFormat:@"Thread 2 Completed"];
                        } else {
                            _thread2Label.text = [NSString stringWithFormat:@"Thread 2 %d", randNum];
                        }
                    });
                }
            }
            
            count--;
        }
    }
}

- (void)executeGetOperation
{
    @autoreleasepool {
        
        NSMutableArray *tableArr = [NSMutableArray array];
        int num = 0;
        do {
            
            NSString *key = [NSString stringWithFormat:@"SetOperation-%d", num];
            ANKeyValueTable *table = [_tableDict objectForKey:key];
            if (nil == table) {
                table = [ANKeyValueTable tableWithName:key version:@"0.0.9" resumable:NO];
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
                NSString *value = [t valueWithKey:key];
                if (nil != value) {
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if (1 == randNum) {
                            _thread3Label.text = [NSString stringWithFormat:@"Thread 3 Completed"];
                        } else {
                            _thread3Label.text = [NSString stringWithFormat:@"Thread 3 %d", randNum];
                        }
                    });
                }
            }
            
            count--;
        }
    }
}

@end
