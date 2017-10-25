//
//  ZBNavigator.m
//  ZBRoute
//
//  Created by xzb on 2017/10/25.
//  Copyright © 2017年 xzb. All rights reserved.
//

#import "ZBNavigator.h"
#import "ZBPageRouter.h"
#import "UIViewController+PageResult.h"
#import "ZBNavigationViewController.h"

@interface ZBNavigator ()

@property (nonatomic, strong) NSMutableArray *navigationControllerPool;
@property (nonatomic, strong, readonly) ZBNavigationViewController *lastNavigationController;
@property (nonatomic, strong, readonly) UIViewController *topModalViewController;

@end

@interface UINavigationController (modal)

@property (nonatomic, strong, readonly) UIViewController *topModalViewController;

@end

@implementation UINavigationController (modal)

- (UIViewController *)topModalViewController
{
    return self.topVisibleViewController;
}

@end

@implementation ZBNavigator

@synthesize navigationController = _navigationController;

#pragma mark - api

+ (instancetype)navigator
{
    return [self instance];
}

+ (instancetype)instance
{
    static dispatch_once_t oncePredicate;
    static ZBNavigator *instance;
    dispatch_once(&oncePredicate, ^{
      instance = [[self alloc] init];
      instance.navigationControllerPool = [[NSMutableArray alloc] initWithCapacity:2];
    });

    return instance;
}

#pragma mark push方式打开新界面

- (BOOL)canPushViewController:(UIViewController *)viewController
{
    if (!viewController) {
        return NO;
    }
    return YES;
}

- (BOOL)pushViewController:(UIViewController *)viewController animated:(BOOL)animate
{
    return [self pushViewController:viewController delegate:nil animated:animate];
}

//dict
- (BOOL)pushViewControllerByDict:(NSDictionary *)dict animated:(BOOL)animate
{
    return [self pushViewControllerByDict:dict delegate:nil animated:animate];
}

- (BOOL)pushViewControllerByDict:(NSDictionary *)dict delegate:(id<ZBPageResultProtocol>)delegate animated:(BOOL)animate
{
    UIViewController *viewController = [[ZBPageRouter router] matchControllerDict:dict];
    if (!viewController) {
        return [[ZBPageRouter router] executeActionDict:dict];
    }
    return [self pushViewController:viewController delegate:delegate animated:animate];
}

- (BOOL)pushViewControllerByDict:(NSDictionary *)dict pageResultBlock:(ZBPageResultBlock)pageResultBlock animated:(BOOL)animate
{
    UIViewController *viewController = [[ZBPageRouter router] matchControllerDict:dict];
    if (!viewController) {
        return [[ZBPageRouter router] executeActionDict:dict pageResultBlock:pageResultBlock];
    }
    return [self pushViewController:viewController pageResultBlock:pageResultBlock animated:animate];
}

//url
- (BOOL)pushViewControllerByUrl:(NSString *)url animated:(BOOL)animate
{
    return [self pushViewControllerByUrl:url delegate:nil animated:animate];
}

- (BOOL)pushViewControllerByUrl:(NSString *)url delegate:(id<ZBPageResultProtocol>)delegate animated:(BOOL)animate
{
    UIViewController *viewController = [[ZBPageRouter router] matchControllerUrl:url];
    if (!viewController) {
        return [[ZBPageRouter router] executeActionUrl:url];
    }
    return [self pushViewController:viewController delegate:delegate animated:animate];
}

- (BOOL)pushViewControllerByUrl:(NSString *)url pageResultBlock:(ZBPageResultBlock)pageResultBlock animated:(BOOL)animate
{
    UIViewController *viewController = [[ZBPageRouter router] matchControllerUrl:url];
    return [self pushViewController:viewController pageResultBlock:pageResultBlock animated:animate];
}

