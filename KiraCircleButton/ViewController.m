//
//  ViewController.m
//  KiraCircleButton
//
//  Created by Kira on 2018/7/6.
//  Copyright © 2018 Kira. All rights reserved.
//

#import "ViewController.h"
#import "KiraCircleButton.h"

@interface ViewController ()

@property (nonatomic, strong) KiraCircleButton *button;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.button = [[KiraCircleButton alloc] initWithFrame:CGRectMake(150 , 400, 70, 70)];
    [self.view setBackgroundColor:[UIColor blackColor]];
    [self.view addSubview:self.button];
    // Do any additional setup after loading the view, typically from a nib.
}


@end
