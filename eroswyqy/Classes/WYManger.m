//
//  WYManger.m
//  eroswyqy
//
//  Created by lh on 2020/12/2.
//

#import "WYManger.h"
#import <QYSDK/QYSDK.h>

@implementation WYManger

+ (instancetype)sharedConfig {
    static WYManger *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[WYManger alloc] init];
    });
    return instance;
}
@end
