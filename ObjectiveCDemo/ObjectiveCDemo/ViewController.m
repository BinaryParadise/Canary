//
//  ViewController.m
//  ObjectiveCDemo
//
//  Created by Rake Yang on 2020/12/13.
//

#import "ViewController.h"
#import <Canary/Canary-Swift.h>

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    NSLog(@"获取配置参数：A = %@", [CanarySwift.shared stringValueFor:@"A" def:@"123"]);
}


@end
