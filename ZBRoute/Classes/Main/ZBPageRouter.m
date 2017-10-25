//
//  ZBPageRouter.m
//  ZBRoute
//
//  Created by xzb on 2017/10/25.
//  Copyright © 2017年 husor1. All rights reserved.
//

#import "ZBPageRouter.h"
#import <objc/runtime.h>

// 协议头与path间的分隔符
static NSString *const kSchemaProtocolDelimiter = @"~";
NSString *const kZBPageRouteNotificationValidateResult = @"kNotificationPageRouteValidateResult"; //通知发送校验结果 {result:YES/NO,paramsDict:paramsDict}

static NSString *const kZBPageRouteBlockSuffix = @"-kZBPageRouteBlockSuffix";

@interface ZBPageRouter ()

@property (strong, nonatomic) NSMutableDictionary *routes;
@property (assign, nonatomic) BOOL enableScheme;

@end

@implementation ZBPageRouter

#pragma mark - interface

+ (instancetype)router
{
    static ZBPageRouter *router = nil;
    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{
      router = [[self alloc] init];
    });
    return router;
}

+ (void)enableScheme:(BOOL)enable
{
    [ZBPageRouter router].enableScheme = enable;
}

- (void)registerUrl:(NSString *)route toControllerClass:(Class)controllerClass
{
    NSMutableDictionary *subRoutes = [self subRoutesToRoute:route];
    subRoutes[@"_"] = controllerClass;

    NSMutableArray *targetArray = self.targetRoutes[NSStringFromClass(controllerClass)];
    if (targetArray) {
        [targetArray addObject:route];
    } else {
        self.targetRoutes[NSStringFromClass(controllerClass)] = @[ route ].mutableCopy;
    }
}

- (void)registerUrl:(NSString *)route toAction:(ZBPageRouterBlock)block
{
    NSString *blockTarget = [NSString stringWithFormat:@"%@%@", route, kZBPageRouteBlockSuffix];
    NSMutableDictionary *subRoutes = [self subRoutesToRoute:blockTarget];

    subRoutes[@"_"] = [block copy];
}

- (UIViewController *)matchControllerUrl:(NSString *)route
{
    if (!route.length) {
        return nil;
    }
    NSMutableDictionary *params = [self paramsInRoute:route];
    return [self createViewControllerByRouteParams:params];
}

- (UIViewController *)matchControllerDict:(NSDictionary *)dict
{
    NSString *target = dict[@"target"];
#ifdef DEBUG
    NSAssert(target, @"跳转时，需要有target字段");
#else
    //release 环境下增强安全性。
    if (target == nil) {
        return nil;
    }
#endif

    __block NSMutableDictionary *params = [self paramsInRoute:target];
    // NSMutableDictionary *subRoutes = self.routes;

    [dict enumerateKeysAndObjectsUsingBlock:^(id _Nonnull key, id _Nonnull obj, BOOL *_Nonnull stop) {
      if (![key isEqualToString:@"target"]) {
          params[key] = obj;
      }
    }];

    return [self createViewControllerByRouteParams:params];
}

- (BOOL)executeActionUrl:(NSString *)route
{
    return [self executeActionUrl:route pageResultBlock:nil];
}

- (BOOL)executeActionUrl:(NSString *)route pageResultBlock:(ZBPageResultBlock)pageResultBlock
{
#ifdef DEBUG
    NSAssert(route, @"执行block时，需要有route字段");
#else
    if (route == nil) {
        return NO;
    }
#endif
    NSString *targetRoute = route;
    NSString *paramsString = @"";
    if ([route rangeOfString:@"?"].location != NSNotFound) {
        NSArray *separatedArray = [route componentsSeparatedByString:@"?"];
        targetRoute = separatedArray[0];
        if (separatedArray.count > 1) {
            paramsString = separatedArray[1];
        }
    }
    NSString *blockTarget = [NSString stringWithFormat:@"%@%@", targetRoute, kZBPageRouteBlockSuffix];
    NSMutableDictionary *params = [self paramsInRoute:[NSString stringWithFormat:@"%@?%@", blockTarget, paramsString]];
    ZBPageRouterBlock routerBlock = [params[@"block"] copy];
    if (!routerBlock) {
        return NO;
    }
    params[@"pageResultBlock"] = pageResultBlock;
    return routerBlock([params copy]);
}

- (BOOL)executeActionDict:(NSDictionary *)dict
{
    NSString *target = dict[@"target"];
#ifdef DEBUG
    NSAssert(target, @"执行block时，需要有target字段");
#else
    if (target == nil) {
        return NO;
    }
#endif
    NSString *blockTarget = [NSString stringWithFormat:@"%@%@", target, kZBPageRouteBlockSuffix];
    __block NSMutableDictionary *params = [self paramsInRoute:blockTarget];
    ZBPageRouterBlock routerBlock = [params[@"block"] copy];

    if (!routerBlock) {
        return NO;
    }

    [dict enumerateKeysAndObjectsUsingBlock:^(id _Nonnull key, id _Nonnull obj, BOOL *_Nonnull stop) {
      params[key] = obj;
    }];

    return routerBlock([params copy]);
}

