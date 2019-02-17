//
//  ViewController.m
//  KiraCircleButton
//
//  Created by Kira on 2018/7/6.
//  Copyright © 2018 Kira. All rights reserved.
//

#import "ViewController.h"
#import "KiraCircleButton.h"
#import "KiraCircleButtonTestViewController.h"

@interface ViewController ()<
KiraCircleButtonTestViewControllerDelegate,
KiraCircleButtonDelegate>

@property (nonatomic, strong) KiraCircleButton *button;
@property (nonatomic, strong) UIButton *animationConfigureButton;
@property (nonatomic, strong) UILabel *configureLabel;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.button = [[KiraCircleButton alloc] initWithFrame:CGRectMake(150 , 400, 80, 80)];
    [self animationConfigureButton];
    [self configureLabel];
    [self.view setBackgroundColor:[UIColor blackColor]];
    [self.view addSubview:self.button];
    // Do any additional setup after loading the view, typically from a nib.
}

- (UILabel *)configureLabel {
    if (!_configureLabel) {
        _configureLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 100, 300, 100)];
        [_configureLabel setFont:[UIFont systemFontOfSize:14.f]];
        [_configureLabel setTextColor:[UIColor redColor]];
        [_configureLabel setBackgroundColor:[UIColor clearColor]];
        _configureLabel.numberOfLines = 0;
        [_configureLabel setText:[self.button getConfigureString]];
        [self.view addSubview:_configureLabel];
    }
    return _configureLabel;
}

- (UIButton *)animationConfigureButton {
    if (!_animationConfigureButton) {
        _animationConfigureButton = [[UIButton alloc] initWithFrame:CGRectMake(150, 600, 100, 50)];
        [_animationConfigureButton setTitle:@"配置动画" forState:UIControlStateNormal];
        [_animationConfigureButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_animationConfigureButton setBackgroundColor:[UIColor colorWithRed:1 green:1 blue:0.8 alpha:1]];
        [_animationConfigureButton addTarget:self action:@selector(actionToConfigure) forControlEvents:UIControlEventTouchUpInside];

        
        [self.view addSubview:_animationConfigureButton];
    }
    return _animationConfigureButton;
}

- (void)actionToConfigure {
    KiraCircleButtonTestViewController *viewController = [[KiraCircleButtonTestViewController alloc] init];
    viewController.delegate = self;
    [self presentViewController:viewController animated:YES completion:nil];
}

#pragma mark Test RSCaptureButtonTestViewControllerDelegate

- (void)finishConfigureWithAnimateDuration1:(float)duration1
                                  duration2:(float)duration2
                             animationKind1:(NSInteger)animationKind1
                             animationKind2:(NSInteger)animationKind2
                                  function1:(NSInteger)function1
                                  function2:(NSInteger)function2 {
    [self.button configureWithScaleDuration:duration1
                                    recordDuration:duration2
                                  scaleAnimateKind:animationKind1
                                 recordAnimateKind:animationKind2
                              scaleAnimateFunction:function1
                             recordAnimateFunction:function2];
    [self.configureLabel setText:[self.button getConfigureString]];
}


@end
