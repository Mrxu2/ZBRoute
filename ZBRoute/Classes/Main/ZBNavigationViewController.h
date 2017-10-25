//
//  ZBNavigationViewController.h
//  XZBDemo
//
//  Created by xzb on 2017/10/25.
//  Copyright © 2017年 xzb. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ZBNavigationPanbackDelegate

- (BOOL)hb_shouldPanback;

@end

@interface ZBNavigationViewController : UINavigationController

@end
