//
//  ZBViewControllerTransition.m
//  XZBDemo
//
//  Created by xzb on 2017/10/25.
//  Copyright © 2017年 xzb. All rights reserved.
//

#import "ZBViewControllerTransition.h"
#import "ZBActionSheetTransition.h"
#import "ZBPopUpTransition.h"

@interface ZBViewControllerTransition ()

@property (weak, nonatomic) UIViewController *viewController;
@property (assign, nonatomic) ZBViewControllerTransitionType transitionType;
@property (copy, nonatomic) NSDictionary *params;
@property (strong, nonatomic) ZBBaseTransition *currentTransition;

@end

@implementation ZBViewControllerTransition

- (instancetype)initWithViewController:(UIViewController *)viewController transtionType:(ZBViewControllerTransitionType)transitionType
{
    self = [super init];
    if (self) {
        self.viewController = viewController;
        self.transitionType = transitionType;
    }
    return self;
}

- (void)presentViewController:(UIViewController *)viewControlelr params:(NSDictionary *)params completion:(void (^)(void))completion
{

    self.params = params;
    viewControlelr.modalPresentationStyle = UIModalPresentationCustom;
    viewControlelr.transitioningDelegate = self;
    [self.viewController presentViewController:viewControlelr animated:YES completion:completion];
}

#pragma mark - UIViewControllerTransitioningDelegate

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source
{

    self.currentTransition = [self transitionForType:ZBPageResultBlockAnimationTransitionPresent];
    return self.currentTransition;
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed
{

    self.currentTransition = [self transitionForType:ZBPageResultBlockAnimationTransitionDismiss];
    return self.currentTransition;
}

#pragma mark -

- (ZBBaseTransition *)transitionForType:(ZBPageResultBlockAnimationTransitionType)type
{

    ZBBaseTransition *transtion = [[self transitionClass] new];
    transtion.params = self.params;
    transtion.transitionType = type;
    return transtion;
}

- (Class)transitionClass
{
    switch (self.transitionType) {
        case ZBPageResultBlockViewControllerTransitionActionSheet:
            return [ZBActionSheetTransition class];
        case ZBPageResultBlockViewControllerTransitionPop:
            return [ZBPopUpTransition class];
    }
}

@end
