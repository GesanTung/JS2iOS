//
//  SDWebImageManager+NoWifi.m
//  SCNews
//
//  Created by 董俊峰 on 15/12/3.
//  Copyright © 2015年 TRS. All rights reserved.
//

#import "SDWebImageManager+NoWifi.h"

@implementation SDWebImageManager (NoWifi)


- (void)addObserverWifi{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(networkStateChange) name:kReachabilityChangedNotification object:nil];
    Reachability *httpConn = [Reachability reachabilityForInternetConnection];
    [httpConn startNotifier];
}

- (void)networkStateChange {
    [self checkNetworkState];
}

- (void)checkNetworkState{
    // 1.检测wifi状态
    Reachability *wifi = [Reachability reachabilityForLocalWiFi];
    
    // 2.检测手机是否能上网络(WIFI\3G\2.5G)
    Reachability *conn = [Reachability reachabilityForInternetConnection];
    
    // 3.判断网络状态
    if ([wifi currentReachabilityStatus] == ReachableViaWiFi) { // 有wifi
        NSLog(@"有wifi");
        self.isNoWifiOpen = NO;
    } else if ([conn currentReachabilityStatus] == ReachableViaWWAN) { // 没有使用wifi, 使用手机自带网络进行上网
        self.isNoWifiOpen = YES;
        NSLog(@"使用手机自带网络进行上网");
    } else { // 没有网络
        if ([[StorageService systemValue:SystemTypeIsWifiImage] boolValue]) {
            self.isNoWifiOpen = YES;
        }
        NSLog(@"没有网络");
    }
}

- (BOOL)getSystemTypeIsWifiImage{
    return [[StorageService systemValue:SystemTypeIsWifiImage] boolValue];
}

@end
