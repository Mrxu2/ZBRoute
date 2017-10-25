//
//  ZBBaseTransition.m
//  XZBDemo
//
//  Created by xzb on 2017/10/25.
//  Copyright © 2017年 xzb. All rights reserved.
//

#import "ZBBaseTransition.h"

@interface ZBBaseTransition ()

@property (weak, nonatomic, readwrite) UIViewController *fromViewController;
@property (weak, nonatomic, readwrite) UIViewController *toViewController;
@property (weak, nonatomic, readwrite) UIView *containerView;
@property (strong, nonatomic) UIView *shadowView;

@end

@implementation ZBBaseTransition

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext
{

    self.toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    self.fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    self.containerView = [transitionContext containerView];

    if (self.transitionType == ZBPageResultBlockAnimationTransitionPresent) {

        [self addShadowViewIfNeeded];
        [self presentAnimateTransition:transitionContext];
    } else {
        [self restoreShadowViewIfNeeded];
        [self dismissAnimateTransition:transitionContext];
    }
}

#pragma mark - shadow

- (void)addShadowViewIfNeeded
{

    BOOL shadowDisable = [self.params[@"transtion_shadow_disable"] boolValue];
    if (shadowDisable) {
        return;
    }

    self.shadowView = [[UIView alloc] initWithFrame:self.fromViewController.view.bounds];
    self.shadowView.alpha = 0;
    self.shadowView.tag = 8080;
    self.shadowView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:.4];
    [self.containerView addSubview:self.shadowView];

    BOOL shadowTapDisable = [self.params[@"transtion_shadow_tap_disable"] boolValue];
    if (shadowTapDisable) {
        return;
    }
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(shadowViewTapped:)];
    [self.toViewController.view addGestureRecognizer:tapGesture];

    UITapGestureRecognizer *shadowViewTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(shadowViewTapped:)];
    [self.shadowView addGestureRecognizer:shadowViewTap];
}

- (void)restoreShadowViewIfNeeded
{

    BOOL shadowDisable = [self.params[@"transtion_shadow_disable"] boolValue];
    if (shadowDisable) {
        return;
    }
    self.shadowView = [self.containerView viewWithTag:8080];
}

#pragma mark - tap

- (void)shadowViewTapped:(UITapGestureRecognizer *)sender
{
    [self.toViewController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - override

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext
{
    return 0.65;
}

- (void)presentAnimateTransition:(id<UIViewControllerContextTransitioning>)transitionContext
{

    [NSException raise:NSInternalInconsistencyException
                format:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)];
}

- (void)dismissAnimateTransition:(id<UIViewControllerContextTransitioning>)transitionContext
{

    [NSException raise:NSInternalInconsistencyException
                format:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)];
}

@end
