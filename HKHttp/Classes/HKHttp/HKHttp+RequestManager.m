//
//  HKHttp+RequestManager.m
//  Pods
//
//  Created by inory on 2019/7/30.
//

#import "HKHttp+RequestManager.h"

@interface NSURLRequest (decide)

//判断是否是同一个请求（依据是请求url和参数是否相同）
- (BOOL)isTheSameRequest:(NSURLRequest *)request;
/**
 * 判断是否是同一个请求
 * 依据是请求url是否相同
 */
- (BOOL)isTheSameUrlRequest:(NSURLRequest *)request;
@end
@implementation NSURLRequest (decide)

- (BOOL)isTheSameRequest:(NSURLRequest *)request {
    if ([self.HTTPMethod isEqualToString:request.HTTPMethod]) {
        if ([self.URL.absoluteString isEqualToString:request.URL.absoluteString]) {
            if ([self.HTTPMethod isEqualToString:@"GET"]||[self.HTTPBody isEqualToData:request.HTTPBody]) {
                return YES;
            }
        }
    }
    return NO;
}

- (BOOL)isTheSameUrlRequest:(NSURLRequest *)request {
    if ([self.HTTPMethod isEqualToString:request.HTTPMethod]) {
        if ([self.URL.absoluteString isEqualToString:request.URL.absoluteString]) {
            return YES;
        }
    }
    return NO;
}
@end

@implementation HKHttp (RequestManager)

+ (BOOL)hkHaveSameRequestInTasksPool:(HKURLSessionTask *)task {
    __block BOOL isSame = NO;
    [[self currentRunningTasks] enumerateObjectsUsingBlock:^(HKURLSessionTask *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([task.originalRequest isTheSameRequest:obj.originalRequest]) {
            isSame  = YES;
            *stop = YES;
        }
    }];
    return isSame;
}

+ (HKURLSessionTask *)hkCancleSameRequestInTasksPool:(HKURLSessionTask *)task {
    __block HKURLSessionTask *oldTask = nil;
    
    [[self currentRunningTasks] enumerateObjectsUsingBlock:^(HKURLSessionTask *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([task.originalRequest isTheSameRequest:obj.originalRequest]) {
            if (obj.state == NSURLSessionTaskStateRunning) {
                [obj cancel];
                oldTask = obj;
            }
            *stop = YES;
        }
    }];
    
    return oldTask;
}

// MARK: 取消URL相同的旧的请求
+ (HKURLSessionTask *)hkCancleSameUrlRequestInTasksPool:(HKURLSessionTask *)task {
    __block HKURLSessionTask *oldTask = nil;
    [[self currentRunningTasks] enumerateObjectsUsingBlock:^(HKURLSessionTask *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([task.originalRequest isTheSameUrlRequest:obj.originalRequest]) {
            if (obj.state == NSURLSessionTaskStateRunning) {
                [obj cancel];
                oldTask = obj;
            }
            *stop = YES;
        }
    }];
    return oldTask;
}
@end
