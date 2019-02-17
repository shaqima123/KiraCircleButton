//
//  KiraCircleButton.m
//  KiraCircleButton
//
//  Created by Kira on 2018/7/6.
//  Copyright © 2018 Kira. All rights reserved.
//

#import "KiraCircleButton.h"
#import "AnimationFunction.h"

//初始半径
static float const startRadius = 40.f;
//最大半径
static float const endRadius = 65.f;
//初始圆圈宽度
static float const minLineWidth = 4.f;
//大圆圈宽度
static float const maxLineWidth = 8.f;

@interface KiraCircleButton ()<UIGestureRecognizerDelegate>

@property (nonatomic, assign) float scaleDuration;
@property (nonatomic, assign) float maxRecordTime;

@property (nonatomic, strong) id<AnimationFunction> animationFunction;
@property (nonatomic, strong) id<AnimationFunction> scaleAnimationFunction;

@property (nonatomic, assign) AnimationFunctionType scaleFunctionType;
@property (nonatomic, assign) AnimationFunctionType recordFunctionType;

@property (nonatomic, strong) UITapGestureRecognizer *tapGesture;
@property (nonatomic, strong) UILongPressGestureRecognizer *longTapGesture;
@property (nonatomic, strong) UIPanGestureRecognizer *panGesture;

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
@property (nonatomic, assign) NSTimeInterval currentTime;
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
    self.scaleDuration = 0.2f;
    self.maxRecordTime = kCaptureButtonMaxRecordTime;
    
    self.animationFunction = [[AnimationFunctionEaseOut alloc] init];
    self.scaleAnimationFunction = [[AnimationFunctionLinear alloc] init];
    
    self.scaleFunctionType = AnimationFunctionTypeCubic;
    self.recordFunctionType = AnimationFunctionTypeQuadratic;
    
    self.circleFgColor = [UIColor colorWithRed:0.99 green:0.72 blue:0.04 alpha:1];
    self.circleBgColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.2];
    
}

- (void)layoutSubviews {
    self.centerPoint = CGPointMake(self.bounds.size.width * 0.5, self.bounds.size.height * 0.5);
    [self resetCaptureButton];
}


- (void)setupUI {
    self.centerPoint = CGPointMake(self.bounds.size.width * 0.5, self.bounds.size.height * 0.5);
    
    [self setUserInteractionEnabled:YES];
    self.tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doSomeThingWhenTap:)];
    self.tapGesture.delegate = self;
    [self addGestureRecognizer:self.tapGesture];
    
    self.longTapGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(doSomeThingWhenLongTap:)];
    self.longTapGesture.minimumPressDuration = 0.2;
    self.longTapGesture.delegate = self;
    [self addGestureRecognizer:self.longTapGesture];
    
    self.panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(doSomeThingWhenPan:)];
    self.panGesture.delegate = self;
    [self addGestureRecognizer:self.panGesture];
    
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

- (void)disableGesture:(Class)gestureClass {
    if (gestureClass == [UITapGestureRecognizer class]) {
        self.tapGesture.enabled = NO;
    }
    if (gestureClass == [UILongPressGestureRecognizer class]) {
        self.longTapGesture.enabled = NO;
    }
    if (gestureClass == [UIPanGestureRecognizer class]) {
        self.panGesture.enabled = NO;
    }
}


- (void)doAnimation {
    self.currentTime = CACurrentMediaTime() - self.beginTime;
    CGFloat recordPercent = self.currentTime / kCaptureButtonMaxRecordTime;
    [self updateStatesWithTime:self.currentTime];
    if (recordPercent > 1) {
        recordPercent = 1;
        [self endProgress];
        return;
    }
}

