//
//  RSWeakProxy.m
//  RealSocial
//
//  Created by Kira on 2019/4/1.
//  Copyright © 2019 skyplan. All rights reserved.
//

#import "RSWeakProxy.h"

@implementation RSWeakProxy


- (instancetype)initWithTarget:(id)target {
    _target = target;
    return self;
}

+ (instancetype)proxyWithTarget:(id)target {
    return [[RSWeakProxy alloc] initWithTarget:target];
}


- (id)forwardingTargetForSelector:(SEL)selector {
    return _target;
}

- (nullable NSMethodSignature *)methodSignatureForSelector:(SEL)sel
{
    return [self.target methodSignatureForSelector:sel];
}


- (void)forwardInvocation:(NSInvocation *)invocation
{
    [invocation invokeWithTarget:self.target];
}

@end
