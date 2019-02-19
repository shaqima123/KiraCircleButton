//
//  AnimationFunction.m
//  KiraCircleButton
//
//  Created by Kira on 2019/2/15.
//  Copyright © 2019 Kira. All rights reserved.
//

#import "AnimationFunction.h"

/**
 线性动画
 */
@implementation AnimationFunctionLinear

- (double)calculate:(double) p {
    NSLog(@"animate function is Linear");
    return p;
}

- (double)calculate:(double)p withType:(AnimationFunctionType)type {
    return p;
}
@end


/**
 渐进
 */
@implementation AnimationFunctionEaseIn

- (double)calculate:(double) p {
    return [self calculate:p withType:AnimationFunctionTypeQuadratic];
}

- (double)calculate:(double)p withType:(AnimationFunctionType)type {
    NSLog(@"animate function is EaseIn");
    switch (type) {
        case AnimationFunctionTypeQuadratic:
        {
            return p * p;
        }
            break;
        case AnimationFunctionTypeCubic:
        {
            return p * p * p;
        }
            break;
        case AnimationFunctionTypeQuartic:
        {
            return p * p * p * p;
        }
            break;
        case AnimationFunctionTypeQuintic:
        {
            return p * p * p * p * p;
        }
            break;
        case AnimationFunctionTypeSine:
        {
            return sin((p - 1) * M_PI_2) + 1;
        }
            break;
        case AnimationFunctionTypeCircular:
        {
            return 1 - sqrt(1 - (p * p));
        }
            break;
        case AnimationFunctionTypeExponential:
        {
            return (p == 0.0) ? p : pow(2, 10 * (p - 1));
        }
            break;
        case AnimationFunctionTypeElastic:
        {
            return sin(13 * M_PI_2 * p) * pow(2, 10 * (p - 1));
        }
            break;
        case AnimationFunctionTypeBack:
        {
            return p * p * p - p * sin(p * M_PI);
        }
            break;
        case AnimationFunctionTypeBounce:
        {
            return 1 - [self easeOutBounce:1 - p];
        }
            break;
        default:
            break;
    }
    return p;
}

- (double)easeOutBounce:(double)p {
    if(p < 4/11.0)
    {
        return (121 * p * p)/16.0;
    }
    else if(p < 8/11.0)
    {
        return (363/40.0 * p * p) - (99/10.0 * p) + 17/5.0;
    }
    else if(p < 9/10.0)
    {
        return (4356/361.0 * p * p) - (35442/1805.0 * p) + 16061/1805.0;
    }
    else
    {
        return (54/5.0 * p * p) - (513/25.0 * p) + 268/25.0;
    }
}


@end


/**
 渐出
 */
@implementation AnimationFunctionEaseOut

- (double)calculate:(double) p {
    return [self calculate:p withType:AnimationFunctionTypeQuadratic];
}

- (double)calculate:(double)p withType:(AnimationFunctionType)type {
    NSLog(@"animate function is EaseOut");
    switch (type) {
        case AnimationFunctionTypeQuadratic:
        {
            return -(p * (p - 2));
        }
            break;
        case AnimationFunctionTypeCubic:
        {
            double f = (p - 1);
            return f * f * f + 1;
        }
            break;
        case AnimationFunctionTypeQuartic:
        {
            double f = (p - 1);
            return f * f * f * (1 - p) + 1;
        }
            break;
        case AnimationFunctionTypeQuintic:
        {
            double f = (p - 1);
            return f * f * f * f * f + 1;
        }
            break;
        case AnimationFunctionTypeSine:
        {
            return sin(p * M_PI_2);
        }
            break;
        case AnimationFunctionTypeCircular:
        {
            return sqrt((2 - p) * p);
        }
            break;
        case AnimationFunctionTypeExponential:
        {
            return (p == 1.0) ? p : 1 - pow(2, -10 * p);
        }
            break;
        case AnimationFunctionTypeElastic:
        {
            return sin(-13 * M_PI_2 * (p + 1)) * pow(2, -10 * p) + 1;
        }
            break;
        case AnimationFunctionTypeBack:
        {
            double f = (1 - p);
            return 1 - (f * f * f - f * sin(f * M_PI));
        }
            break;
        case AnimationFunctionTypeBounce:
        {
            if(p < 4/11.0)
            {
                return (121 * p * p)/16.0;
            }
            else if(p < 8/11.0)
            {
                return (363/40.0 * p * p) - (99/10.0 * p) + 17/5.0;
            }
            else if(p < 9/10.0)
            {
                return (4356/361.0 * p * p) - (35442/1805.0 * p) + 16061/1805.0;
            }
            else
            {
                return (54/5.0 * p * p) - (513/25.0 * p) + 268/25.0;
            }
        }
            break;
        default:
            break;
    }
    return p;
}

@end


/**
 渐进渐出
 */
@implementation AnimationFunctionEaseInOut

- (double)calculate:(double) p {
    return [self calculate:p withType:AnimationFunctionTypeQuadratic];
}

