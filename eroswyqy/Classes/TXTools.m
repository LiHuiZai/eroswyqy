//
//  TXTools.m
//  InvestmentAdvisor
//
//  Created by yjs on 2019/2/27.
//  Copyright © 2019 袁佳帅. All rights reserved.
//

#import "TXTools.h"

#define TXCOLORBLACK [UIColor colorWithRed:51.0/255 green:51.0/255 blue:51.0/255 alpha:1]
#define TXCOLORRED [UIColor colorWithRed:244.0/255 green:67.0/255 blue:54.0/255 alpha:1]
#define TXCOLORGREEN [UIColor colorWithRed:32.0/255 green:171.0/255 blue:63.0/255 alpha:1]

@implementation TXTools
TXSingletonM(TXTools)

- (UIViewController*)currentViewController {
    UIViewController* rootViewController = self.applicationDelegate.window.rootViewController;
    return [self currentViewControllerFrom:rootViewController];
}

- (UINavigationController*)currentNavigationViewController {
    UIViewController* currentViewController = self.currentViewController;
    return currentViewController.navigationController;
}

- (id<UIApplicationDelegate>)applicationDelegate {
    return [UIApplication sharedApplication].delegate;
}

// 通过递归拿到当前控制器
- (UIViewController*)currentViewControllerFrom:(UIViewController*)viewController {
    if ([viewController isKindOfClass:[UINavigationController class]]) {
        UINavigationController* navigationController = (UINavigationController *)viewController;
        return [self currentViewControllerFrom:navigationController.viewControllers.lastObject];
    } // 如果传入的控制器是导航控制器,则返回最后一个
    else if([viewController isKindOfClass:[UITabBarController class]]) {
        UITabBarController* tabBarController = (UITabBarController *)viewController;
        return [self currentViewControllerFrom:tabBarController.selectedViewController];
    } // 如果传入的控制器是tabBar控制器,则返回选中的那个
    else if(viewController.presentedViewController != nil) {
        return [self currentViewControllerFrom:viewController.presentedViewController];
    } // 如果传入的控制器发生了modal,则就可以拿到modal的那个控制器
    else {
        return viewController;
    }
}
@end
