//
//  RYMemoryCache.m
//  RYHttpMangeDemo
//
//  Created by LiveiOS on 2019/1/6.
//  Copyright © 2019 LiveiOS. All rights reserved.
//

#import "HKMemoryCache.h"
#import "HKCacheManager.h"
#import <UIKit/UIKit.h>

static NSCache *shareCache;

@implementation HKMemoryCache
+ (NSCache *)shareCache {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (shareCache == nil) shareCache = [[NSCache alloc] init];
    });
    
    //当收到内存警报时，清空内存缓存
    [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidReceiveMemoryWarningNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
        [shareCache removeAllObjects];
    }];
    
    return shareCache;
}

+ (void)writeData:(id)data forKey:(NSString *)key {
    if ([HKNullUtils isNull:data])return;
    if ([HKNullUtils isNull:key])return;
    NSCache *cache = [HKMemoryCache shareCache];
    
    [cache setObject:data forKey:key];
    
}

+ (id)readDataWithKey:(NSString *)key {
    if ([HKNullUtils isNull:key])return @"";

    id data = nil;
    
    NSCache *cache = [HKMemoryCache shareCache];
    
    data = [cache objectForKey:key];
    
    
    return data;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidReceiveMemoryWarningNotification object:nil];
}

@end
