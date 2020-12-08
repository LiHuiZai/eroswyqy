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
WX_PlUGIN_EXPORT_MODULE(bmOpenChat, WYOpenChat)

@interface WYOpenChat ()
@end
@implementation WYOpenChat
WX_EXPORT_METHOD_SYNC(@selector(initKey:appName:idFusion:));



@end
