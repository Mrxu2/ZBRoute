//
//  ZBNavigator+Transition.m
//  ZBRoute
//
//  Created by xzb on 2017/10/25.
//  Copyright © 2017年 xzb. All rights reserved.
//

#import "ZBNavigator+Transition.h"
#import "ZBPageRouter.h"
#import <objc/runtime.h>
#import <objc/message.h>

@interface ZBNavigatorParams ()

- (UIViewController *)getTargetViewController;

@end

@implementation ZBNavigatorParams

- (UIViewController *)getTargetViewController
{

    if (self.viewController) {
        return self.viewController;
    }
    if (self.params) {
        return [[ZBPageRouter router] matchControllerDict:self.params];
    }
    if (self.urlString) {
        return [[ZBPageRouter router] matchControllerUrl:self.urlString];
    }
    [NSException raise:NSInternalInconsistencyException
                format:@"this should never happen in %@ ", NSStringFromSelector(_cmd)];
    return nil;
}

@end

@implementation ZBNavigator (Transition)

- (BOOL)presentAnimateViewControllerWithParams:(void (^)(ZBNavigatorParams *navigatorParams))navigationParamsBlock
{

    ZBNavigatorParams *params = [ZBNavigatorParams new];
    navigationParamsBlock(params);

    UIViewController *presentedViewController = [self navigationControllers].lastObject.topVisibleViewController;
    UIViewController *targetViewController = [params getTargetViewController];

    if (params.delegate) {
        targetViewController.zbDelegate = params.delegate;
    }
    if (params.pageResultBlock) {
        targetViewController.zbPageResultBlock = params.pageResultBlock;
    }

    ZBViewControllerTransition *transition = [[ZBViewControllerTransition alloc] initWithViewController:presentedViewController transtionType:params.transitionType];
    // retain 住，防止被释放
    objc_setAssociatedObject(self, _cmd, transition, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [transition presentViewController:targetViewController params:params.params completion:params.completion];

    return YES;
}

#pragma mark -

@end
