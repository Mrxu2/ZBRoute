//
//  ZBBaseTransition.h
//  ZBRoute
//
//  Created by xzb on 2017/10/25.
//  Copyright © 2017年 xzb. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, ZBPageResultBlockAnimationTransitionType) {
    ZBPageResultBlockAnimationTransitionPresent,
    ZBPageResultBlockAnimationTransitionDismiss
};

@interface ZBBaseTransition : NSObject <UIViewControllerAnimatedTransitioning>

@property (assign, nonatomic) ZBPageResultBlockAnimationTransitionType transitionType;
@property (strong, nonatomic, readonly) UIView *shadowView;
@property (copy, nonatomic) NSDictionary *params;

@property (weak, nonatomic, readonly) UIViewController *fromViewController;
@property (weak, nonatomic, readonly) UIViewController *toViewController;
@property (weak, nonatomic, readonly) UIView *containerView;

/**
 prenset 的时候执行
 子类必须重写这个方法
 */
- (void)presentAnimateTransition:(id<UIViewControllerContextTransitioning>)transitionContext;

/**
 dismiss 的时候执行
 子类必须重写这个方法
 
 */
- (void)dismissAnimateTransition:(id<UIViewControllerContextTransitioning>)transitionContext;

@end
