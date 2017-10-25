//
//  UIViewController+PageResult.m
//  XZBDemo
//
//  Created by xzb on 2017/10/25.
//  Copyright © 2017年 xzb. All rights reserved.
//

#import "UIViewController+PageResult.h"
#import "objc/runtime.h"
#import "NSObject+ZBRunAtDealloc.h"

@implementation UIViewController (PageResult)

- (void)setPageResult:(NSMutableDictionary *)pageResult
{
    objc_setAssociatedObject(self, @selector(pageResult), pageResult, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSMutableDictionary *)pageResult
{
    NSMutableDictionary *pageResult = objc_getAssociatedObject(self, @selector(pageResult));
    if (pageResult == nil) {
        pageResult = [NSMutableDictionary dictionary];
        [self setPageResult:pageResult];
    }
    return pageResult;
}

- (void)setZbDelegate:(id)zbDelegate
{
    objc_setAssociatedObject(self, @selector(zbDelegate), zbDelegate, OBJC_ASSOCIATION_ASSIGN);
    __weak id weakSelf = self;
    [zbDelegate zb_runAtDealloc:^{
      objc_setAssociatedObject(weakSelf, @selector(zbDelegate), nil, OBJC_ASSOCIATION_ASSIGN);
    }];
}

- (id<ZBPageResultProtocol>)zbDelegate
{
    return objc_getAssociatedObject(self, @selector(zbDelegate));
}

- (void)setZbPageResultBlock:(ZBPageResultBlock)pageResultBlock
{
    objc_setAssociatedObject(self, @selector(zbPageResultBlock), pageResultBlock, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (ZBPageResultBlock)zbPageResultBlock
{
    return objc_getAssociatedObject(self, @selector(zbPageResultBlock));
}

@end
