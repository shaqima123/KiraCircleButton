//
//  UIView+Animation.m
//  KiraCircleButton
//
//  Created by 沙琪玛 on 2019/4/16.
//  Copyright © 2019 Kira. All rights reserved.
//


#import "UIView+Animation.h"
#import "AnimationFunction.h"
#import "RSWeakProxy.h"
#import <objc/runtime.h>

typedef void(^rs_CompletedBlock)(void);
static const NSString *kRSAnimationKeyStartValue = @"kRSAnimationKeyStartValue";
static const NSString *kRSAnimationKeyEndValue = @"kRSAnimationKeyEndValue";
static const NSString *kRSAnimationKeyDuration = @"kRSAnimationKeyDuration";
static const NSString *kRSAnimationKeyAnimationFunction = @"kRSAnimationKeyAnimationFunction";
static const NSString *kRSAnimationKeySelector = @"kRSAnimationKeySelector";

@interface UIView()

@property (nonatomic, strong) CADisplayLink *rs_displayLink;
@property (nonatomic, assign) NSTimeInterval rs_beginTime;
@property (nonatomic, assign) NSTimeInterval rs_delayTime;
@property (nonatomic, assign) NSTimeInterval rs_currentTime;
@property (nonatomic, assign) NSTimeInterval rs_maxDuration;

@property (nonatomic, assign) BOOL rs_isInProgress;
@property (nonatomic, strong) NSArray *rs_animatablePropertiesArray;
@property (nonatomic, strong) NSMutableArray *rs_animationArray;

@property (nonatomic, copy) rs_CompletedBlock rs_completion;

@end

@implementation UIView (Animation)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class aClass = [self class];
        
        SEL originalSelector = NSSelectorFromString(@"dealloc");
        SEL swizzledSelector = @selector(swizzledDealloc);
        
        Method originalMethod = class_getInstanceMethod(aClass, originalSelector);
        Method swizzledMethod = class_getInstanceMethod(aClass, swizzledSelector);
        method_exchangeImplementations(originalMethod, swizzledMethod);
    });
}

- (void)swizzledDealloc {
    [self rs_willDealloc];
    [self swizzledDealloc];
}

- (void)rs_startAnimation {
    [self rs_startAnimationDelay:0 completed:nil];
}

- (void)rs_startAnimationDelay:(NSTimeInterval)delay {
    [self rs_startAnimationDelay:delay completed:nil];
}

- (void)rs_startAnimationCompleted:(void(^)(void))completion {
    [self rs_startAnimationDelay:0 completed:completion];
}

