//
//  UIViewController+PageResult.h
//  XZBDemo
//
//  Created by xzb on 2017/10/25.
//  Copyright © 2017年 xzb. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZBPageResultProtocol.h"

typedef void (^ZBPageResultBlock)(NSDictionary *result);

@interface UIViewController (PageResult)

@property (nonatomic, weak) id<ZBPageResultProtocol> zbDelegate;
@property (nonatomic, copy) ZBPageResultBlock zbPageResultBlock;
@property (nonatomic, strong) NSMutableDictionary *pageResult;

@end
