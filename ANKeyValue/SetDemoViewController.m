//
//  SetDemoViewController.m
//  ANKeyValue
//
//  Created by SpringOx on 1/12/15.
//  Copyright (c) 2015 SpringOx. All rights reserved.
//

#import "SetDemoViewController.h"
#import "ANKeyValueTable.h"
#import "SetDemoItem.h"
#import "TableHelper.h"

@interface SetDemoViewController ()

@property (nonatomic, strong) NSMutableArray *itemList;

@end

@implementation SetDemoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    UIBarButtonItem *addButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Add"
                                                                      style:UIBarButtonItemStylePlain
                                                                     target:self
                                                                     action:@selector(didPressAddButtonAction:)];
    self.navigationItem.rightBarButtonItem = addButtonItem;
    
    self.itemList = [[TableHelper getSetItemTable] containerWithKey:@"setItemList"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSString *)date:(NSDate *)date stringWithFormat:(NSString *)string
{
    static NSDateFormatter *localDateFormatter = nil;
    if (nil == localDateFormatter) {
        localDateFormatter = [[NSDateFormatter alloc] init];
        [localDateFormatter setLocale:[NSLocale currentLocale]];
        [localDateFormatter setDateStyle:NSDateFormatterMediumStyle];
        [localDateFormatter setTimeStyle:NSDateFormatterShortStyle];
    }
    [localDateFormatter setDateFormat:string];
    return [localDateFormatter stringFromDate:date];
}

- (void)didPressAddButtonAction:(id)sender
{
    NSString *dateKey = [self date:[NSDate date] stringWithFormat:@"yyyy/MM/dd hh:mm"];
    [self insertCellWithKey:dateKey];
}

- (void)insertCellWithKey:(NSString *)key
{
    int randNum = arc4random();
    SetDemoItem *item = [[SetDemoItem alloc] init];
    item.timeStr = key;
    item.randNum = randNum;
    
    if (nil == self.itemList) {
        self.itemList = [NSMutableArray array];
    }
    [self.itemList addObject:item];
    
    [[TableHelper getSetItemTable] setContainer:self.itemList withKey:@"setItemList"];
    
    [self.tableView reloadData];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.itemList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIndentifier = @"TextCell";
    UITableViewCell *textCell = [_tableView dequeueReusableCellWithIdentifier:cellIndentifier];
    if (nil == textCell) {
        textCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIndentifier];
        textCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        textCell.detailTextLabel.adjustsFontSizeToFitWidth = YES;
    }
    
    SetDemoItem *item = [self.itemList objectAtIndex:indexPath.row];
    textCell.textLabel.text = item.timeStr;
    textCell.detailTextLabel.text = [NSString stringWithFormat:@"%2X", item.randNum];
    
    return textCell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *key = [tableView cellForRowAtIndexPath:indexPath].textLabel.text;
    [self insertCellWithKey:key];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.itemList removeObjectAtIndex:indexPath.row];
    [[TableHelper getSetItemTable] synchronize];
    
    [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationLeft];
}

@end