- (void)rs_startAnimationDelay:(NSTimeInterval)delay completed:(void(^)(void))completion {
    if (self.rs_isInProgress) {
        return;
    }
    self.rs_delayTime = delay;
    if (completion) {
        self.rs_completion = completion;
    }
    
    self.rs_beginTime = CACurrentMediaTime();
    self.rs_isInProgress = YES;
    [self setRs_displayLink:[CADisplayLink displayLinkWithTarget:[RSWeakProxy proxyWithTarget:self]
                                                        selector:@selector(rs_doAnimation)]];
    self.rs_displayLink.paused = NO;
    [self.rs_displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    
    //找出最大的duration
    for (int i = 0; i < self.rs_animationArray.count; i++) {
        NSDictionary *dictionary = [self.rs_animationArray objectAtIndex:i];
        
        NSNumber *durationNumber = [dictionary objectForKey:kRSAnimationKeyDuration];
        NSTimeInterval duration = durationNumber.doubleValue;
        self.rs_maxDuration = MAX(self.rs_maxDuration, duration);
    }
}

#pragma mark ----- 不需要传递初始值，初始值为当前 view 的状态

- (id)getStartValueWithProperty:(NSString *)propertyString {
    if (![self.rs_animatablePropertiesArray containsObject:[propertyString lowercaseString]]) {
        NSAssert(NO, @"不支持 %@ 属性的动画!",propertyString);
    }
    if ([[propertyString lowercaseString] isEqualToString:@"alpha"]) {
        NSNumber *alpha = @(self.alpha);
        return alpha;
    }
    if ([[propertyString lowercaseString] isEqualToString:@"frame"]) {
        NSValue *frame = [NSValue valueWithCGRect:self.frame];
        return frame;
    }
    if ([[propertyString lowercaseString] isEqualToString:@"bounds"]) {
        NSValue *bounds = [NSValue valueWithCGRect:self.bounds];
        return bounds;
    }
    if ([[propertyString lowercaseString] isEqualToString:@"center"]) {
        NSValue *center = [NSValue valueWithCGPoint:self.center];
        return center;
    }
    if ([[propertyString lowercaseString] isEqualToString:@"transform"]) {
        NSValue *transform = [NSValue valueWithCGAffineTransform:self.transform];
        return transform;
    }
    
    if ([[propertyString lowercaseString] isEqualToString:@"frame.origin"]) {
        NSValue *origin = [NSValue valueWithCGPoint:self.frame.origin];
        return origin;
    }
    
    if ([[propertyString lowercaseString] isEqualToString:@"frame.size"]) {
        NSValue *size = [NSValue valueWithCGSize:self.frame.size];
        return size;
    }
    
    if ([[propertyString lowercaseString] isEqualToString:@"frame.origin.x"]) {
        NSNumber *x = @(self.frame.origin.x);
        return x;
    }
    if ([[propertyString lowercaseString] isEqualToString:@"frame.origin.y"]) {
        NSNumber *y = @(self.frame.origin.y);
        return y;
    }
    if ([[propertyString lowercaseString] isEqualToString:@"frame.size.width"]) {
        NSNumber *w = @(self.frame.size.width);
        return w;
    }
    if ([[propertyString lowercaseString] isEqualToString:@"frame.size.height"]) {
        NSNumber *h = @(self.frame.size.height);
        return h;
    }
    
    if ([[propertyString lowercaseString] isEqualToString:@"bounds.origin"]) {
        NSValue *origin = [NSValue valueWithCGPoint:self.bounds.origin];
        return origin;
    }
    if ([[propertyString lowercaseString] isEqualToString:@"bounds.size"]) {
        NSValue *size = [NSValue valueWithCGSize:self.bounds.size];
        return size;
    }
    if ([[propertyString lowercaseString] isEqualToString:@"bounds.origin.x"]) {
        NSNumber *x = @(self.bounds.origin.x);
        return x;
    }
    if ([[propertyString lowercaseString] isEqualToString:@"bounds.origin.y"]) {
        NSNumber *y = @(self.bounds.origin.y);
        return y;
    }
    if ([[propertyString lowercaseString] isEqualToString:@"bounds.size.width"]) {
        NSNumber *w = @(self.bounds.size.width);
        return w;
    }
    if ([[propertyString lowercaseString] isEqualToString:@"bounds.size.height"]) {
        NSNumber *h = @(self.bounds.size.height);
        return h;
    }
    
    if ([[propertyString lowercaseString] isEqualToString:@"center.x"]) {
        NSNumber *x = @(self.center.x);
        return x;
    }
    if ([[propertyString lowercaseString] isEqualToString:@"center.y"]) {
        NSNumber *y = @(self.center.y);
        return y;
    }
    
    return nil;
}

- (void)rs_addAnimationToProperty:(NSString *)propertyString
                         endValue:(id)endValue
                         duration:(NSTimeInterval)duration
                    animationType:(AnimationType) animationType {
    [self rs_addAnimationToProperty:propertyString
                     withStartValue:[self getStartValueWithProperty:propertyString]
                           endValue:endValue
                           duration:duration
                      animationType:animationType];
}

- (void)rs_addAnimationToProperty:(NSString *)propertyString
                         endValue:(id)endValue
                         duration:(NSTimeInterval)duration
                    animationType:(AnimationType) animationType
            animationFunctionType:(AnimationFunctionType) functionType {
    [self rs_addAnimationToProperty:propertyString
                     withStartValue:[self getStartValueWithProperty:propertyString]
                           endValue:endValue
                           duration:duration
                      animationType:animationType
              animationFunctionType:functionType];
}

- (void)rs_addAnimationToProperty:(NSString *)propertyString
                         endValue:(id)endValue
                         duration:(NSTimeInterval)duration
                animationFunction:(id<AnimationFunction>)animationFunction {
    [self rs_addAnimationToProperty:propertyString
                     withStartValue:[self getStartValueWithProperty:propertyString]
                           endValue:endValue
                           duration:duration
                  animationFunction:animationFunction];
}

#pragma mark -----

- (void)rs_addAnimationToProperty:(NSString *)propertyString
                   withStartValue:(id)startValue
                         endValue:(id)endValue
                         duration:(NSTimeInterval)duration
                    animationType:(AnimationType) animationType {
    [self rs_addAnimationToProperty:propertyString
                     withStartValue:startValue
                           endValue:endValue
                           duration:duration
                      animationType:animationType
              animationFunctionType:AnimationFunctionTypeDefault];
}

- (void)rs_addAnimationToProperty:(NSString *)propertyString
                   withStartValue:(id)startValue
                         endValue:(id)endValue
                         duration:(NSTimeInterval)duration
                    animationType:(AnimationType) animationType
            animationFunctionType:(AnimationFunctionType) functionType {
    id<AnimationFunction> animation = nil;
    switch (animationType) {
        case AnimationTypeLinear:
        {
            animation = [[AnimationFunctionLinear alloc] init];
        }
            break;
        case AnimationTypeEaseIn:
        {
            animation = [[AnimationFunctionEaseIn alloc] init];
            ((AnimationFunctionEaseIn *)animation).funcType = functionType;
        }
            break;
            
        case AnimationTypeEaseOut:
        {
            animation = [[AnimationFunctionEaseOut alloc] init];
            ((AnimationFunctionEaseOut *)animation).funcType = functionType;
        }
            break;
        case AnimationTypeEaseInOut:
        {
            animation = [[AnimationFunctionEaseInOut alloc] init];
            ((AnimationFunctionEaseInOut *)animation).funcType = functionType;
        }
            break;
        default:
            break;
    }
    [self rs_addAnimationToProperty:propertyString withStartValue:startValue endValue:endValue duration:duration animationFunction:animation];
}

- (void)rs_addAnimationToProperty:(NSString *)propertyString withStartValue:(id)startValue endValue:(id)endValue duration:(NSTimeInterval)duration animationFunction:(id<AnimationFunction>)animationFunction {
    
    if (![self.rs_animatablePropertiesArray containsObject:[propertyString lowercaseString]]) {
        NSAssert(NO, @"不支持 %@ 属性的动画!",propertyString);
    }
    if (!startValue || !endValue || !duration || !animationFunction) {
        NSAssert(NO, @"参数不能为nil！");
        return;
    }
    
    id startValueToExchange = startValue;
    id endValueToExchange = endValue;
    //TODO: check and replace frame.origin.x to frame
    if ([[propertyString lowercaseString] hasPrefix:@"frame"]) {
        CGRect startRect = self.frame;
        CGRect endRect = self.frame;
        if ([[propertyString lowercaseString] isEqualToString:@"frame.origin"]) {
            startRect.origin = ((NSValue *)startValue).CGPointValue;
            endRect.origin = ((NSValue *)endValue).CGPointValue;
        }
        if ([[propertyString lowercaseString] isEqualToString:@"frame.size"]) {
            startRect.size = ((NSValue *)startValue).CGSizeValue;
            endRect.size = ((NSValue *)endValue).CGSizeValue;
        }
        if ([[propertyString lowercaseString] isEqualToString:@"frame.origin.x"]) {
            startRect.origin.x = ((NSNumber *)startValue).floatValue;
            endRect.origin.x = ((NSNumber *)endValue).floatValue;
        }
        if ([[propertyString lowercaseString] isEqualToString:@"frame.origin.y"]) {
            startRect.origin.y = ((NSNumber *)startValue).floatValue;
            endRect.origin.y = ((NSNumber *)endValue).floatValue;
        }
        if ([[propertyString lowercaseString] isEqualToString:@"frame.size.width"]) {
            startRect.size.width = ((NSNumber *)startValue).floatValue;
            endRect.size.width = ((NSNumber *)endValue).floatValue;
        }
        if ([[propertyString lowercaseString] isEqualToString:@"frame.size.height"]) {
            startRect.size.height = ((NSNumber *)startValue).floatValue;
            endRect.size.height = ((NSNumber *)endValue).floatValue;
        }
        
        startValueToExchange = [NSValue valueWithCGRect:startRect];
        endValueToExchange = [NSValue valueWithCGRect:endRect];
    }
    
    if ([[propertyString lowercaseString] hasPrefix:@"bounds"]) {
        CGRect startBounds = self.bounds;
        CGRect endBounds = self.bounds;
        if ([[propertyString lowercaseString] isEqualToString:@"bounds.origin"]) {
            startBounds.origin = ((NSValue *)startValue).CGPointValue;
            endBounds.origin = ((NSValue *)endValue).CGPointValue;
        }
        if ([[propertyString lowercaseString] isEqualToString:@"bounds.size"]) {
            startBounds.size = ((NSValue *)startValue).CGSizeValue;
            endBounds.size = ((NSValue *)endValue).CGSizeValue;
        }
        if ([[propertyString lowercaseString] isEqualToString:@"bounds.origin.x"]) {
            startBounds.origin.x = ((NSNumber *)startValue).floatValue;
            endBounds.origin.x = ((NSNumber *)endValue).floatValue;
        }
        if ([[propertyString lowercaseString] isEqualToString:@"bounds.origin.y"]) {
            startBounds.origin.y = ((NSNumber *)startValue).floatValue;
            endBounds.origin.y = ((NSNumber *)endValue).floatValue;
        }
        if ([[propertyString lowercaseString] isEqualToString:@"bounds.size.width"]) {
            startBounds.size.width = ((NSNumber *)startValue).floatValue;
            endBounds.size.width = ((NSNumber *)endValue).floatValue;
        }
        if ([[propertyString lowercaseString] isEqualToString:@"bounds.size.height"]) {
            startBounds.size.height = ((NSNumber *)startValue).floatValue;
            endBounds.size.height = ((NSNumber *)endValue).floatValue;
        }
        
        startValueToExchange = [NSValue valueWithCGRect:startBounds];
        endValueToExchange = [NSValue valueWithCGRect:endBounds];
    }
    
    if ([[propertyString lowercaseString] hasPrefix:@"center"]) {
        CGPoint startCenter = self.center;
        CGPoint endCenter = self.center;
        if ([[propertyString lowercaseString] isEqualToString:@"center.x"]) {
            startCenter.x = ((NSNumber *)startValue).floatValue;
            endCenter.x = ((NSNumber *)endValue).floatValue;
        }
        if ([[propertyString lowercaseString] isEqualToString:@"center.y"]) {
            startCenter.y = ((NSNumber *)startValue).floatValue;
            endCenter.y = ((NSNumber *)endValue).floatValue;
        }
        
        startValueToExchange = [NSValue valueWithCGPoint:startCenter];
        endValueToExchange = [NSValue valueWithCGPoint:endCenter];
    }
    
    
    if (!self.rs_animationArray) {
        self.rs_animationArray = @[].mutableCopy;
    }
    NSDictionary *dictionary = @{kRSAnimationKeyStartValue : startValueToExchange,
                                 kRSAnimationKeyEndValue : endValueToExchange,
                                 kRSAnimationKeyDuration : @(duration),
                                 kRSAnimationKeyAnimationFunction : animationFunction,
                                 kRSAnimationKeySelector : propertyString
                                 };
    [self.rs_animationArray addObject:dictionary];
}

#pragma mark private

- (void)rs_willDealloc {
    if (self.rs_isInProgress) {
        [self rs_resetAnimationParams];
    }
}

- (void)rs_endProgress {
    if (!self.rs_isInProgress) {
        return;
    }
    if (self.rs_completion) {
        self.rs_completion();
    }
    [self rs_resetAnimationParams];
}

- (void)rs_resetAnimationParams {
    NSLog(@"xxxxxxx displaylink destroyed");
    self.rs_displayLink.paused = YES;
    [self.rs_displayLink invalidate];
    self.rs_beginTime = 0;
    self.rs_delayTime = 0;
    self.rs_currentTime = 0;
    self.rs_maxDuration = 0;
    self.rs_isInProgress = NO;
    [self.rs_animationArray removeAllObjects];
    self.rs_completion = nil;
}

- (void)rs_doAnimation {
    if (!self.rs_isInProgress) {
        return;
    }
    self.rs_currentTime = CACurrentMediaTime() - self.rs_beginTime - self.rs_delayTime;
    if (self.rs_currentTime < 0) {
        return;
    }
    CGFloat recordPercent = self.rs_currentTime / self.rs_maxDuration;
    if (recordPercent > 1) {
        recordPercent = 1;
        [self rs_endProgress];
        return;
    }
    [self rs_updateStates];
}

- (void)rs_updateStates {
    if (self) {
        for (int i = 0; i < self.rs_animationArray.count; i++) {
            NSDictionary *dictionary = [self.rs_animationArray objectAtIndex:i];
            
            NSString *ivarString = [dictionary objectForKey:kRSAnimationKeySelector];
            
            
            id startValue = [dictionary objectForKey:kRSAnimationKeyStartValue];
            
            id endValue = [dictionary objectForKey:kRSAnimationKeyEndValue];
            
            NSNumber *durationNumber = [dictionary objectForKey:kRSAnimationKeyDuration];
            NSTimeInterval duration = durationNumber.doubleValue;
            
            id<AnimationFunction> animationFunction = [dictionary objectForKey:kRSAnimationKeyAnimationFunction];
            
            CGFloat percent = self.rs_currentTime / duration;
            if (percent > 1) {
                percent = 1;
            }
            
            percent = [animationFunction calculate:percent];
            
            [self calculateResultWith:ivarString fromValue:startValue toValue:endValue percent:percent];
        }
    }
}

- (void)calculateResultWith:(NSString *)propertyString fromValue:(id)from toValue:(id)to percent:(float)percent {
    if ([[propertyString lowercaseString] hasPrefix:@"alpha"]) {
        float fromValue = ((NSNumber *)from).floatValue;
        float toValue = ((NSNumber *)to).doubleValue;
        float result = [self interpolateFrom:fromValue to:toValue percent:percent];
        self.alpha = result;
        return;
    }
    if ([[propertyString lowercaseString] hasPrefix:@"frame"] || [[propertyString lowercaseString] hasPrefix:@"bounds"]) {
        CGRect fromValue = ((NSValue *)from).CGRectValue;
        CGRect toValue = ((NSValue *)to).CGRectValue;
        
        float fx = fromValue.origin.x;
        float fy = fromValue.origin.y;
        float fw = fromValue.size.width;
        float fh = fromValue.size.height;
        
        float tx = toValue.origin.x;
        float ty = toValue.origin.y;
        float tw = toValue.size.width;
        float th = toValue.size.height;
        
        float rx = fx;
        float ry = fy;
        float rw = fw;
        float rh = fh;
        
        if (![self equal:fx to:tx]) {
            rx = [self interpolateFrom:fx to:tx percent:percent];
        }
        if (![self equal:fy to:ty]) {
            ry = [self interpolateFrom:fy to:ty percent:percent];
        }
        if (![self equal:fw to:tw]) {
            rw = [self interpolateFrom:fw to:tw percent:percent];
        }
        if (![self equal:fh to:th]) {
            rh = [self interpolateFrom:fh to:th percent:percent];
        }
        if ([[propertyString lowercaseString] hasPrefix:@"frame"]) {
            self.frame = CGRectMake(rx, ry, rw, rh);
        }
        if ([[propertyString lowercaseString] hasPrefix:@"bounds"]) {
            self.bounds = CGRectMake(rx, ry, rw, rh);
        }
        return;
    }
    if ([[propertyString lowercaseString] hasPrefix:@"center"]) {
        CGPoint fromValue = ((NSValue *)from).CGPointValue;
        CGPoint toValue = ((NSValue *)to).CGPointValue;
        
        float fx = fromValue.x;
        float fy = fromValue.y;
        
        float tx = toValue.x;
        float ty = toValue.y;
        
        float rx = fx;
        float ry = fy;
        
        if (![self equal:fx to:tx]) {
            rx = [self interpolateFrom:fx to:tx percent:percent];
        }
        if (![self equal:fy to:ty]) {
            ry = [self interpolateFrom:fy to:ty percent:percent];
        }
        self.center = CGPointMake(rx, ry);
        return;
    }
    if ([[propertyString lowercaseString] hasPrefix:@"transform"]) {
        CGAffineTransform fromValue = ((NSValue *)from).CGAffineTransformValue;
        CGAffineTransform toValue =((NSValue *)to).CGAffineTransformValue;
        
        float fromTranslateX = CGAffineTransformGetTranslateX(fromValue);
        float fromTranslateY = CGAffineTransformGetTranslateY(fromValue);
        float fromRotate = CGAffineTransformGetRotation(fromValue);
        float fromScaleX = CGAffineTransformGetScaleX(fromValue);
        float fromScaleY = CGAffineTransformGetScaleY(fromValue);
        
        float toTranslateX = CGAffineTransformGetTranslateX(toValue);
        float toTranslateY = CGAffineTransformGetTranslateY(toValue);
        float toRotate = CGAffineTransformGetRotation(toValue);
        float toScaleX = CGAffineTransformGetScaleX(toValue);
        float toScaleY = CGAffineTransformGetScaleY(toValue);
        
        float resultTranslateX = fromTranslateX;
        float resultTranslateY = fromTranslateY;
        float resultRotate = fromRotate;
        float resultScaleX = fromScaleX;
        float resultScaleY = fromScaleY;
        
        if (![self equal:fromTranslateX to:toTranslateX]) {
            resultTranslateX = [self interpolateFrom:fromTranslateX to:toTranslateX percent:percent];
        }
        if (![self equal:fromTranslateY to:toTranslateY]) {
            resultTranslateY = [self interpolateFrom:fromTranslateY to:toTranslateY percent:percent];
        }
        if (![self equal:fromRotate to:toRotate]) {
            resultRotate = [self interpolateFrom:fromRotate to:toRotate percent:percent];
        }
        if (![self equal:fromScaleX to:toScaleX]) {
            resultScaleX = [self interpolateFrom:fromScaleX to:toScaleX percent:percent];
        }
        if (![self equal:fromScaleY to:toScaleY]) {
            resultScaleY = [self interpolateFrom:fromScaleY to:toScaleY percent:percent];
        }
        
        CGAffineTransform transform = CGAffineTransformIdentity;
        transform = CGAffineTransformTranslate(transform, resultTranslateX, resultTranslateY);
        transform = CGAffineTransformRotate(transform, resultRotate);
        transform = CGAffineTransformScale(transform, resultScaleX, resultScaleY);
        
        self.transform = transform;
        return;
    }
}

- (BOOL)equal:(float)a to:(float)b {
    if (fabs(a - b) < 0.000001) {
        return YES;
    }
    return NO;
}

- (float)interpolateFrom:(float)from to:(float)to percent:(float)percent {
    return from + (to - from) * percent;
}

- (void)setRs_displayLink:(CADisplayLink *)rs_displayLink {
    objc_setAssociatedObject(self, @selector(setRs_displayLink:), rs_displayLink, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (CADisplayLink *)rs_displayLink {
    CADisplayLink *displayLink = objc_getAssociatedObject(self, @selector(setRs_displayLink:));
    return displayLink;
}

- (void)setRs_beginTime:(NSTimeInterval)rs_beginTime {
    NSNumber *value = @(rs_beginTime);
    objc_setAssociatedObject(self, @selector(setRs_beginTime:), value, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSTimeInterval)rs_beginTime {
    NSNumber *value = objc_getAssociatedObject(self, @selector(setRs_beginTime:));
    return value.doubleValue;
}

- (void)setRs_delayTime:(NSTimeInterval)rs_delayTime {
    NSNumber *value = @(rs_delayTime);
    objc_setAssociatedObject(self, @selector(setRs_delayTime:), value, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSTimeInterval)rs_delayTime {
    NSNumber *value = objc_getAssociatedObject(self, @selector(setRs_delayTime:));
    return value.doubleValue;
}

- (void)setRs_currentTime:(NSTimeInterval)rs_currentTime {
    NSNumber *value = @(rs_currentTime);
    objc_setAssociatedObject(self, @selector(setRs_currentTime:), value, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSTimeInterval)rs_currentTime {
    NSNumber *value = objc_getAssociatedObject(self, @selector(setRs_currentTime:));
    return value.doubleValue;
}

- (void)setRs_maxDuration:(NSTimeInterval)rs_maxDuration {
    NSNumber *value = @(rs_maxDuration);
    objc_setAssociatedObject(self, @selector(setRs_maxDuration:), value, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSTimeInterval)rs_maxDuration {
    NSNumber *value = objc_getAssociatedObject(self, @selector(setRs_maxDuration:));
    return value.doubleValue;
}


- (void)setRs_isInProgress:(BOOL)rs_isInProgress {
    NSNumber *value = @(rs_isInProgress);
    objc_setAssociatedObject(self, @selector(setRs_isInProgress:), value, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)rs_isInProgress {
    NSNumber *value = objc_getAssociatedObject(self, @selector(setRs_isInProgress:));
    return value.boolValue;
}

- (void)setRs_animationArray:(NSMutableArray *)rs_animationArray {
    objc_setAssociatedObject(self, @selector(setRs_animationArray:), rs_animationArray, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSMutableArray *)rs_animationArray {
    return objc_getAssociatedObject(self, @selector(setRs_animationArray:));
}

- (NSArray *)rs_animatablePropertiesArray {
    NSArray *array = objc_getAssociatedObject(self, @selector(rs_animatablePropertiesArray));
    if (array != nil) return array;
    
    array = @[@"frame",@"bounds",@"center",@"transform",@"alpha",
              @"frame.origin",@"frame.size",@"frame.origin.x",@"frame.origin.y",@"frame.size.width",@"frame.size.height",
              @"bounds.origin",@"bounds.size",@"bounds.origin.x",@"bounds.origin.y",@"bounds.size.width",@"bounds.size.height",
              @"center.x",@"center.y"];
    
    objc_setAssociatedObject(self, @selector(rs_animatablePropertiesArray), array, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    return array;
}

- (void)setRs_completion:(rs_CompletedBlock)rs_completion {
    objc_setAssociatedObject(self, @selector(setRs_completion:), rs_completion, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (rs_CompletedBlock)rs_completion {
    return objc_getAssociatedObject(self, @selector(setRs_completion:));
}

#pragma mark

static inline CGFloat CGAffineTransformGetRotation(CGAffineTransform transform) {
    return atan2(transform.b, transform.a);
}

/// Get the transform's scale.x
static inline CGFloat CGAffineTransformGetScaleX(CGAffineTransform transform) {
    return  sqrt(transform.a * transform.a + transform.c * transform.c);
}

/// Get the transform's scale.y
static inline CGFloat CGAffineTransformGetScaleY(CGAffineTransform transform) {
    return sqrt(transform.b * transform.b + transform.d * transform.d);
}

/// Get the transform's translate.x
static inline CGFloat CGAffineTransformGetTranslateX(CGAffineTransform transform) {
    return transform.tx;
}

/// Get the transform's translate.y
static inline CGFloat CGAffineTransformGetTranslateY(CGAffineTransform transform) {
    return transform.ty;
}
@end