- (double)calculate:(double)p withType:(AnimationFunctionType)type {
    NSLog(@"animate function is EaseInEaseOut");
    switch (type) {
        case AnimationFunctionTypeQuadratic:
        {
            if(p < 0.5)
            {
                return 2 * p * p;
            }
            else
            {
                return (-2 * p * p) + (4 * p) - 1;
            }
        }
            break;
        case AnimationFunctionTypeCubic:
        {
            if(p < 0.5)
            {
                return 4 * p * p * p;
            }
            else
            {
                double f = ((2 * p) - 2);
                return 0.5 * f * f * f + 1;
            }
        }
            break;
        case AnimationFunctionTypeQuartic:
        {
            if(p < 0.5)
            {
                return 8 * p * p * p * p;
            }
            else
            {
                double f = (p - 1);
                return -8 * f * f * f * f + 1;
            }
        }
            break;
        case AnimationFunctionTypeQuintic:
        {
            if(p < 0.5)
            {
                return 16 * p * p * p * p * p;
            }
            else
            {
                double f = ((2 * p) - 2);
                return  0.5 * f * f * f * f * f + 1;
            }
        }
            break;
        case AnimationFunctionTypeSine:
        {
            return 0.5 * (1 - cos(p * M_PI));
        }
            break;
        case AnimationFunctionTypeCircular:
        {
            if(p < 0.5)
            {
                return 0.5 * (1 - sqrt(1 - 4 * (p * p)));
            }
            else
            {
                return 0.5 * (sqrt(-((2 * p) - 3) * ((2 * p) - 1)) + 1);
            }
        }
            break;
        case AnimationFunctionTypeExponential:
        {
            if(p == 0.0 || p == 1.0) return p;
            
            if(p < 0.5)
            {
                return 0.5 * pow(2, (20 * p) - 10);
            }
            else
            {
                return -0.5 * pow(2, (-20 * p) + 10) + 1;
            }
        }
            break;
        case AnimationFunctionTypeElastic:
        {
            if(p < 0.5)
            {
                return 0.5 * sin(13 * M_PI_2 * (2 * p)) * pow(2, 10 * ((2 * p) - 1));
            }
            else
            {
                return 0.5 * (sin(-13 * M_PI_2 * ((2 * p - 1) + 1)) * pow(2, -10 * (2 * p - 1)) + 2);
            }
        }
            break;
        case AnimationFunctionTypeBack:
        {
            if(p < 0.5)
            {
                double f = 2 * p;
                return 0.5 * (f * f * f - f * sin(f * M_PI));
            }
            else
            {
                double f = (1 - (2*p - 1));
                return 0.5 * (1 - (f * f * f - f * sin(f * M_PI))) + 0.5;
            }
        }
            break;
        case AnimationFunctionTypeBounce:
        {
            if(p < 0.5)
            {
                return 0.5 * [self easeInBounce:(p*2)];
            }
            else
            {
                return 0.5 * [self easeOutBounce:(p * 2 - 1)] + 0.5;
            }
        }
            break;
        default:
            break;
    }
    return p;
}

- (double)easeOutBounce:(double)p {
    if(p < 4/11.0)
    {
        return (121 * p * p)/16.0;
    }
    else if(p < 8/11.0)
    {
        return (363/40.0 * p * p) - (99/10.0 * p) + 17/5.0;
    }
    else if(p < 9/10.0)
    {
        return (4356/361.0 * p * p) - (35442/1805.0 * p) + 16061/1805.0;
    }
    else
    {
        return (54/5.0 * p * p) - (513/25.0 * p) + 268/25.0;
    }
}

- (double)easeInBounce:(double)p {
    return 1 - [self easeOutBounce:1 - p];
}

@end

static const int precision = 100;
@interface AnimationFunctionBezier()
@property (nonatomic, assign) CGPoint point1;
@property (nonatomic, assign) CGPoint point2;
@property (nonatomic, strong) NSMutableArray *coords;

@end

@implementation AnimationFunctionBezier

- (void)setupWithControlPoint1:(CGPoint)point1 controlPoint2:(CGPoint)point2 {
    self.point1 = point1;
    self.point2 = point2;
    [self getCoordsArray];
}

- (CGPoint)getCoord:(double)t {
    if (t > 1 || t < 0) {
        return CGPointZero;
    }
    double _t = 1 - t;
    double coefficient1 = 3 * t * pow(_t, 2);
    double coefficient2 = 3 * _t * pow(t, 2);
    double coefficient3 = pow(t, 3);
    double px = coefficient1 * self.point1.x + coefficient2 * self.point2.x + coefficient3;
    double py = coefficient1 * self.point1.y + coefficient2 * self.point2.y + coefficient3;
    
    return CGPointMake(px, py);
}

- (void)getCoordsArray {
    double step = 1.f / (precision + 1);
    NSMutableArray *array = @[].mutableCopy;
    for (int t = 0; t <= precision + 1; t++) {
        [array addObject:[NSValue valueWithCGPoint:[self getCoord:(t * step)]]];
    }
    self.coords = array;
}

- (double)calculate:(double)p {
    if (p >= 1) return 1;
    if (p <= 0) return 0;
    double startX = 0;
    for (int i = 0; i < self.coords.count; i++) {
        NSValue *value = [self.coords objectAtIndex:i];
        if (value.CGPointValue.x >= p) {
            startX = i;
            break;
        }
    }
    CGPoint axis1 = ((NSValue *)[self.coords objectAtIndex:startX]).CGPointValue;
    CGPoint axis2 = ((NSValue *)[self.coords objectAtIndex:startX - 1]).CGPointValue;
    double k = (axis2.y - axis1.y)/(axis2.x - axis1.x);
    double b = axis1.y - k * axis1.x;
    return k * p + b;
}

- (double)calculate:(double)p withType:(AnimationFunctionType)type {
    return [self calculate:p];
}

@end
