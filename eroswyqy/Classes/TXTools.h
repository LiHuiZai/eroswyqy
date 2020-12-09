//
//  TXTools.h
//  InvestmentAdvisor
//
//  Created by yjs on 2019/2/27.
//  Copyright © 2019 袁佳帅. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#define TXSingletonH(name) + (instancetype)shared##name;
// .m文件
#define TXSingletonM(name) \
static id _instance; \
\
+ (instancetype)allocWithZone:(struct _NSZone *)zone \
{ \
static dispatch_once_t onceToken; \
dispatch_once(&onceToken, ^{ \
_instance = [super allocWithZone:zone]; \
}); \
return _instance; \
} \
\
+ (instancetype)shared##name \
{ \
static dispatch_once_t onceToken; \
dispatch_once(&onceToken, ^{ \
_instance = [[self alloc] init]; \
}); \
return _instance; \
} \
\
- (id)copyWithZone:(NSZone *)zone \
{ \
return _instance; \
}

NS_ASSUME_NONNULL_BEGIN

///>>> 数据如果是0返回情况
typedef NS_ENUM(NSInteger, TXZeroType) {
    TXZeroTypeZero,/// 返回 0
    TXZeroTypeLine /// 返回 --
};

@interface TXTools : NSObject
TXSingletonH(TXTools)

/// 返回当前控制器
- (UIViewController*)currentViewController;

/// 返回当前的导航控制器
- (UINavigationController*)currentNavigationViewController;

@end

NS_ASSUME_NONNULL_END
