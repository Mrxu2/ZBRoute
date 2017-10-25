//
//  NSObject+ZBRunAtDealloc.h
//  ZBRoute
//
//  Created by xzb on 2017/10/25.
//  Copyright © 2017年 xzb. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (ZBPageResultBlockRunAtDealloc)

- (void)zb_runAtDealloc:(void (^)(void))block;

@end