- (BOOL)executeActionDict:(NSDictionary *)dict pageResultBlock:(ZBPageResultBlock)pageResultBlock
{
    NSString *target = dict[@"target"];
#ifdef DEBUG
    NSAssert(target, @"执行block时，需要有target字段");
#else
    if (target == nil) {
        return NO;
    }
#endif
    NSString *blockTarget = [NSString stringWithFormat:@"%@%@", target, kZBPageRouteBlockSuffix];
    __block NSMutableDictionary *params = [self paramsInRoute:blockTarget];
    ZBPageRouterBlock routerBlock = [params[@"block"] copy];

    if (!routerBlock) {
        return NO;
    }

    [dict enumerateKeysAndObjectsUsingBlock:^(id _Nonnull key, id _Nonnull obj, BOOL *_Nonnull stop) {
      params[key] = obj;
    }];
    params[@"pageResultBlock"] = pageResultBlock;

    return routerBlock([params copy]);
}

#pragma mark - route main
// extract params in a route
- (NSMutableDictionary *)paramsInRoute:(NSString *)route
{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];

    if (!self.enableScheme) {
        route = [self stringFromFilterAppUrlScheme:route];
    }
    params[@"route"] = route;

    NSMutableDictionary *subRoutes = self.routes;
    NSArray *pathComponents = [self pathComponentsFromRoute:route];
    for (NSString *pathComponent in pathComponents) {
        BOOL found = NO;
        NSArray *subRoutesKeys = subRoutes.allKeys;
        for (NSString *key in subRoutesKeys) {
            if ([subRoutesKeys containsObject:pathComponent]) {
                found = YES;
                subRoutes = subRoutes[pathComponent];
                break;
            } else if ([key hasPrefix:@":"]) {
                found = YES;
                subRoutes = subRoutes[key];
                params[[key substringFromIndex:1]] = pathComponent;
                break;
            }
        }
        if (!found) {
            return nil;
        }
    }

    // Extract Params From Query.
    NSRange firstRange = [route rangeOfString:@"?"];
    if (firstRange.location != NSNotFound && route.length > firstRange.location + firstRange.length) {
        NSString *paramsString = [route substringFromIndex:firstRange.location + firstRange.length];
        NSArray *paramStringArr = [paramsString componentsSeparatedByString:@"&"];
        for (NSString *paramString in paramStringArr) {
            NSArray *paramArr = [paramString componentsSeparatedByString:@"="];
            if (paramArr.count > 1) {
                NSString *key = [paramArr objectAtIndex:0];
                NSString *value = [paramArr objectAtIndex:1];
                //value decode
                value = [[value stringByReplacingOccurrencesOfString:@"+" withString:@" "] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                params[key] = value;
            }
        }
    }

    Class class = subRoutes[@"_"];
    if (class_isMetaClass(object_getClass(class))) {
        if ([class isSubclassOfClass:[UIViewController class]]) {
            params[@"controller_class"] = subRoutes[@"_"];
        } else {
            return nil;
        }
    } else {
        if (subRoutes[@"_"]) {
            params[@"block"] = [subRoutes[@"_"] copy];
        }
    }
    return params;
}

- (NSArray *)pathComponentsFromRoute:(NSString *)route
{
    NSMutableArray *pathComponents = [NSMutableArray array];
    if ([route rangeOfString:@"://"].location != NSNotFound) {
        NSArray *pathSegments = [route componentsSeparatedByString:@"://"];
        // 添加scheme
        NSString *scheme = pathSegments[0];
        [pathComponents addObject:scheme];

        // 如果只有path，那么放一个占位符
        if ((pathSegments.count == 2 && ((NSString *) pathSegments[1]).length) || pathSegments.count < 2) {
            [pathComponents addObject:kSchemaProtocolDelimiter];
        }
        route = [route substringFromIndex:scheme.length + 2];
    }

    for (NSString *pathComponent in route.pathComponents) {
        if ([pathComponent isEqualToString:@"/"]) continue;
        //if ([[pathComponent substringToIndex:1] isEqualToString:@"?"]) break;

        NSRange range = [pathComponent rangeOfString:@"?"];
        if (range.location != NSNotFound) {
            if (range.location > 0) {
                [pathComponents addObject:[pathComponent substringToIndex:range.location]];
            }
            break;
        }
        [pathComponents addObject:pathComponent];
    }
    return [pathComponents copy];
}

- (NSMutableDictionary *)subRoutesToRoute:(NSString *)route
{
    if (!self.enableScheme) {
        route = [self stringFromFilterAppUrlScheme:route];
    }
    NSArray *pathComponents = [self pathComponentsFromRoute:route];
    NSInteger index = 0;
    NSMutableDictionary *subRoutes = self.routes;
    while (index < pathComponents.count) {
        NSString *pathComponent = pathComponents[index];
        if (![subRoutes objectForKey:pathComponent]) {
            subRoutes[pathComponent] = [[NSMutableDictionary alloc] init];
        }
        subRoutes = subRoutes[pathComponent];
        index++;
    }

    return subRoutes;
}

