//
//  HKHttpManager.h
//  Pods
//
//  Created by inory on 2019/7/30.
//

#import <Foundation/Foundation.h>
#import "HKNetworkingHelper.h"


@interface HKHttpConfigModel : NSObject
/** 请求参数 */
@property (nonatomic , copy , readonly ) HKConfigToDic hkParams;
/** 请求header */
@property (nonatomic , copy , readonly ) HKConfigToDic hkHeader;
/** 请求接口地址 如何没有设置「hk_setDefaultDomain」则默认hkBaseUrl为完整的接口地址*/
@property (nonatomic , copy , readonly ) HKConfigToString hkBaseUrl;
/** 是否刷新请求(遇到重复请求，若为YES，则会取消旧的请求，用新的请求，若为NO，则忽略新请求，用旧请求) */
@property (nonatomic , copy , readonly ) HKConfigToBool hkRefresh;
/** 是否缓存 */
@property (nonatomic , copy , readonly ) HKConfigToBool hkCache;
/** 超时时间 */
@property (nonatomic , copy , readonly ) HKConfigToTime hkTimeOut;
/** 加载进度 */
@property (nonatomic , copy , readonly ) HKConfigToProgressBlock hkLoadingProgressBlock;
/** 成功回调 */
@property (nonatomic , copy , readonly ) HKConfigToObjectBlock hkResponseSuccessBlock;
/** 失败回调 <string>*/
@property (nonatomic , copy , readonly ) HKConfigToStringBlock hkResponseFailBlock;
/** 失败回调 <error>*/
@property (nonatomic , copy , readonly ) HKConfigToObjectBlock hkResponseErrorBlock;
/** 开始请求 -> 格式: .HKStartRequest() */
@property (nonatomic , copy , readonly ) HKConfigToEmpty hkStartRequest;

/**
 *  初始化网络配置
 *
 */
-(void)startRequest;

@end


@interface HKGetConfigModel : HKHttpConfigModel @end

@interface HKPostConfigModel : HKHttpConfigModel @end

@interface HKUploadConfigModel : HKHttpConfigModel
/** 上传文件类型 */
@property (nonatomic , copy , readonly ) HKConfigToString hkFileType;
/** 上传文件mimeType */
@property (nonatomic , copy , readonly ) HKConfigToString hkMimeType;
/** 上传文件服务器文件夹名 */
@property (nonatomic , copy , readonly ) HKConfigToString hkFileName;
/** 上传的文件Data */
@property (nonatomic , copy , readonly ) HKConfigToData hkUploadData;

@end

@interface HKDownloadConfigModel : HKHttpConfigModel
/** 自定义存储文件夹名称 */
@property (nonatomic , copy , readonly ) HKConfigToString hkCacheFileName;
/** 是否解压 */
@property (nonatomic , copy , readonly ) HKConfigToBool hkisUnzip;
@end


@interface HKHttp : NSObject
/** GET 请求 */
+ (HKGetConfigModel *)GET;
/** POST 请求 */
+ (HKPostConfigModel *)POST;
/** 下载文件 */
+ (HKDownloadConfigModel *)Download;

/**
 *  设置网络请求域名
 *
 */
+ (void)hk_setDefaultDomain:(NSString *)domain;
/**
 *  正在运行的网络任务
 *
 *  @return task
 */
+(NSArray *)currentRunningTasks;

@end
