//
//  ZBActionSheetTransition.m
//  ZBRoute
//
//  Created by xzb on 2017/10/25.
//  Copyright © 2017年 xzb. All rights reserved.
//

#import "ZBActionSheetTransition.h"

@implementation ZBActionSheetTransition
- (CGFloat)hb_safeFloatValueWithParam:(NSDictionary *)param forKey:(id)key defaultValue:(CGFloat)defaultValue;
{
    id value = param[key];
    if (value == nil) {
        return defaultValue;
    } else if ([value isKindOfClass:[NSNumber class]]) {
        return [value floatValue];
    } else if ([value isKindOfClass:[NSString class]]) {
        return [value floatValue];
    } else {
        return defaultValue;
    }
}

-(void)presentAnimateTransition:(id<UIViewControllerContextTransitioning>)transitionContext
{

    CGRect finalFrame = [transitionContext finalFrameForViewController:self.toViewController];
    CGFloat viewHeight = [self hb_safeFloatValueWithParam:self.params forKey:@"transition_height" defaultValue:0];

    CGRect tmpRect = self.toViewController.view.frame;
    tmpRect.origin.y = CGRectGetHeight(finalFrame);
    self.toViewController.view.frame = tmpRect;

    if (viewHeight) {
        finalFrame.origin.y = CGRectGetHeight(finalFrame) - viewHeight;
        finalFrame.size.height = viewHeight;
    }

    self.toViewController.view.layer.shadowColor = [UIColor darkGrayColor].CGColor;
    self.toViewController.view.layer.shadowOffset = CGSizeMake(0, -2);
    self.toViewController.view.layer.shadowOpacity = .6;
    [self.containerView addSubview:self.toViewController.view];

    NSTimeInterval duration = [self transitionDuration:transitionContext];
    [UIView animateWithDuration:duration
        delay:0.0
        usingSpringWithDamping:.7
        initialSpringVelocity:duration
        options:UIViewAnimationOptionCurveLinear
        animations:^{

          self.toViewController.view.frame = finalFrame;
          self.shadowView.alpha = 1;
        }
        completion:^(BOOL finished) {

          [transitionContext completeTransition:YES];
        }];
}

- (void)dismissAnimateTransition:(id<UIViewControllerContextTransitioning>)transitionContext
{

    [UIView animateWithDuration:.15
        delay:0.0
        options:UIViewAnimationOptionCurveLinear
        animations:^{

          CGRect tmpRect = self.fromViewController.view.frame;
          tmpRect.origin.y = self.toViewController.view.frame.size.height;
          self.fromViewController.view.frame = tmpRect;

          self.shadowView.alpha = 0;
        }
        completion:^(BOOL finished) {

          [self.shadowView removeFromSuperview];
          [transitionContext completeTransition:YES];
        }];
}

@end

