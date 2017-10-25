# ZBRoute

## Installation

```ruby
# Podfile

pod 'ZBRoute'
```

## Requirements

- iOS 8+ 
- Xcode 7+

## Usage

#### 1. register

######registrant:

```ruby
- (void)registerUrl:(NSString *)route toControllerClass:(Class)controllerClass;
example:
[[ZBPageRouter router] registerUrl:@"TwoVc" toControllerClass:NSClassFromString(@"TwoVc")];
```

######caller:

```ruby
Request : @{@"target"::@"String"}
example:
[[ZBNavigator instance] pushViewControllerByDict:@{@"target":@"TwoVc"} animated:YES];
```


#### 2. interaction


A -> B

>  message:@{@"key":@"value"}

```
example:
A:
[[ZBNavigator instance] pushViewControllerByDict:@{@"target":@"TwoVc",@"key":@"value")} animated:YES];

B:
- (BOOL)validateParams:(NSDictionary *)params{
    NSLog(@"params:%@",params);
    return YES;
}
```

B->A
> message:@"key":@"value"}

```
Follow the naming rules:
@"module/controller/method"
send "MODULE/Controller/Openservice" class to the "method";

遵循命名规则:
模块/控制器/方法
会向"MODULE/Controller/Openservice"的类发送"method"的消息;
需要使用OpenService
```
```
notice:
//使用这个方法调用的话,在OpenService里,方法的返回值是对象类型;
+ (id)call:(NSString *)serviceString withParams:(NSDictionary *)params;
//使用这个方法调用的化,在OpenService理,方法的返回值是BOOL类型;
+ (BOOL)call:(NSString *)serviceString withParams:(NSDictionary *)params callbackBlock:(ZBOpenServiceCallbackBlock)callbackBlock;
```
```
B:
    BOOL callBack = [[ZBOpenService call:@"zb/twoVc/one" withParams:@{@"key":@"value"}] boolValue];
    NSLog(@"callBack> %d",callBack);

    BOOL callBack2 = [ZBOpenService call:@"zb/twoVc/two" withParams:@{@"key":@"value"} callbackBlock:^(NSError *error, id result) {
          NSLog(@"result> %@",result);
    }];
    NSLog(@"callBack2> %d",callBack2);
```
```
A:
新建一个ZBTwoVcOpenService继承NSObject的接收类

@interface ZBTwoVcOpenService : NSObject

- (NSNumber *)one:(NSDictionary *)param;

- (BOOL)two:(NSDictionary *)param callbackBlock:(void(^)(NSError *error, id result))callbackBlock;

@end
```
```
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

