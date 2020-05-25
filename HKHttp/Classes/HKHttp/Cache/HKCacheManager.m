//
//  RYCacheManager.m
//  RYHttpMangeDemo
//
//  Created by LiveiOS on 2019/1/6.
//  Copyright © 2019 LiveiOS. All rights reserved.
//

#import "HKCacheManager.h"
#import "HKMemoryCache.h"
#import "HKDiskCache.h"
#import "HKLRUManager.h"
#import <CommonCrypto/CommonDigest.h>


static NSString *const cacheDirKey = @"cacheDirKey";

static NSString *const downloadDirKey = @"downloadDirKey";

static NSUInteger diskCapacity = 40 * 1024 * 1024;

static NSTimeInterval cacheTime = 7 * 24 * 60 * 60;


@implementation HKCacheManager



+ (HKCacheManager *)shareManager {
    static HKCacheManager *_RYCacheManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _RYCacheManager = [[HKCacheManager alloc] init];
    });
    return _RYCacheManager;
}

- (void)setCacheTime:(NSTimeInterval)time diskCapacity:(NSUInteger)capacity {
    diskCapacity = capacity;
    cacheTime = time;
}

- (void)cacheResponseObject:(id)responseObject
                 requestUrl:(NSString *)requestUrl
                     params:(NSDictionary *)params {

    if ([HKNullUtils isNull:responseObject])return;
    if ([HKNullUtils isNull:requestUrl])return;
    if (!params) params = @{};
    NSString *originString = [NSString stringWithFormat:@"%@%@",requestUrl,params];
    NSString *hash = [self md5:originString];
    
    NSData *data = nil;
    NSError *error = nil;
    if ([responseObject isKindOfClass:[NSData class]]) {
        data = responseObject;
    }else if ([responseObject isKindOfClass:[NSDictionary class]]){
        data = [NSJSONSerialization dataWithJSONObject:responseObject options:NSJSONWritingPrettyPrinted error:&error];
    }
    
    if (error == nil) {
        //缓存到内存中
        [HKMemoryCache writeData:responseObject forKey:hash];
        
        //缓存到磁盘中
     
        [HKDiskCache saveLoadData:data filename:hash];        
        [[HKLRUManager shareManager] addFileNode:hash];
    }
    
}

- (id)getCacheResponseObjectWithRequestUrl:(NSString *)requestUrl
                                    params:(NSDictionary *)params {

    id cacheData = nil;
    
    if (!params) params = @{};
    NSString *originString = [NSString stringWithFormat:@"%@%@",requestUrl,params];
    NSString *hash = [self md5:originString];
    
    //先从内存中查找
    cacheData = [HKMemoryCache readDataWithKey:hash];
    
    if (!cacheData) {
        NSString *directoryPath = [[NSUserDefaults standardUserDefaults] objectForKey:cacheDirKey];
        
        if (directoryPath) {
            cacheData = [HKDiskCache readDataFromDir:directoryPath filename:hash];
            
            if (cacheData) [[HKLRUManager shareManager] refreshIndexOfFileNode:hash];
        }
    }
    
    return cacheData;
}

- (void)storeDownloadData:(NSData *)data
               requestUrl:(NSString *)requestUrl
            cacheFileName:(NSString *)fileName{
    if ([HKNullUtils isNull:data])return;
    if ([HKNullUtils isNull:requestUrl])return;
    
    NSString *name = nil;
    NSString *type = nil;
    NSArray *strArray = nil;
    
    strArray = [requestUrl componentsSeparatedByString:@"."];
    if (strArray.count > 0) {
        type = strArray[strArray.count - 1];
    }
    
    if (type) {
        name = [NSString stringWithFormat:@"%@.%@",[self md5:requestUrl],type];
    }else {
        name = [NSString stringWithFormat:@"%@",[self md5:requestUrl]];
    }
    
    NSString *directoryPath = [self getDownDirectoryPath];

    if (![HKNullUtils isNull:fileName]){
        directoryPath = [directoryPath stringByAppendingPathComponent:fileName];
    }
    
    [HKDiskCache writeData:data toDir:directoryPath filename:name];
    
}

