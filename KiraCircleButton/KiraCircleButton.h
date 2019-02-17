//
//  KiraCircleButton.h
//  KiraCircleButton
//
//  Created by Kira on 2018/7/6.
//  Copyright © 2018 Kira. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AnimationFunction.h"

NS_ASSUME_NONNULL_BEGIN

@class KiraCircleButton;

@protocol KiraCircleButtonDelegate <NSObject>

@optional

/**
 手势调用函数
 
 @param tap 
 */
- (void)actionTapInCaptureButton:(UITapGestureRecognizer *)tap;
- (void)actionPanInCaptureButton:(UIPanGestureRecognizer *)pan;
- (void)actionLongPressInCaptureButton:(UILongPressGestureRecognizer *)longPress;


/**
 开始动画进度
 */
- (void)startProgress;


/**
 结束动画进度
 */
- (void)endProgress;


/**
 在开始或者结束动画时，isInProgress状态改变时的回调
 
 @param captureButton
 @param isInProgress 是否在动画进度中的状态
 */
- (void)captureButton:(KiraCircleButton *)captureButton recordingStateChanged:(BOOL) isInProgress;

@end

//最大录制时间
static float const kCaptureButtonMaxRecordTime = 15.f;

@interface KiraCircleButton : UIView

@property (nonatomic, assign, readonly) NSTimeInterval currentTime;
@property (nonatomic, assign, readonly) BOOL isInProgress;

@property (nonatomic, weak) id<KiraCircleButtonDelegate> delegate;

- (void)disableGesture:(Class)gestureClass;
- (void)resetCaptureButton;

- (void)configureWithScaleDuration:(float)scaleDuration
                    recordDuration:(float)recordDuration
                  scaleAnimateKind:(NSInteger)scaleAnimateKind
                 recordAnimateKind:(NSInteger)recordAnimateKind
              scaleAnimateFunction:(AnimationFunctionType)scaleAnimateFunction
             recordAnimateFunction:(AnimationFunctionType)recordAnimateFunction;
- (NSString *)getConfigureString;

@end

NS_ASSUME_NONNULL_END
