//
//  KiraCircleButtonTestViewController.m
//  RealSocial
//
//  Created by Kira on 2019/2/16.
//  Copyright © 2019 skyplan. All rights reserved.
//

#import "KiraCircleButtonTestViewController.h"

@interface KiraCircleButtonTestViewController ()<
UIPickerViewDataSource,
UIPickerViewDelegate
>

@property (nonatomic, strong) UIButton *cancelButton;
@property (nonatomic, strong) UIButton *finishButton;

@property (nonatomic, strong) UITextView *textView1;
@property (nonatomic, strong) UITextView *textView2;

@property (nonatomic, strong) UIPickerView * pickerView;
@property (nonatomic, strong) UIButton *pickerCancelButton;
@property (nonatomic, strong) UIButton *pickerFinishButton;
@property (nonatomic, strong) UILabel *pickerTipLabel;

@property (nonatomic, strong)NSArray * animationKindArray;
@property (nonatomic, strong)NSArray * animationFuncArray;

@property (nonatomic, strong) UIButton *chooseButton1;
@property (nonatomic, strong) UIButton *chooseButton2;

@property (nonatomic, strong) UILabel *animateLabel1;
@property (nonatomic, strong) UILabel *animateLabel2;

@property (nonatomic, assign) BOOL isScaleAnimation;

@property (nonatomic, assign) NSInteger selectAnimateKind1;
@property (nonatomic, assign) NSInteger selectAnimateKind2;

@property (nonatomic, assign) NSInteger selectAnimateFunc1;
@property (nonatomic, assign) NSInteger selectAnimateFunc2;

@property (nonatomic, assign) float animationDuration1;
@property (nonatomic, assign) float animationDuration2;

@end

