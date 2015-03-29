//
//  ConcurrentViewController.h
//  ANKeyValue
//
//  Created by SpringOx on 3/24/15.
//  Copyright (c) 2015 SpringOx. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ConcurrentViewController : UIViewController

@property (weak, nonatomic) IBOutlet UILabel *thread1Label;
@property (weak, nonatomic) IBOutlet UILabel *thread2Label;
@property (weak, nonatomic) IBOutlet UILabel *thread3Label;
@property (weak, nonatomic) IBOutlet UIButton *startButton;

- (IBAction)didPressStartButtonAction:(id)sender;

@end