- (void)updateStatesWithTime:(NSTimeInterval) currentTime {
    CGFloat toRadius = endRadius - maxLineWidth * 0.5;
    CGFloat fromRadius = startRadius - minLineWidth * 0.5;
    
    CGFloat scalePercent = currentTime / self.scaleDuration;
    CGFloat recordPercent = currentTime / self.maxRecordTime;

    if (scalePercent > 1) {
        scalePercent = 1;
    }
    if (recordPercent > 1) {
        recordPercent = 1;
    }

    scalePercent = [self.scaleAnimationFunction calculate:scalePercent withType:self.scaleFunctionType];
    recordPercent = [self.animationFunction calculate:recordPercent withType:self.recordFunctionType];
    
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

- (void)doSomeThingWhenTap:(UITapGestureRecognizer *)tap {
    NSLog(@"Im tapped");
    if ([self.delegate respondsToSelector:@selector(actionTapInCaptureButton:)]) {
        [self.delegate actionTapInCaptureButton:tap];
    }
}

- (void)doSomeThingWhenLongTap:(UILongPressGestureRecognizer *)gesture {
    if ([self.delegate respondsToSelector:@selector(actionLongPressInCaptureButton:)]) {
        [self.delegate actionLongPressInCaptureButton:gesture];
    }
    if (gesture.state == UIGestureRecognizerStateBegan) {
        NSLog(@"Im long tapped start");
        [self startProgress];
    } else if (gesture.state == UIGestureRecognizerStateEnded) {
        NSLog(@"Im long tapped end");
        [self endProgress];
    }
}

- (void)doSomeThingWhenPan:(UIPanGestureRecognizer *)pan {
    if ([self.delegate respondsToSelector:@selector(actionPanInCaptureButton:)]) {
        [self.delegate actionPanInCaptureButton:pan];
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

- (void)setIsInProgress:(BOOL)isInProgress {
    _isInProgress = isInProgress;
    if ([self.delegate respondsToSelector:@selector(captureButton:recordingStateChanged:)]) {
        [self.delegate captureButton:self recordingStateChanged:isInProgress];
    }
}

- (void)configureWithScaleDuration:(float)scaleDuration
                    recordDuration:(float)recordDuration
                  scaleAnimateKind:(NSInteger)scaleAnimateKind
                 recordAnimateKind:(NSInteger)recordAnimateKind
              scaleAnimateFunction:(AnimationFunctionType)scaleAnimateFunction
             recordAnimateFunction:(AnimationFunctionType)recordAnimateFunction {
    self.scaleDuration = scaleDuration;
    self.maxRecordTime = recordDuration;
    switch (scaleAnimateKind) {
        case 0:
        {
            self.scaleAnimationFunction = [[AnimationFunctionLinear alloc] init];
        }
            break;
        case 1:
        {
            self.scaleAnimationFunction = [[AnimationFunctionEaseIn alloc] init];
        }
            break;
        case 2:
        {
            self.scaleAnimationFunction = [[AnimationFunctionEaseOut alloc] init];
        }
            break;
        case 3:
        {
            self.scaleAnimationFunction = [[AnimationFunctionEaseInOut alloc] init];
        }
            break;
        default:
            break;
    }
    
    switch (recordAnimateKind) {
        case 0:
        {
            self.animationFunction = [[AnimationFunctionLinear alloc] init];
        }
            break;
        case 1:
        {
            self.animationFunction = [[AnimationFunctionEaseIn alloc] init];
        }
            break;
        case 2:
        {
            self.animationFunction = [[AnimationFunctionEaseOut alloc] init];
        }
            break;
        case 3:
        {
            self.animationFunction = [[AnimationFunctionEaseInOut alloc] init];
        }
            break;
        default:
            break;
    }
    
    self.scaleFunctionType = scaleAnimateFunction;
    self.recordFunctionType = recordAnimateFunction;
}

- (NSString *)getConfigureString {
    NSString *recordAnimateKindString = nil;
    NSString *scaleAnimateKindString = nil;
    NSString *recordAnimateFuncString = nil;
    NSString *scaleAnimateFuncString = nil;
    
    NSArray *animationFuncArray =  @[@"Quadratic",
                                     @"Cubic",
                                     @"Quartic",
                                     @"Quintic",
                                     @"Sine",
                                     @"Circular",
                                     @"Exponential",
                                     @"Elastic",
                                     @"Back",
                                     @"Bounce"];
    scaleAnimateFuncString = [animationFuncArray objectAtIndex:self.scaleFunctionType];
    recordAnimateFuncString = [animationFuncArray objectAtIndex:self.recordFunctionType];
    
    if ([self.animationFunction isMemberOfClass:[AnimationFunctionLinear class]]) {
        recordAnimateKindString = @"Linear";
        recordAnimateFuncString = @"";
    }
    if ([self.animationFunction isMemberOfClass:[AnimationFunctionEaseIn class]]) {
        recordAnimateKindString = @"EaseIn";
    }
    if ([self.animationFunction isMemberOfClass:[AnimationFunctionEaseOut class]]) {
        recordAnimateKindString = @"EaseOut";
    }
    if ([self.animationFunction isMemberOfClass:[AnimationFunctionEaseInOut class]]) {
        recordAnimateKindString = @"EaseInOut";
    }
    
    if ([self.scaleAnimationFunction isMemberOfClass:[AnimationFunctionLinear class]]) {
        scaleAnimateKindString = @"Linear";
        scaleAnimateFuncString = @"";
    }
    if ([self.scaleAnimationFunction isMemberOfClass:[AnimationFunctionEaseIn class]]) {
        scaleAnimateKindString = @"EaseIn";
    }
    if ([self.scaleAnimationFunction isMemberOfClass:[AnimationFunctionEaseOut class]]) {
        scaleAnimateKindString = @"EaseOut";
    }
    if ([self.scaleAnimationFunction isMemberOfClass:[AnimationFunctionEaseInOut class]]) {
        scaleAnimateKindString = @"EaseInOut";
    }
    
    return [NSString stringWithFormat:@" 放大动画时间:%f\n 录制动画时间:%f\n 放大动画函数:%@ %@\n 录制动画函数:%@ %@\n",self.scaleDuration,self.maxRecordTime,scaleAnimateKindString,scaleAnimateFuncString,recordAnimateKindString,recordAnimateFuncString];
}

#pragma mark UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldBeRequiredToFailByGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    if ([gestureRecognizer isKindOfClass:[UILongPressGestureRecognizer class]] && [otherGestureRecognizer isKindOfClass:[UITapGestureRecognizer class]]) {
        return YES;
    }
    return NO;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    if (gestureRecognizer.view == self) {
        return YES;
    }
    return NO;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if (gestureRecognizer.view == self) {
        return YES;
    }
    return NO;
}
@end
