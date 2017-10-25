# ZBRoute
#Installation

Use the orsome CocoaPods.

In your Podfile

>pod 'ZBRoute'

## ZBPageRouter使用

#### 1. 页面注册和调用

注册方:

```
- (void)registerUrl:(NSString *)route toControllerClass:(Class)controllerClass;
具体:
[[ZBPageRouter router] registerUrl:@"TwoVc" toControllerClass:NSClassFromString(@"TwoVc")];
```

调用方:

```
//target 字段必传
[[ZBNavigator instance] pushViewControllerByDict:@{@"target":@"TwoVc"} animated:YES];
```


#### 2. 页面交互


假设A -> B


正向:
```
A向B发送消息:
@{@"key":@"value"}
[[ZBNavigator instance] pushViewControllerByDict:@{@"target":@"TwoVc",@"key":@"value")} animated:YES];
```

逆向:

```
特别注意:
//使用这个方法调用的话,在OpenService里,方法的返回值是对象类型;
+ (id)call:(NSString *)serviceString withParams:(NSDictionary *)params;
//使用这个方法调用的化,在OpenService理,方法的返回值是BOOL类型;
+ (BOOL)call:(NSString *)serviceString withParams:(NSDictionary *)params callbackBlock:(ZBOpenServiceCallbackBlock)callbackBlock;
```
```
B向A发送消息:
需要使用OpenService
遵循命名规则:
模块/控制器/方法

发送方(在B界面):
BOOL callBack = [[ZBOpenService call:@"zb/twoVc/one" withParams:@{@"key":@"value"}] boolValue];
NSLog(@"callBack> %d",callBack);

BOOL callBack2 = [ZBOpenService call:@"zb/twoVc/two" withParams:@{@"key":@"value"} callbackBlock:^(NSError *error, id result) {
NSLog(@"result> %@",result);
}];
NSLog(@"callBack2> %d",callBack2);

在接受方:
新建一个ZBTwoVcOpenService继承NSObject的接收类

@interface ZBTwoVcOpenService : NSObject

- (NSNumber *)one:(NSDictionary *)param;

- (BOOL)two:(NSDictionary *)param callbackBlock:(void(^)(NSError *error, id result))callbackBlock;

@end

#import "ZBTwoVcOpenService.h"
@implementation ZBTwoVcOpenService

- (NSNumber *)one:(NSDictionary *)param
{
NSLog(@"%s %@",__func__,param);
return @(YES);
}

- (BOOL)two:(NSDictionary *)param callbackBlock:(void(^)(NSError *error, id result))callbackBlock
{
NSLog(@"%s %@",__func__,param);
dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
if (callbackBlock){
callbackBlock(nil,@"123");
}
});

return YES;
}

@end


```

