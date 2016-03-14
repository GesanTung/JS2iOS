//
//  SDWebImageManager+NoWifi.h
//  SCNews
//
//  Created by 董俊峰 on 15/12/3.
//  Copyright © 2015年 TRS. All rights reserved.
//

#import "SDWebImageDownloader.h"

@interface SDWebImageManager (NoWifi)

- (void)addObserverWifi;

- (BOOL)getSystemTypeIsWifiImage;

@end
