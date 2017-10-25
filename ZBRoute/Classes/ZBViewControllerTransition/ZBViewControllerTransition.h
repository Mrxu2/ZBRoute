//
//  ZBViewControllerTransition.h
//  ZBRoute
//
//  Created by xzb on 2017/10/25.
//  Copyright © 2017年 xzb. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, ZBViewControllerTransitionType) {

    ZBPageResultBlockViewControllerTransitionActionSheet,
    ZBPageResultBlockViewControllerTransitionPop,
};

@interface ZBViewControllerTransition : NSObject <UIViewControllerTransitioningDelegate>

/**
 使用当前的视图控制器初始化
 
 @param viewController 当前的视图控制器
 @return ZBPageResultBlockViewControllerTransition对象
 */
- (instancetype)initWithViewController:(UIViewController *)viewController transtionType:(ZBViewControllerTransitionType)transitionType;

/**
 present 显示一个视图控制器
 
 @param viewControlelr 视图控制器
 @param params 参数
 */
- (void)presentViewController:(UIViewController *)viewControlelr params:(NSDictionary *)params completion:(void (^)(void))completion;

@end
