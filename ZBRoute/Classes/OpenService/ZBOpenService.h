//
//  ZBOpenService.h
//  XZBDemo
//
//  Created by xzb on 2017/10/25.
//  Copyright © 2017年 xzb. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^ZBOpenServiceCallbackBlock)(NSError *error, id result);

@interface ZBOpenService : NSObject

+ (id)call:(NSString *)serviceString withParams:(NSDictionary *)params;
+ (BOOL)call:(NSString *)serviceString withParams:(NSDictionary *)params callbackBlock:(ZBOpenServiceCallbackBlock)callbackBlock;

@end
