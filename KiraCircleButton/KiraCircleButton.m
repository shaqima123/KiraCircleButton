//
//  KiraCircleButton.m
//  KiraCircleButton
//
//  Created by Kira on 2018/7/6.
//  Copyright © 2018 Kira. All rights reserved.
//

#import "KiraCircleButton.h"
#import "AnimationFunction.h"

//最大录制时间
static float const maxRecordTime = 3.f;
//初始半径
static float const startRadius = 40.f;
//最大半径
static float const endRadius = 65.f;
//初始圆圈宽度
static float const minLineWidth = 4.f;
//大圆圈宽度
static float const maxLineWidth = 8.f;

//放大动画持续时
static float const scaleDuration = 0.2f;


@interface KiraCircleButton ()

@property (nonatomic, strong) id<AnimationFunction> animationFunction;

@property (nonatomic, strong) UIColor * circleBgColor;
@property (nonatomic, strong) UIColor * circleFgColor;

@property (nonatomic, strong) CADisplayLink *displayLink;
@property (nonatomic, strong) UIVisualEffectView* effectView;
@property (nonatomic, assign) CGPoint centerPoint;

@property (nonatomic, strong) CAShapeLayer *circleLayer;//
@property (nonatomic, strong) CAShapeLayer *maskLayer;
@property (nonatomic, strong) CAShapeLayer *drawLayer;

@property (nonatomic, strong) UIBezierPath *drawPath;
@property (nonatomic, strong) UIBezierPath *maskPath;



@property (nonatomic, assign) CGFloat currentRadius;
@property (nonatomic, assign) float currentLineWidth;

@property (nonatomic, assign) NSTimeInterval beginTime;
@property (nonatomic, assign) BOOL isInProgress;


@end

@implementation KiraCircleButton
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupData];
        [self setupUI];
    }
    return self;
}

- (void)setupData {
    
    self.animationFunction = [[AnimationFunctionEaseOut alloc] init];
    self.circleFgColor = [UIColor colorWithRed:0.99 green:0.72 blue:0.04 alpha:1];
    self.circleBgColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.2];
    
}

- (void)setupUI {
    self.centerPoint = CGPointMake(self.frame.size.width * 0.5, self.frame.size.height * 0.5);
    
    [self setUserInteractionEnabled:YES];
    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doSomeThingWhenTap)];
    [self addGestureRecognizer:tap];
    
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(doSomeThingWhenLongTap:)];
    longPress.minimumPressDuration = 0.2;
    [self addGestureRecognizer:longPress];
    
    //给按钮增加毛玻璃效果
    UIBlurEffect *effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleRegular];
    self.effectView = [[UIVisualEffectView alloc] initWithEffect:effect];
    self.effectView.userInteractionEnabled = NO;
    [self addSubview:self.effectView];
    [self.effectView setFrame:CGRectMake(startRadius - endRadius, startRadius - endRadius, 2 * endRadius, 2 * endRadius)];
    
   
    self.drawLayer = [CAShapeLayer layer];
    self.circleLayer = [CAShapeLayer layer];
    self.maskLayer = [CAShapeLayer layer];
    [self resetCaptureButton];
    
    self.drawLayer.strokeColor = self.circleFgColor.CGColor;
    self.drawLayer.fillColor = [UIColor clearColor].CGColor;
    self.drawLayer.strokeStart = 0;
    self.drawLayer.strokeEnd = 0;
    self.drawLayer.lineCap = kCALineCapRound;
    
    self.circleLayer.fillColor = [UIColor clearColor].CGColor;
    
    [self.layer addSublayer:self.circleLayer];
    [self.layer setMask:self.maskLayer];
    [self.layer addSublayer:self.drawLayer];
}

- (void)resetCaptureButton {
    [self updateStatesWithTime:0];
}

