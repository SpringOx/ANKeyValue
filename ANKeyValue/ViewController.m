//
//  ViewController.m
//  ANKeyValue
//
//  Created by SpringOx on 12/24/14.
//  Copyright (c) 2014 SpringOx. All rights reserved.
//

#import "ViewController.h"
#import "ANKeyValueTable.h"
#import "SetDemoViewController.h"
#import "PerformanceViewController.h"
#import "ConcurrentViewController.h"

@interface ViewController ()<UITableViewDataSource, UITableViewDelegate>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.

    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIndentifier = @"TextCell";
    UITableViewCell *textCell = [_tableView dequeueReusableCellWithIdentifier:cellIndentifier];
    if (nil == textCell) {
        textCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIndentifier];
        textCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    if (0 == indexPath.row) {
        textCell.textLabel.text = @"Set & Get";
    } else if (1 == indexPath.row) {
        textCell.textLabel.text = @"Performance";
    } else if (2 == indexPath.row) {
        textCell.textLabel.text = @"Concurrent";
    }
    
    return textCell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    if (0 == indexPath.row) {
        SetDemoViewController *viewCtl = [[SetDemoViewController alloc] initWithNibName:nil bundle:nil];
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        viewCtl.title = cell.textLabel.text;
        [self.navigationController pushViewController:viewCtl animated:YES];
    } else if (1 == indexPath.row) {
        PerformanceViewController *viewCtl = [[PerformanceViewController alloc] initWithNibName:nil bundle:nil];
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        viewCtl.title = cell.textLabel.text;
        [self.navigationController pushViewController:viewCtl animated:YES];
    } else if (2 == indexPath.row) {
        ConcurrentViewController *viewCtl = [[ConcurrentViewController alloc] initWithNibName:nil bundle:nil];
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        viewCtl.title = cell.textLabel.text;
        [self.navigationController pushViewController:viewCtl animated:YES];
    }
    
    [_tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
