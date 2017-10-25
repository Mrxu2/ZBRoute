//
//  ZBPageResultProtocol.h
//  ZBRoute
//
//  Created by xzb on 2017/10/25.
//  Copyright © 2017年 xzb. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@protocol ZBPageResultProtocol <NSObject>
- (void)zb_target:(NSString *)target didFinishWithResult:(NSDictionary *)result;
@end
