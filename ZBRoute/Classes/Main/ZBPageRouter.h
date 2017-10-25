//
//  ZBPageRouter.h
//  ZBRoute
//
//  Created by xzb on 2017/10/25.
//  Copyright © 2017年 xzb. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "UIViewController+PageResult.h"

FOUNDATION_EXPORT NSString *const kZBPageRouteNotificationValidateResult;

typedef BOOL (^ZBPageRouterBlock)(NSDictionary *params);

@interface ZBPageRouter : NSObject

@property (nonatomic, strong) NSMutableDictionary<NSString *, NSMutableArray *> *targetRoutes;

+ (instancetype)router;

+ (void)enableScheme:(BOOL)enable;

- (void)registerUrl:(NSString *)route toControllerClass:(Class)controllerClass;
- (void)registerUrl:(NSString *)route toAction:(ZBPageRouterBlock)block;

- (UIViewController *)matchControllerUrl:(NSString *)route;
- (UIViewController *)matchControllerDict:(NSDictionary *)dict;

- (BOOL)executeActionUrl:(NSString *)route;
- (BOOL)executeActionUrl:(NSString *)route pageResultBlock:(ZBPageResultBlock)pageResultBlock;
- (BOOL)executeActionDict:(NSDictionary *)dict;
- (BOOL)executeActionDict:(NSDictionary *)dict pageResultBlock:(ZBPageResultBlock)pageResultBlock;

@end

@interface ZBPageRouter (Testing)

/**
 所有已经注册的路由信息
 
 格式：
 
 {
 @"route" => @"逗号分隔的类名列表",
 ...
 }
 */
@property (nonatomic, copy, readonly) NSDictionary<NSString *, NSArray *> *registeredRoutes;

@end

@interface UIViewController (ZBPageRouter)

@property (nonatomic, strong, readonly) NSDictionary *params;

// TODO: maybe we need a validate params or mapping params method
- (BOOL)validateParams:(NSDictionary *)params;

@end