/** 获取下载文件的存储文件路径 */
-(NSString *)getDownloadPathFromCacheWithRequestUrl:(NSString *)requestUrl{
    
    return [self getDownloadPathWithUrl:requestUrl cacheFileName:nil];
}
-(NSString *)getDownloadPathWithUrl:(NSString *)requestUrl cacheFileName:(NSString *)fileName{
    
    if ([HKNullUtils isNull:requestUrl])return nil;
    
    NSData *data = nil;
    NSString *name = nil;
    NSString *type = nil;
    NSArray *strArray = nil;
    NSString *filePath = nil;
    
    strArray = [requestUrl componentsSeparatedByString:@"."];
    if (strArray.count > 0) {
        type = strArray[strArray.count - 1];
    }
    
    if (type) {
        name = [NSString stringWithFormat:@"%@.%@",[self md5:requestUrl],type];
    }else {
        name = [NSString stringWithFormat:@"%@",[self md5:requestUrl]];
    }
    
    NSString *directoryPath = [self getDownDirectoryPath];
    if (fileName){
        directoryPath = [directoryPath stringByAppendingPathComponent:fileName];
    }
    if (directoryPath) data = [HKDiskCache readDataFromDir:directoryPath filename:name];
    if (data) {
        filePath = [directoryPath stringByAppendingPathComponent:name];
    }
    return filePath;
}


- (NSString *)getCustomDownloadPathFromFileName:(NSString *)fileName{
    
    NSString *filePath = [self getDownDirectoryPath];
    
    if (![HKNullUtils isNull:fileName]){
        filePath = [filePath stringByAppendingPathComponent:fileName];
    }
   return filePath;
}



- (NSURL *)getDownloadDataFromCacheWithRequestUrl:(NSString *)requestUrl {
    
    if ([HKNullUtils isNull:requestUrl])return nil;
   
    NSURL *fileUrl = nil;
    
    fileUrl = [NSURL fileURLWithPath:[self getDownloadPathFromCacheWithRequestUrl:requestUrl]];

    return fileUrl;
}

- (NSUInteger)totalCacheSize {
    NSString *diretoryPath = [self getCacheDiretoryPath];
    
    return [HKDiskCache dataSizeInDir:diretoryPath];
}

- (NSUInteger)totalDownloadDataSize {
    NSString *diretoryPath = [self getDownDirectoryPath];
    
    return [HKDiskCache dataSizeInDir:diretoryPath];
}

- (void)clearDownloadData {
    NSString *diretoryPath = [self getDownDirectoryPath];
    
    [HKDiskCache clearDataIinDir:diretoryPath];
}



- (NSString *)getDownDirectoryPath {
    NSString *diretoryPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    return diretoryPath;
}

- (NSString *)getCacheDiretoryPath {
    NSString *diretoryPath = [[NSUserDefaults standardUserDefaults] objectForKey:cacheDirKey];
    return diretoryPath;
}

- (void)clearTotalCache {
    NSString *directoryPath = [self getCacheDiretoryPath];
    
    [HKDiskCache clearDataIinDir:directoryPath];
}

- (void)clearLRUCache {
    if ([self totalCacheSize] > diskCapacity) {
        NSArray *deleteFiles = [[HKLRUManager shareManager] removeLRUFileNodeWithCacheTime:cacheTime];
        NSString *directoryPath = [[NSUserDefaults standardUserDefaults] objectForKey:cacheDirKey];
        if (directoryPath && deleteFiles.count > 0) {
            [deleteFiles enumerateObjectsUsingBlock:^(NSString *obj, NSUInteger idx, BOOL * _Nonnull stop) {
                NSString *filePath = [directoryPath stringByAppendingPathComponent:obj];
                [HKDiskCache deleteCache:filePath];
            }];
            
        }
    }
}

#pragma mark - 散列值
- (NSString *)md5:(NSString *)string {
    if (string == nil || string.length == 0) {
        return nil;
    }
    
    unsigned char digest[CC_MD5_DIGEST_LENGTH],i;
    
    CC_MD5([string UTF8String],(int)[string lengthOfBytesUsingEncoding:NSUTF8StringEncoding],digest);
    
    NSMutableString *ms = [NSMutableString string];
    
    for (i = 0; i < CC_MD5_DIGEST_LENGTH; i++) {
        [ms appendFormat:@"%02x",(int)(digest[i])];
    }
    
    return [ms copy];
}



@end

@implementation HKNullUtils

+ (NSString *)noNilString:(NSString *)str {
    if ([self isNull:str]) {
        return @"";
    }
    return str;
}

+ (BOOL)isNull:(NSObject *)object {
    if (object == nil ||
        [object isEqual:[NSNull null]] ||
        [object isEqual:@""] ||
        [object isEqual:@" "] ||
        [object isEqual:@"null"] ||
        [object isEqual:@"<null>"] ){
        
        return YES;
    } else {
        return NO;
    }
}

+ (NSString *)noNullString:(id)value {
    if (value && [value isKindOfClass:[NSString class]]) {
        NSString *valueStr = [NSString stringWithFormat:@"%@",value];
        if (valueStr.length) return valueStr;
    }
    return @"";
}


@end
