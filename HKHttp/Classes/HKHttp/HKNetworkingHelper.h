//
//  HKNetworkingHelper.h
//  Pods
//
//  Created by inory on 2019/7/30.
//

#ifndef HKNetworkingHelper_h

#define HKNetworkingHelper_h

#import <Foundation/Foundation.h>

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
typedef HKHttpConfigModel *(^HKConfigToObjectBlock)(void(^block)(id response));
typedef HKHttpConfigModel *(^HKConfigToFloatBlock)(void(^block)(float progress));
typedef HKHttpConfigModel *(^HKConfigToDataBlock)(void(^block)(NSData *value));
typedef HKHttpConfigModel *(^HKConfigToArrayBlock)(void(^block)(NSArray *value));
typedef HKHttpConfigModel *(^HKConfigToStringBlock)(void(^block)(NSString *value));
typedef HKHttpConfigModel *(^HKConfigToDicBlock)(void(^block)(NSDictionary *value));
typedef HKHttpConfigModel *(^HKConfigToDownloadBlock)(void(^block)(NSString *filePath,BOOL isUnzip));
typedef HKHttpConfigModel *(^HKConfigToProgressBlock)(void(^block)(int64_t bytesRead,
                                                                   int64_t totalBytes));






#define metamacro_concat_(A, B) A ## B

#define metamacro_concat(A, B) \
    metamacro_concat_(A, B)

#define metamacro_foreach_iter(INDEX, MACRO, ARG) MACRO(INDEX, ARG)

#define metamacro_at(N, ...) \
    metamacro_concat(metamacro_at, N)(__VA_ARGS__)

#define metamacro_argcount(...) \
    metamacro_at(20, __VA_ARGS__, 20, 19, 18, 17, 16, 15, 14, 13, 12, 11, 10, 9, 8, 7, 6, 5, 4, 3, 2, 1)


#define metamacro_foreach_cxt(MACRO, SEP, CONTEXT, ...) \
    metamacro_concat(metamacro_foreach_cxt, metamacro_argcount(__VA_ARGS__))(MACRO, SEP, CONTEXT, __VA_ARGS__)

#define metamacro_foreach(MACRO, SEP, ...) \
    metamacro_foreach_cxt(metamacro_foreach_iter, SEP, MACRO, __VA_ARGS__)

#define hk_weakify_(INDEX, CONTEXT, VAR) \
    CONTEXT __typeof__(VAR) metamacro_concat(VAR, _weak_) = (VAR);


#define hk_strongify_(INDEX, VAR) \
    __strong __typeof__(VAR) VAR = metamacro_concat(VAR, _weak_);

#if DEBUG
#define hk_keywordify autoreleasepool {}
#else
#define hk_keywordify try {} @catch (...) {}
#endif

#define hk_weakify(...) \
    hk_keywordify \
    metamacro_foreach_cxt(hk_weakify_,, __weak, __VA_ARGS__)

#define hk_strongify(...) \
    hk_keywordify \
    _Pragma("clang diagnostic push") \
    _Pragma("clang diagnostic ignored \"-Wshadow\"") \
    metamacro_foreach(hk_strongify_,, __VA_ARGS__) \
    _Pragma("clang diagnostic pop")




#endif /* HKNetworkingHelper_h */