//主
- (BOOL)pushViewController:(UIViewController *)viewController pageResultBlock:(ZBPageResultBlock)pageResultBlock animated:(BOOL)animate
{
    //1.判断viewController是否存在
    if (![self canPushViewController:viewController]) {
        return NO;
    }

    //2.是否有回调block
    if (pageResultBlock) {
        viewController.zbPageResultBlock = pageResultBlock;
    }

    //3.NavigationController没有SubController就直接返回;
    if (_navigationControllerPool.count <= 0 || !_rootNavigationController) {
        self.rootNavigationController = [[ZBNavigationViewController alloc] initWithRootViewController:viewController];
        return YES;
    }

    //4.跳转
    ZBNavigationViewController *navigationController = [self.navigationControllerPool lastObject];
    [navigationController pushViewController:viewController animated:animate];
    return YES;
}
//Route主
- (BOOL)pushViewController:(UIViewController *)viewController delegate:(id<ZBPageResultProtocol>)delegate animated:(BOOL)animate
{
    //1.判断viewController是否存在
    if (![self canPushViewController:viewController]) {
        return NO;
    }
    /*
     if ([[ZBNavigatorInterceptorManager instance] shouldBlockViewController:viewController showVCType:ZBShowVCTypePush]) {
     return YES;
     }
     */
    if (delegate) {
        viewController.zbDelegate = delegate;
    }

    //4.NavigationController没有SubController就直接返回;
    if (_navigationControllerPool.count <= 0 || !_rootNavigationController) {
        self.rootNavigationController = [[ZBNavigationViewController alloc] initWithRootViewController:viewController];
        return YES;
    }
    //5.跳转
    ZBNavigationViewController *navigationController = [self.navigationControllerPool lastObject];
    [navigationController pushViewController:viewController animated:animate];

    return YES;
}

#pragma mark pop关闭新界面
- (BOOL)popViewControllerAnimated:(BOOL)animate
{
    if (![self canPopViewController]) {
        return NO;
    }

    ZBNavigationViewController *navigationController = [self.navigationControllerPool lastObject];
    if (navigationController.presentedViewController) {
        [navigationController dismissViewControllerAnimated:NO
                                                 completion:^{
                                                   [navigationController popViewControllerAnimated:animate];
                                                 }];
        return YES;
    }

    [navigationController popViewControllerAnimated:animate];
    return YES;
}

- (BOOL)canPopToViewController:(UIViewController *)viewController animated:(BOOL)animate
{
    ZBNavigationViewController *navigationController = self.lastNavigationController;
    if (!navigationController || navigationController.topVisibleViewController != navigationController.topViewController) {
        return NO;
    }
    return YES;
}

- (BOOL)popToViewController:(UIViewController *)viewController animated:(BOOL)animate
{
    if (![self canPopToViewController:viewController animated:animate]) {
        return NO;
    }
    ZBNavigationViewController *navigationController = self.lastNavigationController;

    if (navigationController.presentedViewController) {
        [navigationController dismissViewControllerAnimated:NO
                                                 completion:^{
                                                   [navigationController popToViewController:viewController animated:animate];
                                                 }];
        return YES;
    }

    [navigationController popToViewController:viewController animated:animate];
    return YES;
}

- (BOOL)canPopViewControllerAtIndex:(NSUInteger)index animated:(BOOL)animate
{
    ZBNavigationViewController *navigationController = self.lastNavigationController;
    if (!navigationController || navigationController.topVisibleViewController != navigationController.topViewController || navigationController.viewControllers.count < index) {
        return NO;
    }
    return YES;
}

- (BOOL)popViewControllerAtIndex:(NSUInteger)index animated:(BOOL)animate
{
    if (![self canPopViewControllerAtIndex:index animated:animate]) {
        return NO;
    }

    ZBNavigationViewController *navigationController = self.lastNavigationController;

    UIViewController *viewController = navigationController.viewControllers[navigationController.viewControllers.count - index];
    if (navigationController.presentedViewController) {
        [navigationController dismissViewControllerAnimated:NO
                                                 completion:^{
                                                   [navigationController popToViewController:viewController animated:animate];
                                                 }];
        return YES;
    }

    [navigationController popToViewController:viewController animated:animate];
    return YES;
}

#pragma mark 模态界面
// 打开模态界面，Caution:模块外的present请使用presentNavigationViewController

- (BOOL)canPresentViewController:(UIViewController *)viewController
{
    if (!viewController) {
        return NO;
    }
    if (_navigationControllerPool.count <= 0) {
        return NO;
    }
    return YES;
}

