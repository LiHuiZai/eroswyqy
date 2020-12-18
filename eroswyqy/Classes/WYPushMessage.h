//
//  WYPushMessage.h
//  eroswyqy
//
//  Created by lh on 2020/12/17.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface WYPushMessage : NSObject
@property (nonatomic, assign) BOOL isLaunchedByNotification;    // 是否点击推送信息进入app

+ (instancetype)shareInstance;
/** 配置推送服务 */
- (void)configPushService;

/** 后台更新 */
+ (void)performFetchWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler;

/** ios10之前 收到push消息回调方法 */
+ (void)receiveRemoteNotificationWY:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler;

/**
 用户点击推送消息打开app，会调用此方法注册一个监听首屏渲染完成的通知，然后再将推送内容 fire 给js
 
 @pushMessage userInfo 消息体
 */
+ (void)addPushNotification:(NSDictionary *)pushMessage;

@end

NS_ASSUME_NONNULL_END
