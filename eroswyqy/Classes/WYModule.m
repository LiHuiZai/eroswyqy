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
#import "BMGlobalEventManager.h"
#import "BMConfigManager.h"
#import "BMMediatorManager.h"
#import "WYPushMessage.h"

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

//消息通知 离开聊天界面的消息通知


- (void)open:(NSDictionary *)info
{
    [[WYPushMessage shareInstance] configPushService];

    QYSource *source = [[QYSource alloc] init];
    source.title = [info objectForKey:@"sourceTitle"];
    source.urlString = [info objectForKey:@"sourceUri"];

    QYSessionViewController *sessionViewController = [[QYSDK sharedSDK] sessionViewController];
    sessionViewController.sessionTitle = source.title;
    sessionViewController.source = source;
    
    //测试
//    sessionViewController.staffId = 5976966;
    
    NSString *strProduct = [info objectForKey:@"product"];
    BOOL isProduct = [self isBlankString:strProduct];
    if (!isProduct) {
        NSDictionary *dic =[[self class] dictionaryWithJsonString:strProduct];
        sessionViewController.commodityInfo = [self makeCommodityInfo:dic];
    }else{
        sessionViewController.commodityInfo = NULL;
    }
    sessionViewController.hidesBottomBarWhenPushed = YES;
    
    /**
     * 所有消息中的链接回调
     */
    [[QYSDK sharedSDK] customActionConfig].linkClickBlock = ^(NSString *actionUrl) {
//        NSString *tip = [NSString stringWithFormat:@"actionUrl: %@", actionUrl];
//        NSDictionary *dicUrl = @{@"chatJumpUrl": actionUrl};
//        NSString *strUrl = [self convertToJsonData:dicUrl];
//        NSDictionary *resDic = [NSDictionary configCallbackDataWithResCode:0 msg:nil data:dicUrl];
        NSDictionary *userinfo=[NSDictionary dictionaryWithObject:actionUrl forKey:@"pageJumpUrl"];
          [BMGlobalEventManager pushMessage:userinfo appLaunchedByNotification:YES];

        [[TXTools sharedTXTools].currentViewController dismissViewControllerAnimated:YES completion:nil];
    };
    
    
    
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:sessionViewController];
    sessionViewController.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"返回" style:UIBarButtonItemStylePlain target:self action:@selector(onBack:)];
//    [[TXTools sharedTXTools].currentNavigationViewController pushViewController:nav animated:YES];
    [[TXTools sharedTXTools].currentViewController presentViewController:nav animated:YES completion:nil];
    
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
        
        NSDictionary *resDic = [NSDictionary configCallbackDataWithResCode:0 msg:nil data:str];
        
        callback(resDic);
    }
}
-(QYCommodityInfo *)makeCommodityInfo:(NSDictionary *)dic{
    QYCommodityInfo *commodityInfo = [[QYCommodityInfo alloc]init];
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
    if ([aStr isEqualToString:@"null"]) {
        return  YES;
    }
    NSCharacterSet *set = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    NSString *trimmedStr = [aStr stringByTrimmingCharactersInSet:set];
    if (!trimmedStr.length) {
        return YES;
    }
    return NO;
}

// 字典转json字符串方法

-(NSString *)convertToJsonData:(NSDictionary *)dict

{

    NSError *error;

    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:&error];

    NSString *jsonString;

    if (!jsonData) {

        NSLog(@"%@",error);

    }else{

        jsonString = [[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding];

    }

    NSMutableString *mutStr = [NSMutableString stringWithString:jsonString];

    NSRange range = {0,jsonString.length};

    //去掉字符串中的空格

    [mutStr replaceOccurrencesOfString:@" " withString:@"" options:NSLiteralSearch range:range];

    NSRange range2 = {0,mutStr.length};

    //去掉字符串中的换行符

    [mutStr replaceOccurrencesOfString:@"\n" withString:@"" options:NSLiteralSearch range:range2];

    return mutStr;

}

@end