- (BOOL)presentViewController:(UIViewController *)viewController animated:(BOOL)animate
{
    return [self presentViewController:viewController delegate:nil animated:animate completion:nil];
}

- (BOOL)presentViewController:(UIViewController *)viewController animated:(BOOL)animate completion:(void (^)(void))completion
{
    return [self presentViewController:viewController delegate:nil animated:animate completion:nil];
}

-(BOOL)presentViewController:(UIViewController *)viewController delegate:(id<ZBPageResultProtocol>)delegate animated:(BOOL)animate
{
    return [self presentViewController:viewController delegate:delegate animated:animate completion:nil];
}
//dict
- (BOOL)presentViewControllerByDict:(NSDictionary *)dict animated:(BOOL)animate
{
    return [self presentViewControllerByDict:dict delegate:nil animated:animate completion:nil];
}

-(BOOL)presentViewControllerByDict:(NSDictionary *)dict animated:(BOOL)animate completion:(void (^)(void))completion
{
    return [self presentViewControllerByDict:dict delegate:nil animated:animate completion:completion];
}

-(BOOL)presentViewControllerByDict:(NSDictionary *)dict delegate:(id<ZBPageResultProtocol>)delegate animated:(BOOL)animate
{
    return [self presentViewControllerByDict:dict delegate:delegate animated:animate completion:nil];
}

-(BOOL)presentViewControllerByDict:(NSDictionary *)dict delegate:(id<ZBPageResultProtocol>)delegate animated:(BOOL)animate completion:(void (^)(void))completion
{
    UIViewController *viewController = [[ZBPageRouter router] matchControllerDict:dict];
    if (!viewController) {
        return [[ZBPageRouter router] executeActionDict:dict];
    }
    return [self presentViewController:viewController delegate:delegate animated:animate completion:completion];
}
//url
- (BOOL)presentViewControllerByUrl:(NSString *)url animated:(BOOL)animate
{
    return [self presentViewControllerByUrl:url delegate:nil animated:animate completion:nil];
}

- (BOOL)presentViewControllerByUrl:(NSString *)url animated:(BOOL)animate completion:(void (^)(void))completion
{
    return [self presentViewControllerByUrl:url delegate:nil animated:animate completion:completion];
}

- (BOOL)presentViewControllerByUrl:(NSString *)url delegate:(id<ZBPageResultProtocol>)delegate animated:(BOOL)animate
{
    return [self presentViewControllerByUrl:url delegate:delegate animated:animate completion:nil];
}

- (BOOL)presentViewControllerByUrl:(NSString *)url delegate:(id<ZBPageResultProtocol>)delegate animated:(BOOL)animate completion:(void (^)(void))completion
{
    UIViewController *viewController = [[ZBPageRouter router] matchControllerUrl:url];
    return [self presentViewController:viewController delegate:delegate animated:animate completion:completion];
}

//main delegate
- (BOOL)presentViewController:(UIViewController *)viewController delegate:(id<ZBPageResultProtocol>)delegate animated:(BOOL)animate completion:(void (^)(void))completion
{
    if (![self canPresentViewController:viewController]) {
        return NO;
    }
    /*
     if ([[ZBNavigatorInterceptorManager instance] shouldBlockViewController:viewController showVCType:ZBShowVCTypePresent]) {
     return YES;
     }
     */
    if (delegate) {
        viewController.zbDelegate = delegate;
    }
    ZBNavigationViewController *navigationController = [self.navigationControllerPool lastObject];
    [navigationController.topVisibleViewController presentViewController:viewController animated:animate completion:completion];
    return YES;
}
//main
- (BOOL)presentViewControllerByDict:(NSDictionary *)dict pageResultBlock:(ZBPageResultBlock)pageResultBlock animated:(BOOL)animate completion:(void (^)(void))completion
{
    UIViewController *viewController = [[ZBPageRouter router] matchControllerDict:dict];
    if (!viewController) {
        return [[ZBPageRouter router] executeActionDict:dict pageResultBlock:pageResultBlock];
    }

    if (![self canPresentViewController:viewController]) {
        return NO;
    }

    if (pageResultBlock) {
        viewController.zbPageResultBlock = pageResultBlock;
    }

    ZBNavigationViewController *navigationController = [self.navigationControllerPool lastObject];
    [navigationController.topVisibleViewController presentViewController:viewController animated:animate completion:completion];
    return YES;
}
#pragma mark 打开(带导航)模态界面，模块外的present请使用这个
- (BOOL)canPresentNavigationViewController:(UIViewController *)viewController
{
    if (!viewController) {
        return NO;
    }
    if (_navigationControllerPool.count <= 0) {
        return NO;
    }
    return YES;
}

