//
//  AnimationFunction.h
//  KiraCircleButton
//
//  Created by Kira on 2019/2/15.
//  Copyright © 2019 Kira. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, AnimationFunctionType) {
    AnimationFunctionTypeDefault,//(AnimationFunctionTypeQuadratic)
    AnimationFunctionTypeCubic,
    AnimationFunctionTypeQuartic,
    AnimationFunctionTypeQuintic,
    AnimationFunctionTypeSine,
    AnimationFunctionTypeCircular,
    AnimationFunctionTypeExponential,
    AnimationFunctionTypeElastic,
    AnimationFunctionTypeBack,
    AnimationFunctionTypeBounce
};

typedef NS_ENUM(NSInteger, AnimationType) {
    AnimationTypeLinear,
    AnimationTypeEaseIn,
    AnimationTypeEaseOut,
    AnimationTypeEaseInOut
};

@protocol AnimationFunction <NSObject>

@required

/**
 缓动函数

 @param p 传入参数，为当前进度除以持续时间的线性百分比
 @return 函数处理之后的进度百分比
 */
- (double)calculate:(double) p;

@end


/**
 线性动画
 */
@interface AnimationFunctionLinear: NSObject <AnimationFunction>

- (double)calculate:(double) p;

@end


/**
 渐进
 */
@interface AnimationFunctionEaseIn: NSObject <AnimationFunction>

@property (nonatomic, assign) AnimationFunctionType funcType;

- (double)calculate:(double) p;

@end


/**
 渐出
 */
@interface AnimationFunctionEaseOut: NSObject <AnimationFunction>

@property (nonatomic, assign) AnimationFunctionType funcType;

- (double)calculate:(double) p;

@end


/**
 渐进渐出
 */
@interface AnimationFunctionEaseInOut: NSObject <AnimationFunction>

@property (nonatomic, assign) AnimationFunctionType funcType;

- (double)calculate:(double) p;

@end

@interface AnimationFunctionBezier: NSObject <AnimationFunction>

- (void)setupWithControlPoint1:(CGPoint)point1 controlPoint2:(CGPoint)point2;
- (double)calculate:(double)p;

@end
NS_ASSUME_NONNULL_END