- (void)doAnimation {
    NSTimeInterval currentTime = CACurrentMediaTime() - self.beginTime;
    CGFloat recordPercent = currentTime / maxRecordTime;
    [self updateStatesWithTime:currentTime];
    if (recordPercent > 1) {
        recordPercent = 1;
        [self endProgress];
        return;
    }
}

- (void)updateStatesWithTime:(NSTimeInterval) currentTime {
    CGFloat toRadius = endRadius - maxLineWidth * 0.5;
    CGFloat fromRadius = startRadius - minLineWidth * 0.5;
    
    CGFloat scalePercent = currentTime / scaleDuration;
    CGFloat recordPercent = currentTime / maxRecordTime;

    if (scalePercent > 1) {
        scalePercent = 1;
    }
    if (recordPercent > 1) {
        recordPercent = 1;
    }

    scalePercent = [self.animationFunction calculate:scalePercent withType:AnimationFunctionTypeBounce];
    recordPercent = [self.animationFunction calculate:recordPercent withType:AnimationFunctionTypeBounce];
    
    if (recordPercent) {
        self.drawLayer.hidden = NO;
    } else {
        self.drawLayer.hidden = YES;
    }
    
    self.currentRadius = [self interpolateFrom:fromRadius to:toRadius percent:scalePercent];
    self.currentLineWidth = [self interpolateFrom:minLineWidth to:maxLineWidth percent:scalePercent];
    
    self.drawPath = [UIBezierPath bezierPathWithArcCenter:self.centerPoint radius:self.currentRadius startAngle:- M_PI_2 endAngle:3 * M_PI_2 clockwise:YES];
    self.drawLayer.path = self.drawPath.CGPath;
    self.drawLayer.lineWidth = self.currentLineWidth;;

    self.circleLayer.path = self.drawPath.CGPath;
    self.circleLayer.lineWidth = self.currentLineWidth;
    
    float alpha = [self interpolateFrom:1 to:0.2 percent:scalePercent];
    self.circleBgColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:alpha];
    self.circleLayer.strokeColor = self.circleBgColor.CGColor;
    
    self.effectView.alpha = [self interpolateFrom:1 to:0 percent:scalePercent];
    
    self.maskPath = [UIBezierPath bezierPathWithArcCenter:self.centerPoint radius:self.currentRadius + self.currentLineWidth * 0.5 startAngle:0 endAngle:M_PI * 2 clockwise:YES];
    self.maskLayer.path = self.maskPath.CGPath;
    [self.layer setMask:self.maskLayer];
    
    self.drawLayer.strokeEnd = [self interpolateFrom:0 to:1 percent:recordPercent];
}

- (CGFloat)interpolateFrom:(CGFloat)from to:(CGFloat)to percent:(CGFloat)percent {
    return from + (to - from) * percent;
}

- (void)doSomeThingWhenTap {
    NSLog(@"Im tapped");
}

- (void)doSomeThingWhenLongTap:(UILongPressGestureRecognizer *)gesture {
    if (gesture.state == UIGestureRecognizerStateBegan) {
        NSLog(@"Im long tapped start");
        [self startProgress];
    } else if (gesture.state == UIGestureRecognizerStateEnded) {
        NSLog(@"Im long tapped end");
        [self endProgress];
    }
}


- (void)startProgress {
    NSLog(@"progress start");
    self.displayLink = [CADisplayLink displayLinkWithTarget:self
                                                   selector:@selector(doAnimation)];
    self.displayLink.paused = NO;
    [self.displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    self.beginTime = CACurrentMediaTime();
    self.isInProgress = YES;
    if (self.delegate && [self.delegate respondsToSelector:@selector(startProgress)]) {
        [self.delegate startProgress];
    }
}

- (void)endProgress {
    if (!self.isInProgress) {
        return;
    }
    NSLog(@"progress end");
    self.isInProgress = NO;
    self.displayLink.paused = YES;
    [self.displayLink invalidate];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(),^{
        [self resetCaptureButton];
    });
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(endProgress)]) {
        [self.delegate endProgress];
    }
}

@end