@implementation KiraCircleButtonTestViewController
- (void)loadData {
    self.animationKindArray = @[@"Linear(线性)",@"EaseIn(渐进)",@"EaseOut(渐出)",@"EaseInOut"];
    
    self.animationFuncArray = @[@""];
    
    self.selectAnimateKind1 = 0;
    self.selectAnimateKind2 = 0;
    
    self.selectAnimateFunc1 = 0;
    self.selectAnimateFunc2 = 0;
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor whiteColor]];
    [self loadData];
    
    self.cancelButton = ({
        UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(40, self.view.bounds.size.height - 150, 100, 50)];
        [button setTitle:@"取消" forState:UIControlStateNormal];
        [button setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        [button addTarget:self
                   action:@selector(cancelButtonDidClick) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:button];
        button;
    });
    
    self.finishButton = ({
        UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(self.view.bounds.size.width - 140, self.view.bounds.size.height - 150, 100, 50)];
        [button setTitle:@"完成" forState:UIControlStateNormal];
        [button setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        [button addTarget:self
                   action:@selector(finishButtonDidClick) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:button];
        button;
    });
    
    UILabel *label1 = [[UILabel alloc] initWithFrame:CGRectMake(20, 100, 300, 50)];
    [label1 setFont:[UIFont systemFontOfSize:20.f]];
    [label1 setTextColor:[UIColor blackColor]];
    [label1 setText:@"放大动画持续时间(0,5]"];
    [self.view addSubview:label1];
    
    self.textView1 = [[UITextView alloc] initWithFrame:CGRectMake(20, 150, 100, 30)];
    [self.textView1 setTextColor:[UIColor blackColor]];
    [self.textView1 setFont:[UIFont systemFontOfSize:20]];
    [self.textView1 setBackgroundColor:[UIColor colorWithRed:33.f/255.f green:33.f/255.f blue:33.f/255.f alpha:0.2]];
    [self.view addSubview:self.textView1];
    
    UILabel *label2 = [[UILabel alloc] initWithFrame:CGRectMake(20, 200, 300, 50)];
    [label2 setFont:[UIFont systemFontOfSize:20.f]];
    [label2 setTextColor:[UIColor blackColor]];
    [label2 setText:@"录制进度动画持续时间[5,15]"];
    [self.view addSubview:label2];
    
    self.textView2 = [[UITextView alloc] initWithFrame:CGRectMake(20, 260, 100, 30)];
    [self.textView2 setTextColor:[UIColor blackColor]];
    [self.textView2 setFont:[UIFont systemFontOfSize:20]];
    [self.textView2 setBackgroundColor:[UIColor colorWithRed:33.f/255.f green:33.f/255.f blue:33.f/255.f alpha:0.2]];
    [self.view addSubview:self.textView2];
    
    
    UILabel *label3 = [[UILabel alloc] initWithFrame:CGRectMake(20, 310, 300, 50)];
    [label3 setFont:[UIFont systemFontOfSize:20.f]];
    [label3 setTextColor:[UIColor blackColor]];
    [label3 setText:@"放大动画缓动函数:"];
    [self.view addSubview:label3];
    
    self.chooseButton1 = ({
        UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(20, 370, 100, 50)];
        [button setTitle:@"点击选择" forState:UIControlStateNormal];
        [button setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        [button addTarget:self
                   action:@selector(actionChooseButton1) forControlEvents:UIControlEventTouchUpInside];
        button.adjustsImageWhenHighlighted = NO;
        button.showsTouchWhenHighlighted = YES;
        [self.view addSubview:button];
        button;
    });
    
    
    self.animateLabel1 = [[UILabel alloc] initWithFrame:CGRectMake(130, 370, 300, 50)];
    [self.animateLabel1 setFont:[UIFont systemFontOfSize:20.f]];
    [self.animateLabel1 setTextColor:[UIColor blackColor]];
    [self.animateLabel1 setText:@"放大动画缓动函数:"];
    [self.animateLabel1 setText:[NSString stringWithFormat:@"%@:%@",
                                 [self.animationKindArray objectAtIndex:self.selectAnimateKind1],[self.animationFuncArray objectAtIndex: self.selectAnimateFunc1]]];
    [self.view addSubview:self.animateLabel1];
    
    UILabel *label4 = [[UILabel alloc] initWithFrame:CGRectMake(20, 440, 300, 50)];
    [label4 setFont:[UIFont systemFontOfSize:20.f]];
    [label4 setTextColor:[UIColor blackColor]];
    [label4 setText:@"录制进度动画缓动函数:"];
    
    [self.view addSubview:label4];
    
    self.chooseButton2 = ({
        UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(20, 500, 100, 50)];
        [button setTitle:@"点击选择" forState:UIControlStateNormal];
        [button setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        [button addTarget:self
                   action:@selector(actionChooseButton2) forControlEvents:UIControlEventTouchUpInside];
        button.adjustsImageWhenHighlighted = NO;
        button.showsTouchWhenHighlighted = YES;
        [self.view addSubview:button];
        button;
    });
    
    self.animateLabel2 = [[UILabel alloc] initWithFrame:CGRectMake(130, 500, 300, 50)];
    [self.animateLabel2 setFont:[UIFont systemFontOfSize:20.f]];
    [self.animateLabel2 setTextColor:[UIColor blackColor]];
    [self.animateLabel2 setText:@"放大动画缓动函数:"];
    
    [self.animateLabel2 setText:[NSString stringWithFormat:@"%@:%@",
                                 [self.animationKindArray objectAtIndex:self.selectAnimateKind2],[self.animationFuncArray objectAtIndex: self.selectAnimateFunc2]]];
    [self.view addSubview:self.animateLabel2];
    
    self.pickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(0, [UIScreen mainScreen].bounds.size.height + 50, [UIScreen mainScreen].bounds.size.width, 300)];
    [self.pickerView setBackgroundColor:[UIColor colorWithRed:33.f/255.f green:33.f/255.f blue:33.f/255.f alpha:0.2]];
    self.pickerView.dataSource = self;
    self.pickerView.delegate = self;
    [self.view addSubview:self.pickerView];
    
    self.pickerCancelButton = ({
        UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(20, [UIScreen mainScreen].bounds.size.height + 20 - 8, 100, 30)];
        [button setTitle:@"取消" forState:UIControlStateNormal];
        [button setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        [button addTarget:self
                   action:@selector(pickerCancelButtonDidClick) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:button];
        button;
    });
    
    self.pickerFinishButton = ({
        UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width - 120, [UIScreen mainScreen].bounds.size.height + 20 - 8, 100, 30)];
        [button setTitle:@"完成" forState:UIControlStateNormal];
        [button setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        [button addTarget:self
                   action:@selector(pickerFinishButtonDidClick) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:button];
        button;
    });
    
    self.pickerTipLabel = ({
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, self.pickerView.frame.origin.y + 8, 300, 50)];
        [label setFont:[UIFont systemFontOfSize:20.f]];
        [label setTextColor:[UIColor blackColor]];
        [self.view addSubview:label];
        label;
    });
}