// 打开(带导航)模态界面，模块外的present请使用这个

- (BOOL)presentNavigationViewController:(UIViewController *)viewController animated:(BOOL)animate
{
    return [self presentNavigationViewController:viewController delegate:nil animated:animate completion:nil];
}

- (BOOL)presentNavigationViewController:(UIViewController *)viewController animated:(BOOL)animate completion:(void (^)(void))completion
{
    return [self presentNavigationViewController:viewController delegate:nil animated:animate completion:completion];
}

//dict
- (BOOL)presentNavigationViewControllerByDict:(NSDictionary *)dict animated:(BOOL)animate
{
    return [self presentNavigationViewControllerByDict:dict delegate:nil animated:animate completion:nil];
}

- (BOOL)presentNavigationViewControllerByDict:(NSDictionary *)dict animated:(BOOL)animate completion:(void (^)(void))completion
{
    return [self presentNavigationViewControllerByDict:dict delegate:nil animated:animate completion:completion];
}

- (BOOL)presentNavigationViewControllerByDict:(NSDictionary *)dict pageResultBlock:(ZBPageResultBlock)pageResultBlock animated:(BOOL)animate completion:(void (^)(void))completion
{
    UIViewController *viewController = [[ZBPageRouter router] matchControllerDict:dict];
    if (!viewController) {
        return [[ZBPageRouter router] executeActionDict:dict pageResultBlock:pageResultBlock];
    }

    return [self presentNavigationViewController:viewController pageResultBlock:pageResultBlock animated:animate completion:completion];
}

-(BOOL)presentNavigationViewControllerByDict:(NSDictionary *)dict delegate:(id<ZBPageResultProtocol>)delegate animated:(BOOL)animate
{
    return [self presentNavigationViewControllerByDict:dict delegate:delegate animated:animate completion:nil];
}

- (BOOL)presentNavigationViewControllerByDict:(NSDictionary *)dict delegate:(id<ZBPageResultProtocol>)delegate animated:(BOOL)animate completion:(void (^)(void))completion
{
    UIViewController *viewController = [[ZBPageRouter router] matchControllerDict:dict];
    if (!viewController) {
        return [[ZBPageRouter router] executeActionDict:dict];
    }
    return [self presentNavigationViewController:viewController delegate:delegate animated:animate completion:completion];
}

//url
- (BOOL)presentNavigationViewControllerByUrl:(NSString *)url animated:(BOOL)animate
{
    return [self presentNavigationViewControllerByUrl:url delegate:nil animated:animate completion:nil];
}

- (BOOL)presentNavigationViewControllerByUrl:(NSString *)url animated:(BOOL)animate completion:(void (^)(void))completion
{
    return [self presentNavigationViewControllerByUrl:url delegate:nil animated:animate completion:completion];
}

- (BOOL)presentNavigationViewControllerByUrl:(NSString *)url delegate:(id<ZBPageResultProtocol>)delegate animated:(BOOL)animate
{
    return [self presentNavigationViewControllerByUrl:url delegate:delegate animated:animate completion:nil];
}

- (BOOL)presentNavigationViewControllerByUrl:(NSString *)url delegate:(id<ZBPageResultProtocol>)delegate animated:(BOOL)animate completion:(void (^)(void))completion
{
    UIViewController *viewController = [[ZBPageRouter router] matchControllerUrl:url];
    return [self presentNavigationViewController:viewController delegate:delegate animated:animate completion:completion];
}

