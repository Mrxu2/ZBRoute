//
//  ZBPopUpTransition.m
//  XZBDemo
//
//  Created by xzb on 2017/10/25.
//  Copyright © 2017年 xzb. All rights reserved.
//

#import "ZBPopUpTransition.h"

@implementation ZBPopUpTransition

- (void)presentAnimateTransition:(id<UIViewControllerContextTransitioning>)transitionContext
{

    [self.containerView addSubview:self.toViewController.view];

    CGAffineTransform transform = CGAffineTransformMakeRotation(M_PI / 5.6f);
    CGAffineTransform transform2 = CGAffineTransformMakeScale(0, 0);
    CGAffineTransform transform3 = CGAffineTransformConcat(transform, transform2);
    self.toViewController.view.transform = transform3;

    NSTimeInterval duration = [self transitionDuration:transitionContext];
    [UIView animateWithDuration:duration
        delay:0.0
        usingSpringWithDamping:.65
        initialSpringVelocity:duration
        options:UIViewAnimationOptionCurveLinear
        animations:^{

          self.shadowView.alpha = 1;
          self.toViewController.view.transform = CGAffineTransformIdentity;
        }
        completion:^(BOOL finished) {
          [transitionContext completeTransition:YES];
        }];
}

- (void)dismissAnimateTransition:(id<UIViewControllerContextTransitioning>)transitionContext
{

    [UIView animateWithDuration:.1
        delay:.0
        options:UIViewAnimationOptionAllowAnimatedContent
        animations:^{

          self.fromViewController.view.transform = CGAffineTransformMakeScale(.9, .9);
          self.fromViewController.view.alpha = .8;
        }
        completion:^(BOOL finished) {
          [UIView animateWithDuration:.1
              delay:0.0
              options:UIViewAnimationOptionCurveLinear
              animations:^{
                self.shadowView.alpha = 0;
                self.fromViewController.view.transform = CGAffineTransformMakeScale(1.2, 1.2);
                self.fromViewController.view.alpha = 0;
              }
              completion:^(BOOL finished) {

                self.fromViewController.view.alpha = 1;
                [self.shadowView removeFromSuperview];
                [transitionContext completeTransition:YES];
              }];

        }];
}

@end