- (BOOL)checkData {
    NSString *warningString = @"";
    if (!self.textView1.text.length || !self.textView2.text.length) {
        warningString = @"请输入动画的持续时间";
    } else {
        if ([self.textView1.text floatValue] <= 0 || [self.textView1.text floatValue] > 5) {
            warningString = @"建议放大动画的持续时间设置在0到5秒之间";
        }
        
        if ([self.textView2.text floatValue] < 5 || [self.textView2.text floatValue] > 15) {
            warningString = @"建议录制动画的持续时间设置在5到15秒之间";
        }
    }
    
    if(warningString.length) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"提示", nil) message:NSLocalizedString(warningString, nil) preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"知道了哥", nil) style:UIAlertActionStyleCancel handler:nil];
        
        [alertController addAction:cancelAction];
        [self presentViewController:alertController animated:YES completion:nil];
        return NO;
    }
    return YES;
}

- (void)finishButtonDidClick {
    if([self checkData]) {
        self.animationDuration1 = [self.textView1.text floatValue];
        self.animationDuration2 = [self.textView2.text floatValue];
        if ([self.delegate respondsToSelector:@selector(finishConfigureWithAnimateDuration1:duration2:animationKind1:animationKind2:function1:function2:)]) {
            [self.delegate finishConfigureWithAnimateDuration1:self.animationDuration1 duration2:self.animationDuration2 animationKind1:self.selectAnimateKind1 animationKind2:self.selectAnimateKind2 function1:self.selectAnimateFunc1 function2:self.selectAnimateFunc2];
        }
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)cancelButtonDidClick {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)pickerCancelButtonDidClick {
    [UIView animateWithDuration:0.25 animations:^{
        [self.pickerView setFrame:CGRectMake(0, [UIScreen mainScreen].bounds.size.height + 50, [UIScreen mainScreen].bounds.size.width, 300)];
        [self.pickerCancelButton setFrame:CGRectMake(20, [UIScreen mainScreen].bounds.size.height + 20 - 8, 100, 30)];
        [self.pickerFinishButton setFrame:CGRectMake([UIScreen mainScreen].bounds.size.width - 120, [UIScreen mainScreen].bounds.size.height + 20 - 8, 100, 30)];
        [self.pickerTipLabel setFrame:CGRectMake(10, self.pickerView.frame.origin.y + 8, 300, 50)];
    }];
    self.cancelButton.hidden = NO;
    self.finishButton.hidden = NO;
}

- (void)pickerFinishButtonDidClick {
    [self.view layoutIfNeeded];
    [UIView animateWithDuration:0.25 animations:^{
        [self.pickerView setFrame:CGRectMake(0, [UIScreen mainScreen].bounds.size.height + 50, [UIScreen mainScreen].bounds.size.width, 300)];
        [self.pickerCancelButton setFrame:CGRectMake(20, [UIScreen mainScreen].bounds.size.height + 20 - 8, 100, 30)];
        [self.pickerFinishButton setFrame:CGRectMake([UIScreen mainScreen].bounds.size.width - 120, [UIScreen mainScreen].bounds.size.height + 20 - 8, 100, 30)];
        [self.pickerTipLabel setFrame:CGRectMake(10, self.pickerView.frame.origin.y + 8, 300, 50)];
    }];
    self.cancelButton.hidden = NO;
    self.finishButton.hidden = NO;
}

- (void)actionChooseButton1 {
    self.isScaleAnimation = YES;
    [self.pickerTipLabel setText:@"正在选择放大动画的缓动函数..."];
    [self.pickerView selectRow:self.selectAnimateKind1 inComponent:0 animated:NO];
    [self.pickerView selectRow:self.selectAnimateFunc1 inComponent:1 animated:NO];
    
    [UIView animateWithDuration:0.25 animations:^{
        [self.pickerView setFrame:CGRectMake(0, [UIScreen mainScreen].bounds.size.height - 300, [UIScreen mainScreen].bounds.size.width, 300)];
        [self.pickerCancelButton setFrame:CGRectMake(20, [UIScreen mainScreen].bounds.size.height + 20 - 8 - 350, 100, 30)];
        [self.pickerFinishButton setFrame:CGRectMake([UIScreen mainScreen].bounds.size.width - 120, [UIScreen mainScreen].bounds.size.height + 20 - 8 - 350, 100, 30)];
        [self.pickerTipLabel setFrame:CGRectMake(10, self.pickerView.frame.origin.y + 8, 300, 50)];
    }];
    
    self.cancelButton.hidden = YES;
    self.finishButton.hidden = YES;
}

- (void)actionChooseButton2 {
    self.isScaleAnimation = NO;
    [self.pickerTipLabel setText:@"正在选择录制动画的缓动函数..."];
    [self.pickerView selectRow:self.selectAnimateKind2 inComponent:0 animated:NO];
    [self.pickerView selectRow:self.selectAnimateFunc2 inComponent:1 animated:NO];
    
    [self.view layoutIfNeeded];
    [UIView animateWithDuration:0.25 animations:^{
        [self.pickerView setFrame:CGRectMake(0, [UIScreen mainScreen].bounds.size.height - 300, [UIScreen mainScreen].bounds.size.width, 300)];
        [self.pickerCancelButton setFrame:CGRectMake(20, [UIScreen mainScreen].bounds.size.height + 20 - 8 - 350, 100, 30)];
        [self.pickerFinishButton setFrame:CGRectMake([UIScreen mainScreen].bounds.size.width - 120, [UIScreen mainScreen].bounds.size.height + 20 - 8 - 350, 100, 30)];
        [self.pickerTipLabel setFrame:CGRectMake(10, self.pickerView.frame.origin.y + 8, 300, 50)];
    }];
    self.cancelButton.hidden = YES;
    self.finishButton.hidden = YES;
}

-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 2;
}

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    NSInteger result = 0;
    switch (component) {
        case 0:
            result = self.animationKindArray.count;
            break;
        case 1:
            result = self.animationFuncArray.count;
            break;
        default:
            break;
    }
    
    return result;
}

