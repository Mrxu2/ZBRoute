//
//  NSObject+ZBRunAtDealloc.m
//  ZBRoute
//
//  Created by xzb on 2017/10/25.
//  Copyright © 2017年 xzb. All rights reserved.
//

#import "NSObject+ZBRunAtDealloc.h"
#import "objc/runtime.h"

typedef void (^voidBlock)(void);

@interface ZBPageResultBlockBlockExecutor : NSObject {
    voidBlock _block;
}

- (id)initWithBlock:(voidBlock)block;

@end

@implementation ZBPageResultBlockBlockExecutor

- (id)initWithBlock:(voidBlock)aBlock
{
    self = [super init];

    if (self) {
        _block = [aBlock copy];
    }

    return self;
}

- (void)dealloc
{
    _block ? _block() : nil;
}

@end

@implementation NSObject (ZBPageResultBlockRunAtDealloc)

- (void)zb_runAtDealloc:(void (^)(void))block
{
    if (block) {
        ZBPageResultBlockBlockExecutor *executor = [[ZBPageResultBlockBlockExecutor alloc] initWithBlock:block];

        objc_setAssociatedObject(self, @selector(zb_runAtDealloc:), executor, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
}

@end