#pragma mark - Private

- (NSMutableDictionary *)routes
{
    if (!_routes) {
        _routes = [[NSMutableDictionary alloc] init];
    }
    return _routes;
}

- (NSMutableDictionary<NSString *, NSMutableArray *> *)targetRoutes
{
    if (!_targetRoutes) {
        _targetRoutes = [[NSMutableDictionary alloc] init];
    }
    return _targetRoutes;
}

- (UIViewController *)createViewControllerByRouteParams:(NSMutableDictionary *)params
{
    Class controllerClass = params[@"controller_class"];
    if (!controllerClass) {
        return nil;
    }

    NSString *route = params[@"route"];
    NSString *target = route;
    if (route && [route containsString:@"?"]) {
        target = [route componentsSeparatedByString:@"?"][0];
    }

    UIViewController *viewController = [[controllerClass alloc] init];
    //    if (![[viewController class] validateParams:params]) {
    BOOL validateResult = [viewController validateParams:params];
    [[NSNotificationCenter defaultCenter] postNotificationName:kZBPageRouteNotificationValidateResult object:nil userInfo:@{ @"result" : @(validateResult),
                                                                                                                             @"paramsDict" : [params copy] }];
    if (!validateResult) {
        return nil;
    }

    objc_setAssociatedObject(viewController, @selector(params), [params copy], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    return viewController;
}

- (NSString *)stringFromFilterAppUrlScheme:(NSString *)string
{
    // 过滤一切scheme
    if ([string rangeOfString:@"://"].location != NSNotFound) {
        NSArray *pathSegments = [string componentsSeparatedByString:@"://"];
        NSString *appUrlScheme = pathSegments[0];
        string = [string substringFromIndex:appUrlScheme.length + 2];
    }
    return string;
}

- (NSArray *)appUrlSchemes
{
    NSMutableArray *appUrlSchemes = [NSMutableArray array];
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    for (NSDictionary *dic in infoDictionary[@"CFBundleURLTypes"]) {
        NSString *appUrlScheme = dic[@"CFBundleURLSchemes"][0];
        [appUrlSchemes addObject:appUrlScheme];
    }

    return [appUrlSchemes copy];
}

@end

@implementation ZBPageRouter (Testing)

inline static __attribute__((__always_inline__)) void iterate(NSDictionary<NSString *, id> *dict, NSArray<NSString *> *keyPath, void (^block)(NSArray<NSString *> *currentKeyPath, id v))
{
    for (NSString *key in dict) {
        NSMutableArray *currentKeyPath = [(keyPath ?: @[]) mutableCopy];
        [currentKeyPath addObject:key];

        id v = dict[key];

        if ([v isKindOfClass:[NSDictionary class]]) {
            iterate(v, [currentKeyPath copy], block);
        } else {
            block([currentKeyPath copy], v);
        }
    }
}

- (NSDictionary *)registeredRoutes
{
    NSMutableDictionary *result = [NSMutableDictionary dictionary];

    iterate(self.routes, nil, ^(NSArray<NSString *> *currentKeyPath, id v) {

        NSString *route = [[self zbMapWithArray:[self zbRejectWithArray:currentKeyPath block:^BOOL(NSString *k) {
            return [k isEqualToString:@"_"];
        }] block:^id(NSString *k) {
        if ([k hasSuffix:kZBPageRouteBlockSuffix]) {
            return [k substringToIndex:k.length - kZBPageRouteBlockSuffix.length];
        }
        return k;
      }] componentsJoinedByString:@"/"];

      if (result[route]) {
          result[route] = [result[route] stringByAppendingFormat:@",%@", [v class]];
      } else {
          result[route] = NSStringFromClass([v class]);
      }

    });

    return CFBridgingRelease(CFPropertyListCreateDeepCopy(kCFAllocatorDefault, (__bridge CFPropertyListRef)(result), kCFPropertyListImmutable));
}

- (NSArray *)zbRejectWithArray:(NSArray *)array block:(BOOL (^)(id obj))block
{
    return [array objectsAtIndexes:[array indexesOfObjectsPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
        return block(obj);
    }]];
}
- (NSArray *)zbMapWithArray:(NSArray *)array block:(id (^)(id obj))block
{
    NSParameterAssert(block != nil);
    
    NSMutableArray *result = [NSMutableArray arrayWithCapacity:array.count];
    
    [array enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        id value = block(obj) ?: [NSNull null];
        [result addObject:value];
    }];
    
    return result;
}
@end

#pragma mark - UIViewController Category

@implementation UIViewController (ZBPageRouter)

- (NSDictionary *)params
{
    return objc_getAssociatedObject(self, @selector(params));
}

- (BOOL)validateParams:(NSDictionary *)params
{
    return YES;
}
@end
