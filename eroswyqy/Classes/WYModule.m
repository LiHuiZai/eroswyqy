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
#import "TXTools.h"
#import "NSDictionary+Util.h"

WX_PlUGIN_EXPORT_MODULE(ErosQiyu, WYModule)

@interface WYModule ()
@end

@implementation WYModule

//WX_EXPORT_METHOD_SYNC(@selector(initKey:appName:idFusion:));
WX_EXPORT_METHOD_SYNC(@selector(open:));
WX_EXPORT_METHOD_SYNC(@selector(login:info:callback:));//登陆
WX_EXPORT_METHOD_SYNC(@selector(logout));//退出登陆
WX_EXPORT_METHOD_SYNC(@selector(track:data:));//行为记录
WX_EXPORT_METHOD_SYNC(@selector(getUnreadCount:));//未读消息数量

//消息点击 拦截点击事件
//消息通知 离开聊天界面的消息通知


- (void)open:(NSDictionary *)info
{
    
    QYSource *source = [[QYSource alloc] init];
    source.title = [info objectForKey:@"sourceTitle"];
    source.urlString = [info objectForKey:@"sourceUri"];

    QYSessionViewController *sessionViewController = [[QYSDK sharedSDK] sessionViewController];
    sessionViewController.sessionTitle = source.title;
    sessionViewController.source = source;
    NSString *strProduct = [info objectForKey:@"product"];
    if ([self isBlankString:strProduct]) {
        NSDictionary *dic =[[self class] dictionaryWithJsonString:strProduct];
        sessionViewController.commodityInfo = [self makeCommodityInfo:dic];
    }else{
        sessionViewController.commodityInfo = NULL;
    }
    
    sessionViewController.hidesBottomBarWhenPushed = YES;
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:sessionViewController];
    sessionViewController.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"返回" style:UIBarButtonItemStylePlain target:self action:@selector(onBack:)];
    [[TXTools sharedTXTools].currentNavigationViewController pushViewController:nav animated:YES];
    
}
//登陆
- (void)login:(NSString *)userID info:(NSString *)info callback:(WXModuleCallback)callback{
    QYUserInfo *userInfo = [[QYUserInfo alloc] init];
    userInfo.userId = userID;
    userInfo.data = info;
    [[QYSDK sharedSDK] setUserInfo:userInfo authTokenVerificationResultBlock:nil];
    [[QYSDK sharedSDK] setUserInfoForFusion:userInfo userInfoResultBlock:^(BOOL success, NSError *error) {
       
        NSInteger resCode = success ? BMResCodeSuccess : BMResCodeError;

        if (callback) {
            NSMutableDictionary * dict = nil;

            NSDictionary *resDic = [NSDictionary configCallbackDataWithResCode:resCode msg:nil data:dict];
            callback(resDic);
        }
        
    } authTokenResultBlock:nil];
    
    
}
//退出登陆
- (void)logout{
    [[QYSDK sharedSDK] logout:^(BOOL success) {
    }];
}

//行为记录
- (void)track:(NSString *)title data :(NSDictionary *)data{
    NSString *key = [[NSUUID UUID] UUIDString];
    [[QYSDK sharedSDK] trackHistory:title description:data key:key];
}
- (void)onBack:(id)sender {
    [[TXTools sharedTXTools].currentViewController dismissViewControllerAnimated:YES completion:nil];
}
- (void)getUnreadCount:(WXModuleCallback)callback{
    NSInteger count = [[[QYSDK sharedSDK] conversationManager] allUnreadCount];

    NSString *str = [NSString stringWithFormat:@"%ld",(long)count];
    if (callback) {
        NSMutableDictionary * dict = nil;
        
        NSDictionary *resDic = [NSDictionary configCallbackDataWithResCode:0 msg:str data:dict];
        callback(resDic);
    }
}
-(QYCommodityInfo *)makeCommodityInfo:(NSDictionary *)dic{
    QYCommodityInfo *commodityInfo = nil;
    commodityInfo.title = [dic objectForKey:@"title"];
    commodityInfo.desc = [dic objectForKey:@"desc"];
    commodityInfo.urlString = [dic objectForKey:@"url"];
    commodityInfo.pictureUrlString = [dic objectForKey:@"picture"];
    commodityInfo.note = [dic objectForKey:@"note"];
    commodityInfo.show = YES;
    
    return commodityInfo;
}


/**
 *  JSON字符串转NSDictionary
 *
 *  @param jsonString JSON字符串
 *
 *  @return NSDictionary
 */
+ (NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString {
    if (jsonString == nil) {
        return nil;
    }
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&error];
    if(error) {
        NSLog(@"json解析失败：%@",error);
        return nil;
    }
    return dic;
}

- (BOOL)isBlankString:(NSString *)aStr {
    if (!aStr) {
        return YES;
    }
    if ([aStr isKindOfClass:[NSNull class]]) {
        return YES;
    }
    if (!aStr.length) {
        return YES;
    }
    NSCharacterSet *set = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    NSString *trimmedStr = [aStr stringByTrimmingCharactersInSet:set];
    if (!trimmedStr.length) {
        return YES;
    }
    return NO;
}
@end
