//
//  ZBNavigator+Transition.h
//  XZBDemo
//
//  Created by xzb on 2017/10/25.
//  Copyright © 2017年 xzb. All rights reserved.
//

#import "ZBNavigator.h"
#import "ZBViewControllerTransition.h"

NS_ASSUME_NONNULL_BEGIN

/**
 用于构造视图跳转需要的所有参数 不然需要写很多对外函数
 */
@interface ZBNavigatorParams : NSObject

@property (assign, nonatomic) ZBViewControllerTransitionType transitionType; // 视图控制器出现的动画
@property (copy, nonatomic) NSDictionary *_Nullable params;                  // 参数 用于生成视图控制器
@property (copy, nonatomic) NSString *_Nullable urlString;                   // url 用于生成视图控制器
@property (weak, nonatomic) UIViewController *_Nullable viewController;      // 视图控制器 #warning params urlString viewController 是等价的 使用一个即可

@property (weak, nonatomic) id<ZBPageResultProtocol> _Nullable delegate; // 回调代理 用于带回数据
@property (copy, nonatomic) ZBPageResultBlock _Nullable pageResultBlock; // 回调 block 用于带回数据

@property (copy, nonatomic) void (^_Nullable completion)(); // 视图动画完成后的回调

@end

/**
 用于 present 时提供统一的动画，背景和返回控制
 */
@interface ZBNavigator (Transition)

- (BOOL)presentAnimateViewControllerWithParams:(void (^)(ZBNavigatorParams *navigatorParams))navigationParamsBlock;

@end


NS_ASSUME_NONNULL_END
