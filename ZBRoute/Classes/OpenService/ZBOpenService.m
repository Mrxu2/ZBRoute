//
//  ZBOpenService.m
//  ZBRoute
//
//  Created by xzb on 2017/10/25.
//  Copyright © 2017年 xzb. All rights reserved.
//

#import "ZBOpenService.h"
#import <objc/message.h>

@interface ZBOpenService ()
@property (nonatomic, strong) NSMutableArray *services;
@end

@implementation ZBOpenService

+ (instancetype)instance
{
    static dispatch_once_t oncePredicate;
    static ZBOpenService *instance;
    dispatch_once(&oncePredicate, ^{
      instance = [[self alloc] init];
    });
    return instance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _services = [NSMutableArray array];
    }
    return self;
}

+ (id)call:(NSString *)serviceString withParams:(NSDictionary *)params
{
    __block id targetOpenService;
    __block SEL targetSelector;

    if (![self validateServiceCall:serviceString
                       hasCallBack:NO
                        completion:^(id object, SEL selector) {
                          targetOpenService = object;
                          targetSelector = selector;
                        }]) {
        return nil;
    }

    NSMethodSignature *sig = [targetOpenService methodSignatureForSelector:targetSelector];
    const char *returnType = sig.methodReturnType;

    if (strcmp(returnType, "@") != 0) {
        NSLog(@"OpenService 方法签名不正确，没有返回值或返回值类型不是对象 [%@]", serviceString);
        ((void (*)(id, SEL, id)) objc_msgSend)(targetOpenService, targetSelector, params);
        return nil;
    }

    return ((id(*)(id, SEL, id)) objc_msgSend)(targetOpenService, targetSelector, params);
}

+ (BOOL)call:(NSString *)serviceString withParams:(NSDictionary *)params callbackBlock:(ZBOpenServiceCallbackBlock)callbackBlock
{
    __block id targetOpenService;
    __block SEL targetSelector;

    if (![self validateServiceCall:serviceString
                       hasCallBack:YES
                        completion:^(id object, SEL selector) {
                          targetOpenService = object;
                          targetSelector = selector;
                        }]) {
        return NO;
    }

    [[ZBOpenService instance].services addObject:targetOpenService];
    ZBOpenServiceCallbackBlock callback = [ZBOpenService callbackBlock:callbackBlock openService:targetOpenService];

    NSMethodSignature *sig = [targetOpenService methodSignatureForSelector:targetSelector];
    const char *returnType = sig.methodReturnType;

    if (strcmp(returnType, @encode(BOOL)) != 0) {
        NSLog(@"OpenService 方法签名不正确，没有返回值或返回值类型不是 BOOL [%@]", serviceString);
        ((void (*)(id, SEL, id, ZBOpenServiceCallbackBlock)) objc_msgSend)(targetOpenService, targetSelector, params, callback);
        return NO;
    }

    return ((BOOL(*)(id, SEL, id, ZBOpenServiceCallbackBlock)) objc_msgSend)(targetOpenService, targetSelector, params, callback);
}

+ (ZBOpenServiceCallbackBlock)callbackBlock:(ZBOpenServiceCallbackBlock)callbackBlock openService:(NSObject *)openService
{
    ZBOpenServiceCallbackBlock block = ^(NSError *error, id result) {
      [[ZBOpenService instance].services removeObject:openService];
      callbackBlock(error, result);
    };
    return [block copy];
}

+ (BOOL)validateServiceCall:(NSString *)serviceString
                hasCallBack:(BOOL)hasCallBack
                 completion:(__attribute__((noescape)) void (^)(id object, SEL selector))completion
{
    Class targetClass = [ZBOpenService serviceClassFromString:serviceString];
    SEL targetSelector = [ZBOpenService selectorFromString:serviceString hasCallBack:hasCallBack];

    if (targetClass == nil || targetSelector == nil) {
        NSLog(@"OpenService 称不规范 [%@]", serviceString);
        return NO;
    }

    id targetOpenService = [[targetClass alloc] init];

    if (![targetOpenService respondsToSelector:targetSelector]) {

        NSLog(@"OpenService 找不到对应的方法 [%@]-->%@", serviceString, NSStringFromSelector(targetSelector));
        return NO;
    }

    completion(targetOpenService, targetSelector);
    return YES;
}

+ (Class)serviceClassFromString:(NSString *)serviceString
{
    NSArray *pathArray = [serviceString componentsSeparatedByString:@"/"];
    NSMutableString *serviceClassMS = [[NSMutableString alloc] init];
    for (NSUInteger index = 0; index < pathArray.count - 1; index++) {
        NSString *path = pathArray[index];
        if (index == 0) {
            [serviceClassMS appendString:[path uppercaseString]];
        } else {
            [serviceClassMS appendFormat:@"%@", [path stringByReplacingCharactersInRange:NSMakeRange(0, 1) withString:[[path substringToIndex:1] uppercaseString]]];
        }
    }
    [serviceClassMS appendString:@"OpenService"];
    return NSClassFromString(serviceClassMS);
}

+ (SEL)selectorFromString:(NSString *)serviceString hasCallBack:(BOOL)hasCallBack
{
    NSRange lastFlag = [serviceString rangeOfString:@"/" options:NSBackwardsSearch];
    NSString *lastPath = [serviceString substringFromIndex:lastFlag.location + 1];
    NSString *selectorString = nil;
    if (hasCallBack) {
        selectorString = [NSString stringWithFormat:@"%@:callbackBlock:", lastPath];
    } else {
        selectorString = [NSString stringWithFormat:@"%@:", lastPath];
    }
    return NSSelectorFromString(selectorString);
}

@end
