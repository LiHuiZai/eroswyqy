//
//  Target_WYPush.m
//  eroswyqy
//
//  Created by lh on 2020/12/17.
//

#import "Target_WYPush.h"
#import "WYPushMessage.h"

@implementation Target_WYPush

- (void)Action_setIsLaunchedByNotification:(NSNumber *)val
{
    [[WYPushMessage shareInstance] setIsLaunchedByNotification:[val boolValue]];
}

- (void)Action_addPushNotification:(NSDictionary *)notificationPayload
{
    [WYPushMessage addPushNotification:notificationPayload];
}

- (void)Action_receiveRemoteNotification:(NSDictionary *)info
{
    [WYPushMessage receiveRemoteNotificationWY:info[@"userInfo"] fetchCompletionHandler:info[@"block"]];
}

- (void)Action_performFetchWithCompletionHandler:(NSDictionary *)info
{
    [WYPushMessage performFetchWithCompletionHandler:info[@"block"]];
}
@end
