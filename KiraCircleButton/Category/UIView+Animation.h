//
//  UIView+Animation.h
//  KiraCircleButton
//
//  Created by 沙琪玛 on 2019/4/16.
//  Copyright © 2019 Kira. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AnimationFunction.h"

NS_ASSUME_NONNULL_BEGIN

@interface UIView (Animation)

- (void)rs_startAnimation;
- (void)rs_startAnimationDelay:(NSTimeInterval)delay;
- (void)rs_startAnimationCompleted:(void(^)(void))completion;
- (void)rs_startAnimationDelay:(NSTimeInterval)delay completed:(void(^)(void))completion;

#pragma mark ----- 不需要传递初始值，初始值为当前 view 的状态
- (void)rs_addAnimationToProperty:(NSString *)propertyString
                         endValue:(id)endValue
                         duration:(NSTimeInterval)duration
                    animationType:(AnimationType)animationType;

- (void)rs_addAnimationToProperty:(NSString *)propertyString
                         endValue:(id)endValue
                         duration:(NSTimeInterval)duration
                    animationType:(AnimationType)animationType
            animationFunctionType:(AnimationFunctionType)functionType;

- (void)rs_addAnimationToProperty:(NSString *)propertyString
                         endValue:(id)endValue
                         duration:(NSTimeInterval)duration
                animationFunction:(id<AnimationFunction>)animationFunction;


#pragma mark -----
- (void)rs_addAnimationToProperty:(NSString *)propertyString
                   withStartValue:(id)startValue
                         endValue:(id)endValue
                         duration:(NSTimeInterval)duration
                    animationType:(AnimationType) animationType;

- (void)rs_addAnimationToProperty:(NSString *)propertyString
                   withStartValue:(id)startValue
                         endValue:(id)endValue
                         duration:(NSTimeInterval)duration
                    animationType:(AnimationType) animationType
            animationFunctionType:(AnimationFunctionType) functionType;

- (void)rs_addAnimationToProperty:(NSString *)propertyString
                   withStartValue:(id)startValue
                         endValue:(id)endValue
                         duration:(NSTimeInterval)duration
                animationFunction:(id<AnimationFunction>)animationFunction;

- (void)rs_willDealloc;

@end

NS_ASSUME_NONNULL_END
