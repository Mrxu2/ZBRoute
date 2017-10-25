//
//  ZBNavigationViewController.m
//  XZBDemo
//
//  Created by xzb on 2017/10/25.
//  Copyright © 2017年 xzb. All rights reserved.
//

#import "ZBNavigationViewController.h"

@interface ZBNavigationViewController () <UIGestureRecognizerDelegate>
@end

@implementation ZBNavigationViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.interactivePopGestureRecognizer.delegate = self;
}

- (BOOL)shouldAutorotate
{
    return self.topViewController.shouldAutorotate;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return self.topViewController.supportedInterfaceOrientations;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return self.topViewController.preferredInterfaceOrientationForPresentation;
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    if (self.viewControllers.count <= 1) {
        return NO;
    }

    if ([self.topViewController respondsToSelector:@selector(hb_shouldPanback)]) {
        return [(id<ZBNavigationPanbackDelegate>) self.topViewController hb_shouldPanback];
    }

    return YES;
}

@end
