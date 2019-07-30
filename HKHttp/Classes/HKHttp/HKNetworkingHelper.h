//
//  HKNetworkingHelper.h
//  Pods
//
//  Created by inory on 2019/7/30.
//

#ifndef HKNetworkingHelper_h
#define HKNetworkingHelper_h


@class HKHttpConfigModel;

/**
 *  网络状态
 */
typedef NS_ENUM(NSInteger, HKNetworkStatus) {
    /**
     *  未知网络
     */
    HKNetworkStatusUnknown             = 1 << 0,
    /**
     *  无法连接
     */
    HKNetworkStatusNotReachable        = 1 << 1,
    /**
     *  WWAN网络
     */
    HKNetworkStatusReachableViaWWAN    = 1 << 2,
    /**
     *  WiFi网络
     */
    HKNetworkStatusReachableViaWiFi    = 1 << 3
};

typedef HKHttpConfigModel *(^HKConfigToEmpty)(void);
typedef HKHttpConfigModel *(^HKConfigToBool)(BOOL value);
typedef HKHttpConfigModel *(^HKConfigToDic)(NSDictionary *value);
typedef HKHttpConfigModel *(^HKConfigToTime)(NSTimeInterval value);
typedef HKHttpConfigModel *(^HKConfigToData)(NSData *value);
typedef HKHttpConfigModel *(^HKConfigToArray)(NSArray *value);
typedef HKHttpConfigModel *(^HKConfigToString)(NSString *value);
typedef HKHttpConfigModel *(^HKConfigToEmptyBlock)(void(^block)(void));
typedef HKHttpConfigModel *(^HKConfigToBoolBlock)(void(^block)(BOOL is));
typedef HKHttpConfigModel *(^HKConfigToDicBlock)(void(^block)(NSDictionary *value));
typedef HKHttpConfigModel *(^HKConfigToDataBlock)(void(^block)(NSData *value));
typedef HKHttpConfigModel *(^HKConfigToArrayBlock)(void(^block)(NSArray *value));
typedef HKHttpConfigModel *(^HKConfigToStringBlock)(void(^block)(NSString *value));
typedef HKHttpConfigModel *(^HKConfigToObjectBlock)(void(^block)(id response));
typedef HKHttpConfigModel *(^HKConfigToDownloadBlock)(void(^block)(NSString *filePath,BOOL isUnzip));
typedef HKHttpConfigModel *(^HKConfigToProgressBlock)(void(^block)(int64_t bytesRead,
                                                                   int64_t totalBytes));

#endif /* HKNetworkingHelper_h */
