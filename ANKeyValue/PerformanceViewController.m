//
//  PerformanceViewController.m
//  ANKeyValue
//
//  Created by SpringOx on 1/24/15.
//  Copyright (c) 2015 SpringOx. All rights reserved.
//

#import "PerformanceViewController.h"
#import "ANKeyValueTable.h"
#import <mach/mach_time.h>

CGFloat BNRTimeBlock (void (^block)(void)) {
    mach_timebase_info_data_t info;
    if (mach_timebase_info(&info) != KERN_SUCCESS) return -1.0;
    
    uint64_t start = mach_absolute_time ();
    block ();
    uint64_t end = mach_absolute_time ();
    uint64_t elapsed = end - start;
    
    uint64_t nanos = elapsed * info.numer / info.denom;
    return (CGFloat)nanos / NSEC_PER_SEC;
}

@interface PerformanceViewController ()
{
    __strong NSMutableDictionary *_tableDict;
}

@end

@implementation PerformanceViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    _tableDict = [NSMutableDictionary dictionary];
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

- (IBAction)didPressSetNumOperationButtonAction:(id)sender {
    
    int num = 0;
    do {
        
        NSString *key = [NSString stringWithFormat:@"SetOperation-%d", num];
        ANKeyValueTable *table = [_tableDict objectForKey:key];
        if (nil == table) {
            table = [ANKeyValueTable tableWithName:key version:@"0.0.9" resumable:YES];
            [_tableDict setObject:table forKey:key];
        }
        [table clear];
        
    } while (10 > ++num);
    
    CGFloat timeInterval1 = BNRTimeBlock(^{
        [self executeSetOperation:0];
    });
    CGFloat timeInterval2 = BNRTimeBlock(^{
        [self executeSetOperation:0];
    });
    CGFloat timeInterval3 = BNRTimeBlock(^{
        [self executeSetOperation:0];
    });
    
    NSString *messsage = [NSString stringWithFormat:@"Calculate:10000 * 10 table\nConsuming:%fs\n(Average of 3 times)",
                          (timeInterval1+timeInterval2+timeInterval3)/3];
    NSLog(@"Set Num Operation: %@", messsage);
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Set Num Operation"
                                                    message:messsage
                                                   delegate:nil
                                          cancelButtonTitle:@"YES"
                                          otherButtonTitles:nil];
    [alert show];
}

- (IBAction)didPressSetStrOperationButtonAction:(id)sender {
    
    int num = 0;
    do {
        
        NSString *key = [NSString stringWithFormat:@"SetOperation-%d", num];
        ANKeyValueTable *table = [_tableDict objectForKey:key];
        if (nil == table) {
            table = [ANKeyValueTable tableWithName:key version:@"0.0.9" resumable:YES];
            [_tableDict setObject:table forKey:key];
        }
        [table clear];
        
    } while (10 > ++num);
    
    CGFloat timeInterval1 = BNRTimeBlock(^{
        [self executeSetOperation:1];
    });
    CGFloat timeInterval2 = BNRTimeBlock(^{
        [self executeSetOperation:1];
    });
    CGFloat timeInterval3 = BNRTimeBlock(^{
        [self executeSetOperation:1];
    });
    
    NSString *messsage = [NSString stringWithFormat:@"Calculate:10000 * 10 table\nConsuming:%fs\n(Average of 3 times)",
                          (timeInterval1+timeInterval2+timeInterval3)/3];
    NSLog(@"Set Str Operation: %@", messsage);
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Set Str Operation"
                                                    message:messsage
                                                   delegate:nil
                                          cancelButtonTitle:@"YES"
                                          otherButtonTitles:nil];
    [alert show];
}

- (IBAction)didPressGetOperationButtonAction:(id)sender {
    
    [self executeSetOperation:1];
    
    CGFloat timeInterval1 = BNRTimeBlock(^{
        [self executeGetOperation];
    });
    CGFloat timeInterval2 = BNRTimeBlock(^{
        [self executeGetOperation];
    });
    CGFloat timeInterval3 = BNRTimeBlock(^{
        [self executeGetOperation];
    });
    
    NSString *messsage = [NSString stringWithFormat:@"Calculate:10000 * 10 table\nConsuming:%fs\n(Average of 3 times)",
                          (timeInterval1+timeInterval2+timeInterval3)/3];
    NSLog(@"Get Str Operation: %@", messsage);
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Get Str Operation"
                                                    message:messsage
                                                   delegate:nil
                                          cancelButtonTitle:@"YES"
                                          otherButtonTitles:nil];
    [alert show];
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
                NSString *value = [t valueWithKey:key];
                if (nil != value) {
                    
                    // do noting
                }
            }
            
            count--;
        }
    }
}

@end