- (BOOL)presentNavigationViewController:(UIViewController *)viewController delegate:(id<ZBPageResultProtocol>)delegate animated:(BOOL)animate
{
    return [self presentNavigationViewController:viewController delegate:delegate animated:animate completion:nil];
}
//main
- (BOOL)presentNavigationViewController:(UIViewController *)viewController delegate:(id<ZBPageResultProtocol>)delegate animated:(BOOL)animate completion:(void (^)(void))completion
{
    ZBNavigationViewController *navigationController = [self.navigationControllerPool lastObject];
    ZBNavigationViewController *modalViewController = [[ZBNavigationViewController alloc] initWithRootViewController:viewController];
    if (delegate) {
        viewController.zbDelegate = delegate;
    }
    [navigationController.topVisibleViewController presentViewController:modalViewController animated:animate completion:completion];
    [self.navigationControllerPool addObject:modalViewController];

    return YES;
}

- (BOOL)presentNavigationViewController:(UIViewController *)viewController pageResultBlock:(ZBPageResultBlock)pageResultBlock animated:(BOOL)animate completion:(void (^)(void))completion
{
    ZBNavigationViewController *navigationController = [self.navigationControllerPool lastObject];
    ZBNavigationViewController *modalViewController = [[ZBNavigationViewController alloc] initWithRootViewController:viewController];
    if (pageResultBlock) {
        viewController.zbPageResultBlock = pageResultBlock;
    }
    [navigationController.topVisibleViewController presentViewController:modalViewController animated:animate completion:completion];
    [self.navigationControllerPool addObject:modalViewController];

    return YES;
}

#pragma mark 关闭模态界面(包含带导航和不带导航的)
- (BOOL)canDismissViewController:(BOOL)animate completion:(void (^)(void))completion
{
    BOOL can = [self canDismissViewController];
    !completion ?: completion();
    return can;
}

- (BOOL)dismissViewController:(BOOL)animate
{
    return [self dismissViewController:animate completion:nil];
}

-(BOOL)dismissViewController:(BOOL)animate completion:(void (^)(void))completion
{
    if (![self canDismissViewController]) {
        return NO;
    }

    ZBNavigationViewController *navigationController = [self.navigationControllerPool lastObject];
    UIViewController *modalViewController = navigationController.topVisibleViewController;

    // 最后的navigationController中没有模态viewController情况(check最后的navigationController是否是modal)
    if (navigationController.topViewController == navigationController.topVisibleViewController) {
        modalViewController = navigationController;
        [_navigationControllerPool removeObject:navigationController];
    }

    [modalViewController dismissViewControllerAnimated:animate completion:completion];
    return YES;
}

- (BOOL)canDismissViewController
{
    if (_navigationControllerPool.count <= 0) {
        return NO;
    }

    ZBNavigationViewController *navigationController = [self.navigationControllerPool lastObject];

    // 最后的navigationController中没有模态viewController情况(check最后的navigationController是否是modal)
    if (navigationController.topViewController == navigationController.topVisibleViewController) {
        if (_navigationControllerPool.count <= 1) {
            return NO;
        }

        ZBNavigationViewController *parentNavigationController = _navigationControllerPool[_navigationControllerPool.count - 2];
        if (parentNavigationController.topViewController == parentNavigationController.topVisibleViewController) {
            return NO;
        }
    }

    return YES;
}

#pragma mark - even Response

#pragma mark - private methods

- (BOOL)canPopViewController
{
    if (self.lastNavigationController.viewControllers.count <= 1) {
        return NO;
    }
    return YES;
}

-(BOOL)canPopToRootViewControllerAnimated
{
    if (self.lastNavigationController.viewControllers.count > 1) {
        return YES;
    }
    return NO;
}

- (BOOL)popToRootViewControllerAnimated:(BOOL)animate
{
    if (![self canPopToRootViewControllerAnimated]) {
        return NO;
    }
    [self.lastNavigationController popToRootViewControllerAnimated:animate];
    return YES;
}

- (NSArray<__kindof ZBNavigationViewController *> *)navigationControllers
{
    return [NSArray arrayWithArray:_navigationControllerPool];
    ;
}

- (ZBNavigationViewController *)lastNavigationController
{
    if (_navigationControllerPool.count <= 0) {
        return nil;
    }

    return [_navigationControllerPool lastObject];
}

- (void)setRootNavigationController:(ZBNavigationViewController *)rootNavigationController
{
    _rootNavigationController = rootNavigationController;
    if (_navigationControllerPool.count <= 0) {
        [_navigationControllerPool addObject:_rootNavigationController];
    } else {
        // danger to be here
        [_navigationControllerPool removeAllObjects];
        [_navigationControllerPool addObject:_rootNavigationController];
    }
}

