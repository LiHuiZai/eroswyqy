//
//  WYOpenChat.m
//  eroswyqy
//
//  Created by lh on 2020/12/7.
//

#import "WYOpenChat.h"
#import <QYSDK/QYSDK.h>
#import <WeexSDK/WeexSDK.h>
#import <WeexPluginLoader/WeexPluginLoader/WeexPluginLoader.h>
#import "TXTools.h"

WX_PlUGIN_EXPORT_MODULE(bmOpenChat, WYOpenChat)

@interface WYOpenChat ()
@end
@implementation WYOpenChat
WX_EXPORT_METHOD_SYNC(@selector(openchat:));

- (void)openchat:(NSDictionary *)info
{
    
    QYSource *source = [[QYSource alloc] init];
    source.title = @"七鱼客服";
    source.urlString = @"https://qiyukf.com/";

    QYSessionViewController *sessionViewController = [[QYSDK sharedSDK] sessionViewController];
    sessionViewController.sessionTitle = source.title;
    sessionViewController.source = source;    
    sessionViewController.hidesBottomBarWhenPushed = YES;
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:sessionViewController];
    sessionViewController.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"返回" style:UIBarButtonItemStylePlain target:self action:@selector(onBack:)];
    [[TXTools sharedTXTools].currentNavigationViewController pushViewController:nav animated:YES];
    
}
- (void)onBack:(id)sender {
    [[TXTools sharedTXTools].currentViewController dismissViewControllerAnimated:YES completion:nil];
}

@end
