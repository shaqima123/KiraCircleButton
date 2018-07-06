//
//  KiraCircleButton.m
//  KiraCircleButton
//
//  Created by Kira on 2018/7/6.
//  Copyright © 2018 Kira. All rights reserved.
//

#import "KiraCircleButton.h"
//最大录制时间
static float const maxRecordTime = 10.f;
//初始半径
static float const startRadius = 35.f;
//最大半径
static float const endRadius = 50.f;
//圆圈宽度
static float const lineWidth = 6.f;

@interface KiraCircleButton ()

@property (nonatomic, strong) CAShapeLayer *circleLayer;
@property (nonatomic, strong) CAShapeLayer *maskLayer;
@property (nonatomic, strong) CAShapeLayer *drawLayer;

@property (nonatomic, strong) CADisplayLink *displayLink;
@property (nonatomic, assign) CGFloat currentRadius;
@property (nonatomic, strong) UIVisualEffectView* effectView;
@property (nonatomic, assign) CGPoint centerPoint;
@property (nonatomic, assign) float currentRecordTime;

@end

@implementation KiraCircleButton
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initUI];
    }
    return self;
}

- (void)initUI {
    self.centerPoint = CGPointMake(self.frame.size.width / 2, self.frame.size.height / 2);
    [self setUserInteractionEnabled:YES];
    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doSomeThingWhenTap)];
    [self addGestureRecognizer:tap];
    
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(doSomeThingWhenLongTap:)];
    longPress.minimumPressDuration = 0.2;
    longPress.delegate = self;
    [self addGestureRecognizer:longPress];
    
    //给按钮增加毛玻璃效果
    UIBlurEffect *effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleRegular];
    self.effectView = [[UIVisualEffectView alloc] initWithEffect:effect];
    self.effectView.userInteractionEnabled = NO;
    [self addSubview:self.effectView];
    [self.effectView setFrame:CGRectMake(startRadius - endRadius, startRadius - endRadius, 2 * endRadius, 2 * endRadius)];
    
    UIBezierPath *backPath = [UIBezierPath bezierPathWithArcCenter:self.centerPoint radius:endRadius - lineWidth/2 startAngle:- M_PI_2 endAngle:3 * M_PI_2 clockwise:YES];
    
    CAShapeLayer *secondLayer = [CAShapeLayer layer];
    secondLayer.strokeColor = [UIColor colorWithRed:1 green:64.f/255.f blue:64.f/255.f alpha:1].CGColor;
    secondLayer.lineWidth = lineWidth;
    secondLayer.fillColor = [UIColor clearColor].CGColor;
    secondLayer.path = backPath.CGPath;
    secondLayer .strokeStart = 0;
    secondLayer.strokeEnd = 0;
    _drawLayer = secondLayer;
    
    _circleLayer = [CAShapeLayer layer];
    
    _maskLayer = [CAShapeLayer layer];
    
    [self resetCaptureButton];
    
    [self.layer addSublayer:_circleLayer];
    
    [self.layer setMask:_maskLayer];
    
    [self.layer addSublayer:secondLayer];
}

- (void)resetCaptureButton {
    _currentRecordTime = 0;
    
    CGPoint center = self.centerPoint;
    _currentRadius = startRadius - lineWidth/2;
    UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:center radius:_currentRadius startAngle:0 endAngle:M_PI * 2 clockwise:YES];
    _circleLayer.path = path.CGPath;
    _circleLayer.lineWidth = lineWidth;
    _circleLayer.strokeColor = [UIColor whiteColor].CGColor;
    _circleLayer.fillColor = [UIColor clearColor].CGColor;
    
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithArcCenter:center radius:_currentRadius + 2 startAngle:0 endAngle:M_PI * 2 clockwise:YES];
    _maskLayer.path = maskPath.CGPath;
    
    self.drawLayer.strokeStart = 0;
    self.drawLayer.strokeEnd = 0;
}

- (void)changeRadius {
    CGFloat toValue = endRadius - lineWidth/2;
    CGFloat fromValue = startRadius - lineWidth/2;
    CGFloat duration = 0.2;
    CGFloat times = 60 * duration;
    CGFloat delta = (toValue - fromValue) / times;
    _currentRecordTime += 1.f/60;
    _currentRadius += delta;
    if (_currentRadius <= toValue) {
        UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:self.centerPoint radius: _currentRadius startAngle:0 endAngle:M_PI * 2 clockwise:YES];
        _circleLayer.path = path.CGPath;
        _circleLayer.lineWidth = lineWidth;

        UIBezierPath *maskPath = [UIBezierPath bezierPathWithArcCenter:self.centerPoint radius:_currentRadius + 2 startAngle:0 endAngle:M_PI * 2 clockwise:YES];
        _maskLayer = [CAShapeLayer layer];
        _maskLayer.path = maskPath.CGPath;
        [self.layer setMask:_maskLayer];
    } else {
        CGFloat delta = 1 / (maxRecordTime * 60);
        self.drawLayer.strokeEnd += delta;
        if (self.drawLayer.strokeEnd >= 1) {
            self.displayLink.paused = YES;
            if (self.delegate && [self.delegate respondsToSelector:@selector(endProgress)]) {
                [self.delegate endProgress];
            }
        }
    }
    
}

- (void)doSomeThingWhenTap {
    NSLog(@"Im tapped");
}

- (void)doSomeThingWhenLongTap:(UILongPressGestureRecognizer *)gesture {
    if (gesture.state == UIGestureRecognizerStateBegan) {
        NSLog(@"Im long tapped start");
        self.displayLink = [CADisplayLink displayLinkWithTarget:self
                                                       selector:@selector(changeRadius)];
        [self.displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
        self.displayLink.paused = NO;
        if (self.delegate && [self.delegate respondsToSelector:@selector(startProgress)]) {
            [self.delegate startProgress];
        }
    } else if (gesture.state == UIGestureRecognizerStateEnded) {
        NSLog(@"Im long tapped end");
        //end
        self.displayLink.paused = YES;
        if (self.delegate && [self.delegate respondsToSelector:@selector(endProgress)]) {
            [self.delegate endProgress];
        }
        [self resetCaptureButton];
    }
}

@end
