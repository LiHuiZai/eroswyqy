//
//  WYPushMessage.m
//  eroswyqy
//
//  Created by lh on 2020/12/17.
//

#import "WYPushMessage.h"
#import "BMGlobalEventManager.h"
#import "BMConfigManager.h"
#import "BMMediatorManager.h"
#import <QYSDK/QYSDK.h>

// iOS10 及以上需导入 UserNotifications.framework
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_10_0
#import <UserNotifications/UserNotifications.h>
#endif

@interface WYPushMessage () <UNUserNotificationCenterDelegate,QYConversationManagerDelegate, QYSessionViewDelegate>
{
    NSString *_cid;
    NSString *_deviceToken;
    NSDictionary *_pushMessage;
}
@end

@implementation WYPushMessage

#pragma mark - Setter / Getter

#pragma mark - Private Method

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

+ (instancetype)shareInstance
{
    static WYPushMessage *_instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[WYPushMessage alloc] init];
    });
    
    return _instance;
}

- (instancetype)init
{
    if (self = [super init]) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidEnterBackground) name:UIApplicationDidEnterBackgroundNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidBecomeActive) name:UIApplicationDidBecomeActiveNotification object:nil];
    }
    return self;
}

- (void)appDidEnterBackground
{
//    self.isLaunchedByNotification = YES;
}

- (void)appDidBecomeActive
{
//    self.isLaunchedByNotification = NO;
}

/**
 解析push消息、透传消息
 
 @param userInfo 消息体
 */
- (void)analysisRemoteNotification:(NSDictionary *)userInfo
{
    if (![BMMediatorManager shareInstance].currentWXInstance) {
        [[self class] addPushNotification:userInfo];
        return;
    }
    [BMGlobalEventManager pushMessage:userInfo appLaunchedByNotification:self.isLaunchedByNotification];
}

/** 当首屏渲染完毕通知响应方法 */
- (void)firstScreenDidFinished:(NSNotification *)not
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.isLaunchedByNotification = YES;
//        [self analysisRemoteNotification:_pushMessage];
//        _pushMessage = nil;
    });
    [[NSNotificationCenter defaultCenter] removeObserver:[WYPushMessage shareInstance] name:BMFirstScreenDidFinish object:nil];
}

/* 注册push推送服务 */
- (void)registerRemoteNotification
{
    /*
     警告：Xcode8 需要手动开启"TARGETS -> Capabilities -> Push Notifications"
     */
    
    /*
     警告：该方法需要开发者自定义，以下代码根据 APP 支持的 iOS 系统不同，代码可以对应修改。
     以下为演示代码，注意根据实际需要修改，注意测试支持的 iOS 系统都能获取到 DeviceToken
     */
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 10.0) {
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_10_0 // Xcode 8编译会调用
        if (@available(iOS 10.0, *)) {
            UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
            center.delegate = self;
            [center requestAuthorizationWithOptions:(UNAuthorizationOptionBadge | UNAuthorizationOptionSound | UNAuthorizationOptionAlert | UNAuthorizationOptionCarPlay) completionHandler:^(BOOL granted, NSError *_Nullable error) {
                if (!error) {
                    WXLogInfo(@"request authorization succeeded!");
                }
            }];
        } else {
            // Fallback on earlier versions
        }
        
        [[UIApplication sharedApplication] registerForRemoteNotifications];
#else // Xcode 7编译会调用
        UIUserNotificationType types = (UIUserNotificationTypeAlert | UIUserNotificationTypeSound | UIUserNotificationTypeBadge);
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:types categories:nil];
        [[UIApplication sharedApplication] registerForRemoteNotifications];
        [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
#endif
    } else if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0) {
        UIUserNotificationType types = (UIUserNotificationTypeAlert | UIUserNotificationTypeSound | UIUserNotificationTypeBadge);
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:types categories:nil];
        [[UIApplication sharedApplication] registerForRemoteNotifications];
        [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
    }
}

#pragma mark - System Delegate & DataSource

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_10_0

//  iOS 10: App在前台获取到通知
- (void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions))completionHandler  API_AVAILABLE(ios(10.0)){
    
    WXLogInfo(@"willPresentNotification：%@", notification.request.content.userInfo);
    
    NSDictionary *userInfo = notification.request.content.userInfo;
    
    [self analysisRemoteNotification:userInfo];
    
    
    // 根据APP需要，判断是否要提示用户Badge、Sound、Alert
//    completionHandler(UNNotificationPresentationOptionBadge | UNNotificationPresentationOptionSound | UNNotificationPresentationOptionAlert);
}

//  iOS 10: 点击通知进入App时触发，在该方法内统计有效用户点击数
- (void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)(void))completionHandler  API_AVAILABLE(ios(10.0)){
    
    WXLogInfo(@"didReceiveNotification：%@", response.notification.request.content.userInfo);
    
    NSDictionary *userInfo = response.notification.request.content.userInfo;
    
    [self analysisRemoteNotification:userInfo];
        
    completionHandler();
}

#endif

#pragma mark - Public Method