- (id)init
{
    self = [super init];
    if (self) {
        self.lockOpenController = NO;
    }
    return self;
}

// 为了兼容 Swift 调用
+ (ZBNavigator *)getInstance
{
    return [self navigator];
}

// 打开新界面，默认为有动画效果的push方式
- (BOOL)openPushViewController:(UIViewController *)viewController animated:(BOOL)animate
{
    // 锁住打开其他界面，仅仅显示服务器的检查页面
    if (self.lockOpenController) {
        return NO;
    }

    if (viewController != nil) {
        // 打点跟踪

        if (self.navigationController.transitionCoordinator) {
            return NO;
        }
        //            [BBAdsAlertView closeAlertByAdType:Ctc_Bottom_Popup_Ads];
        [self pushViewController:viewController animated:animate];

        return YES;
    } else {
        //        BBLog(@"BBNavigator,bad param");
        return NO;
    }
}

// 关闭新界面，默认为有动画效果的pop方式
- (void)closePopViewControllerAnimated:(BOOL)animate
{
    if (self.navigationController != nil) {
        [[ZBNavigator navigator] popViewControllerAnimated:animate];
    }
}

// 关闭新界面到指定界面，默认为有动画效果的pop方式，index从0开始计数
- (void)closePopViewControllerAtIndex:(NSUInteger)index animated:(BOOL)animate
{
    if (self.navigationController != nil) {
        NSArray *array = [self.navigationController viewControllers];
        if (array.count <= index) {
            [[ZBNavigator navigator] popToRootViewControllerAnimated:animate];
        } else {
            UIViewController *viewController = array[array.count - (index + 1)];
            [[ZBNavigator navigator] popToViewController:viewController animated:animate];
        }
    }
}

// 关闭所有新界面，默认为有动画效果的pop方式
- (void)closePopViewControllerToRootWithAnimated:(BOOL)animate
{
    if (self.navigationController != nil) {
        [[ZBNavigator navigator] popToRootViewControllerAnimated:animate];
    }
}

// 打开模态界面，默认为有动画效果
- (BOOL)openModalViewController:(UIViewController *)viewController animated:(BOOL)animate
{
    if (viewController != nil && self.navigationController.visibleViewController != nil) {
        //         [BBAdsAlertView closeAlertByAdType:Ctc_Bottom_Popup_Ads];
        [[ZBNavigator navigator] presentViewController:viewController animated:animate];

        return YES;
    } else {
        return NO;
    }
}

- (BOOL)displayModalViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    if (viewController != nil && self.navigationController.visibleViewController != nil) {
        //        [BBAdsAlertView closeAlertByAdType:Ctc_Bottom_Popup_Ads];
        [[ZBNavigator navigator] presentViewController:viewController animated:animated];
        return YES;
    } else {
        return NO;
    }
}

// 关闭模态界面
- (BOOL)closeModalViewController:(BOOL)animate completion:(void (^)(void))completion
{
    if (self.navigationController.visibleViewController != nil) {
        [[ZBNavigator navigator] dismissViewController:animate completion:completion];
        return YES;
    } else {
        return NO;
    }
}

- (void)popToRootViewController:(BOOL)animate
{
    [[ZBNavigator navigator] popToRootViewControllerWithAnimated:animate];
}

// 回到根VC
- (BOOL)popToRootViewControllerWithAnimated:(BOOL)animated
{
    [[ZBNavigator navigator] popToRootViewControllerAnimated:animated];
    return YES;
}

- (ZBNavigationViewController *)navigationController
{
    return self.navigationControllers.lastObject;
}



#pragma mark - getter And setter

@end

@protocol ZBURLHandlerProtocol <NSObject>

- (BOOL)openURLString:(NSString *)url;

@end



@implementation UINavigationController(ZBNavigator)
- (UIViewController*)topVisibleViewController{
    UIViewController *visibleViewController = self.visibleViewController;
    while (visibleViewController.presentedViewController) {
        visibleViewController = visibleViewController.presentedViewController;
    }
    
    return visibleViewController;
}
@end