-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    NSString * title = nil;
    switch (component) {
        case 0:
            title = self.animationKindArray[row];
            break;
        case 1:
            title = self.animationFuncArray[row];
            break;
        default:
            break;
    }
    
    return title;
}

-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    switch (component) {
        case 0:
        {
            if (row == 0) {
                self.animationFuncArray = @[@""];
                if (self.isScaleAnimation) {
                    self.selectAnimateFunc1 = 0;
                } else {
                    self.selectAnimateFunc2 = 0;
                }
            } else {
                self.animationFuncArray =  @[@"Quadratic",
                                             @"Cubic",
                                             @"Quartic",
                                             @"Quintic",
                                             @"Sine",
                                             @"Circular",
                                             @"Exponential",
                                             @"Elastic",
                                             @"Back",
                                             @"Bounce"];
            
            }
            [self.pickerView reloadComponent:1];
            if (self.isScaleAnimation) {
                self.selectAnimateKind1 = row;
            } else {
                self.selectAnimateKind2 = row;
            }
        }
            break;
        case 1:
        {
            if (self.isScaleAnimation) {
                self.selectAnimateFunc1 = row;
            } else {
                self.selectAnimateFunc2 = row;
            }
        }
            break;
            
        default:
            break;
    }
    
    if (self.isScaleAnimation) {
        [self.animateLabel1 setText:[NSString stringWithFormat:@"%@:%@",
                                     [self.animationKindArray objectAtIndex:self.selectAnimateKind1],[self.animationFuncArray objectAtIndex: self.selectAnimateFunc1]]];
    } else {
        [self.animateLabel2 setText:[NSString stringWithFormat:@"%@:%@",
                                     [self.animationKindArray objectAtIndex:self.selectAnimateKind2],[self.animationFuncArray objectAtIndex: self.selectAnimateFunc2]]];
    }
    
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}
@end
