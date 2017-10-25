//
//  ZBNavigator.h
//  ZBRoute
//
//  Created by xzb on 2017/10/25.
//  Copyright © 2017年 xzb. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "ZBPageResultProtocol.h"
#import "UIViewController+PageResult.h"
#import "ZBNavigationViewController.h"

typedef void (^goshareBlock)(BOOL isGoShare);
typedef void (^cancelShareBlock)();
typedef void (^sharedBlock)(NSString *platform);

@interface ZBNavigator : NSObject

@property (nonatomic, strong) ZBNavigationViewController *rootNavigationController;
@property (nonatomic, copy) NSArray<__kindof ZBNavigationViewController *> *navigationControllers;
@property (nonatomic, strong) ZBNavigationViewController *navigationController;
@property (nonatomic, assign) BOOL lockOpenController;

+ (instancetype)navigator;
+ (instancetype)instance;
#pragma mark - push
- (BOOL)canPushViewController:(UIViewController *)viewController;

- (BOOL)pushViewController:(UIViewController *)viewController animated:(BOOL)animate;

- (BOOL)pushViewControllerByDict:(NSDictionary *)dict animated:(BOOL)animate;
- (BOOL)pushViewControllerByDict:(NSDictionary *)dict delegate:(id<ZBPageResultProtocol>)delegate animated:(BOOL)animate;
- (BOOL)pushViewControllerByDict:(NSDictionary *)dict pageResultBlock:(ZBPageResultBlock)pageResultBlock animated:(BOOL)animate;

- (BOOL)pushViewControllerByUrl:(NSString *)url animated:(BOOL)animate;
- (BOOL)pushViewControllerByUrl:(NSString *)url delegate:(id<ZBPageResultProtocol>)delegate animated:(BOOL)animate;
- (BOOL)pushViewControllerByUrl:(NSString *)url pageResultBlock:(ZBPageResultBlock)pageResultBlock animated:(BOOL)animate;

#pragma mark - pop
- (BOOL)popViewControllerAnimated:(BOOL)animate;

- (BOOL)canPopToViewController:(UIViewController *)viewController animated:(BOOL)animate;
- (BOOL)popToViewController:(UIViewController *)viewController animated:(BOOL)animate;

- (BOOL)canPopViewControllerAtIndex:(NSUInteger)index animated:(BOOL)animate;
- (BOOL)popViewControllerAtIndex:(NSUInteger)index animated:(BOOL)animate;

#pragma mark - 模态
- (BOOL)canPresentViewController:(UIViewController *)viewController;

- (BOOL)presentViewController:(UIViewController *)viewController animated:(BOOL)animate;
- (BOOL)presentViewController:(UIViewController *)viewController animated:(BOOL)animate completion:(void (^)(void))completion;

- (BOOL)presentViewControllerByDict:(NSDictionary *)dict animated:(BOOL)animate;
- (BOOL)presentViewControllerByDict:(NSDictionary *)dict animated:(BOOL)animate completion:(void (^)(void))completion;

- (BOOL)presentViewControllerByUrl:(NSString *)url animated:(BOOL)animate;
- (BOOL)presentViewControllerByUrl:(NSString *)url animated:(BOOL)animate completion:(void (^)(void))completion;

#pragma mark - 模态带Navigation
- (BOOL)canPresentNavigationViewController:(UIViewController *)viewController;

- (BOOL)presentNavigationViewController:(UIViewController *)viewController animated:(BOOL)animate;
- (BOOL)presentNavigationViewController:(UIViewController *)viewController animated:(BOOL)animate completion:(void (^)(void))completion;
- (BOOL)presentNavigationViewControllerByDict:(NSDictionary *)dict animated:(BOOL)animate;
- (BOOL)presentNavigationViewControllerByDict:(NSDictionary *)dict animated:(BOOL)animate completion:(void (^)(void))completion;

- (BOOL)presentNavigationViewControllerByUrl:(NSString *)url animated:(BOOL)animate;
- (BOOL)presentNavigationViewControllerByUrl:(NSString *)url animated:(BOOL)animate completion:(void (^)(void))completion;

#pragma mark - dismiss
- (BOOL)canDismissViewController:(BOOL)animate completion:(void (^)(void))completion;
- (BOOL)dismissViewController:(BOOL)animate;
- (BOOL)dismissViewController:(BOOL)animate completion:(void (^)(void))completion;
- (BOOL)canDismissViewController;

@end

@interface UINavigationController (ZBNavigator)

// 处于当前rootViewController最顶端可见的ViewController，包含modal
@property (nonatomic, strong, readonly) UIViewController *topVisibleViewController;

@end
