//
//  Target_WYPush.h
//  eroswyqy
//
//  Created by lh on 2020/12/17.
//

#import <Foundation/Foundation.h>


@interface Target_WYPush : NSObject

- (void)Action_setIsLaunchedByNotification:(NSNumber *)val;
- (void)Action_addPushNotification:(NSDictionary *)notificationPayload;
- (void)Action_receiveRemoteNotification:(NSDictionary *)info;
- (void)Action_performFetchWithCompletionHandler:(NSDictionary *)info;

@end
