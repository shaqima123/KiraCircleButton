//
//  KiraCircleButtonTestViewController.h
//  RealSocial
//
//  Created by Kira on 2019/2/16.
//  Copyright © 2019 skyplan. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol KiraCircleButtonTestViewControllerDelegate <NSObject>

- (void)finishConfigureWithAnimateDuration1:(float)duration1
                                  duration2:(float)duration2
                             animationKind1:(NSInteger)animationKind1
                             animationKind2:(NSInteger)animationKind2
                                  function1:(NSInteger)function1
                                  function2:(NSInteger)function2;


@end

@interface KiraCircleButtonTestViewController : UIViewController

@property (nonatomic, weak) id<KiraCircleButtonTestViewControllerDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
