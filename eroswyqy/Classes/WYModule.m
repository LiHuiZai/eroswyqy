//
//  WYModule.m
//  eroswyqy
//
//  Created by lh on 2020/12/3.
//

#import "WYModule.h"
#import <QYSDK/QYSDK.h>
#import <WeexSDK/WeexSDK.h>
#import <WeexPluginLoader/WeexPluginLoader/WeexPluginLoader.h>

WX_PlUGIN_EXPORT_MODULE(bmWYqy, WYModule)

@interface WYModule ()
@end

@implementation WYModule

WX_EXPORT_METHOD_SYNC(@selector(initKey:appName:idFusion:));


- (void)initKey:(NSString *)appkey appName:(NSString *)appname idFusion:(NSString *)isFusion
{
    QYSDKOption *option = [[QYSDKOption alloc] init];
    option.appKey = appkey;
    option.appName = appname;
    option.isFusion = isFusion;
    [[QYSDK sharedSDK] registerWithOption:option];
}
@end
