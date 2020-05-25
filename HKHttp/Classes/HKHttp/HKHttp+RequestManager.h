//
//  HKHttpManager+RequestManager.h
//  Pods
//
//  Created by inory on 2019/7/30.
//

#import "HKHttp.h"

/**
 *  请求任务
 */
typedef NSURLSessionDataTask HKURLSessionTask;

@interface HKHttp (RequestManager)

/**
 *  判断网络请求池中是否有相同的请求
 *
 *  @param task 网络请求任务
 *
 *  @return bool
 */
+ (BOOL)hkHaveSameRequestInTasksPool:(HKURLSessionTask *)task;

/**
 *  如果有旧请求则取消旧请求
 *
 *  @param task 新请求
 *
 *  @return 旧请求
 */
+ (HKURLSessionTask *)hkCancleSameRequestInTasksPool:(HKURLSessionTask *)task;
/**
 *  如果有URL相同的旧请求则取消旧请求
 *
 *  @param task 新请求
 *
 *  @return 旧请求
 */
+ (HKURLSessionTask *)hkCancleSameUrlRequestInTasksPool:(HKURLSessionTask *)task;


@end
