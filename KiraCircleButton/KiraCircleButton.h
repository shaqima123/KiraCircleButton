//
//  KiraCircleButton.h
//  KiraCircleButton
//
//  Created by Kira on 2018/7/6.
//  Copyright © 2018 Kira. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol KiraCircleButtonDelegate <NSObject>

@optional

- (void)startProgress;
- (void)endProgress;

@end

@interface KiraCircleButton : UIView

@property (nonatomic, weak) id<KiraCircleButtonDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
