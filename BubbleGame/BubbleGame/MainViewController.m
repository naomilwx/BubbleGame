//
//  ViewController.m
//  BubbleGame
//
//  Created by Naomi Leow on 21/2/14.
//  Copyright (c) 2014 nus.cs3217. All rights reserved.
//

#import "MainViewController.h"

@interface MainViewController ()

@end

@implementation MainViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    [self loadBackground];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)menuButtonPressed:(UIButton *)sender {
    NSLog(@"sender %@", [[sender titleLabel] text]);
}

- (void)loadBackground{
    self.menuBackground.contentMode = UIViewContentModeScaleAspectFit;
    self.menuBackground.clipsToBounds = YES;
    self.menuBackground.userInteractionEnabled = YES;
    UIImage *background = [UIImage imageNamed:@"MenuBackground"];
    [self.menuBackground setImage:background];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
}

@end
