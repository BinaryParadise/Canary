//
//  ViewController.m
//  Canary_Exampe_OC
//
//  Created by Rake Yang on 2020/3/19.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

#import "ViewController.h"
@import Canary;

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (IBAction)showConfig:(id)sender {
    [CNManager.manager show];
}


@end