- (void)configPushService
{

    [self registerRemoteNotification];
}
- (void)WYregisterPushMessageNotification{
    
    [[QYSDK sharedSDK] registerPushMessageNotification:^(QYPushMessage *message) {
        NSString *time = [[self class] showTime:message.time showDetail:YES];
        NSString *content = @"";
        content = [NSString stringWithFormat:@"头像url：%@ \n按钮文本：%@ \n按钮链接：%@ \n时间：%@", message.headImageUrl, message.actionText, message.actionUrl, time] ;
        if (message.type == QYPushMessageTypeText) {
            content = [content stringByAppendingString:[NSString stringWithFormat:@" \n内容：%@", message.text]];
        } else if (message.type == QYPushMessageTypeRichText) {
            content = [content stringByAppendingString:[NSString stringWithFormat:@" \n内容：%@", message.richText]];
        } else if (message.type == QYPushMessageTypeImage) {
            content = [content stringByAppendingString:[NSString stringWithFormat:@" \n内容：%@", message.imageUrl]];
        }

        UIAlertView *dialog = [[UIAlertView alloc] initWithTitle:@"推送消息"
                                                         message:content
                                                        delegate:self
                                               cancelButtonTitle:@"确定"
                                               otherButtonTitles:nil,nil];
        [dialog show];
    }];
    
}


+ (void)registerForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    if (@available(iOS 13.0, *)) {
       NSUInteger length = [deviceToken length];
       char *chars = (char *)[deviceToken bytes];
       NSMutableString *hexString = [[NSMutableString alloc] init];
       for (NSUInteger i = 0; i < length; i++) {
        [hexString appendString:[NSString stringWithFormat:@"%0.2hhx", chars[i]]];
       }
       [WYPushMessage shareInstance]->_deviceToken=hexString;
    }else{
       NSString *token = [self hexadecimalString:deviceToken];
       [WYPushMessage shareInstance]->_deviceToken = [token stringByReplacingOccurrencesOfString:@" " withString:@""];
    }
    [[QYSDK sharedSDK] updateApnsToken:deviceToken];

}

+ (NSString *)hexadecimalString:(NSData *)data
{
    const unsigned char *dataBuffer = (const unsigned char *)[data bytes];

    if (!dataBuffer) {
        return [NSString string];
    }

    NSUInteger dataLength  = [data length];
    NSMutableString *hexString  = [NSMutableString stringWithCapacity:(dataLength * 2)];

    for (int i = 0; i < dataLength; ++i) {
        [hexString appendFormat:@"%02x", (unsigned int)dataBuffer[i]];
    }

    return [NSString stringWithString:hexString];
}

+ (void)performFetchWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
{
    completionHandler(UIBackgroundFetchResultNewData);
}

+ (void)receiveRemoteNotificationWY:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
{
    [[WYPushMessage shareInstance] analysisRemoteNotification:userInfo];
    completionHandler(UIBackgroundFetchResultNewData);
}


+ (void)addPushNotification:(NSDictionary *)pushMessage
{
    [WYPushMessage shareInstance]->_pushMessage = pushMessage;
    
    [[NSNotificationCenter defaultCenter] addObserver:[WYPushMessage shareInstance] selector:@selector(firstScreenDidFinished:) name:BMFirstScreenDidFinish object:nil];
}

+ (NSString *)showTime:(NSTimeInterval) msglastTime showDetail:(BOOL)showDetail {
    //今天的时间
    NSDate * nowDate = [NSDate date];
    NSDate * msgDate = [NSDate dateWithTimeIntervalSince1970:msglastTime];
    NSString *result = nil;
    NSCalendarUnit components = (NSCalendarUnit)(NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay|NSCalendarUnitWeekday|NSCalendarUnitHour | NSCalendarUnitMinute);
    NSDateComponents *nowDateComponents = [[NSCalendar currentCalendar] components:components fromDate:nowDate];
    NSDateComponents *msgDateComponents = [[NSCalendar currentCalendar] components:components fromDate:msgDate];
    NSDate *today = [[NSDate alloc] init];
    NSTimeInterval secondsPerDay = 24 * 60 * 60;
    NSDate *yesterday = [today dateByAddingTimeInterval: -secondsPerDay];
    NSDateComponents *yesterdayDateComponents = [[NSCalendar currentCalendar] components:components fromDate:yesterday];
    
    NSInteger hour = msgDateComponents.hour;
    result = @"";
    
    if (nowDateComponents.year == msgDateComponents.year
        && nowDateComponents.month == msgDateComponents.month
        && nowDateComponents.day == msgDateComponents.day) {
        //今天,hh:mm
        result = [[NSString alloc] initWithFormat:@"%@ %ld:%02d",result,(long)hour,(int)msgDateComponents.minute];
    } else if (yesterdayDateComponents.year == msgDateComponents.year
               && yesterdayDateComponents.month == msgDateComponents.month
               && yesterdayDateComponents.day == msgDateComponents.day) {
        //昨天，昨天 hh:mm
        result = showDetail?  [[NSString alloc] initWithFormat:@"昨天%@ %ld:%02d",result,(long)hour,(int)msgDateComponents.minute] : @"昨天";
    } else if(nowDateComponents.year == msgDateComponents.year) {
        //今年，MM/dd hh:mm
        result = [NSString stringWithFormat:@"%02d/%02d %ld:%02d", (int)msgDateComponents.month, (int)msgDateComponents.day, (long)msgDateComponents.hour, (int)msgDateComponents.minute];
    } else if(nowDateComponents.year != msgDateComponents.year) {
        //跨年， YY/MM/dd hh:mm
        NSString *day = [NSString stringWithFormat:@"%02d/%02d/%02d", (int)(msgDateComponents.year%100), (int)msgDateComponents.month, (int)msgDateComponents.day];
        result = showDetail ? [day stringByAppendingFormat:@" %@ %ld:%02d",result, (long)hour, (int)msgDateComponents.minute] : day;
    }
    return result;
}
@end
