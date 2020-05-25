//
//  RYDiskCache.m
//  RYHttpMangeDemo
//
//  Created by LiveiOS on 2019/1/6.
//  Copyright © 2019 LiveiOS. All rights reserved.
//

//#import "RYNetworkingHeader.h"
#import "HKDiskCache.h"
#import "HKCacheManager.h"


@implementation HKDiskCache
- (instancetype)sharedInstance{
    
    return [[self class] sharedInstance];
}

+ (instancetype)sharedInstance{
    
    static dispatch_once_t once;
    
    static id __singleton__;
    
    dispatch_once( &once, ^{
        
        __singleton__ = [[self alloc] init];
        
    } );
    
    return __singleton__;
}


+(NSString *)getDocumentPath{
    
    NSArray *filePaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    return [filePaths objectAtIndex:0];
    
}

+(void)saveLoadData:(id)data filename:(NSString *)filename{
    
    NSString *directory=[self getDocumentPath];
    if ([HKNullUtils isNull:data])return;
    if ([HKNullUtils isNull:directory])return;
    if ([HKNullUtils isNull:filename])return;
    
    NSString *filePath = [directory stringByAppendingPathComponent:filename];
    
    [[NSFileManager defaultManager] createFileAtPath:filePath contents:data attributes:nil];
}


+ (void)writeData:(id)data
            toDir:(NSString *)directory
         filename:(NSString *)filename{
    if ([HKNullUtils isNull:data])return;
    if ([HKNullUtils isNull:directory])return;
    if ([HKNullUtils isNull:filename])return;
    
    if ([self createFileDirectories:directory]){
        NSString *filePath = [directory stringByAppendingPathComponent:filename];
        NSFileManager *fileManager = [NSFileManager defaultManager];
        
//        NSError * error;

//        BOOL isSuccess = [data writeToFile:filePath options:NSDataWritingAtomic error:&error];
        
        BOOL isSuccess = [fileManager createFileAtPath:filePath contents:data attributes:nil];
//        [fileManager createDirectoryAtPath:filePath withIntermediateDirectories:YES attributes:nil error:&error];
        
//        if (error){
//            WLog(@"createDirectory error is %@",error.localizedDescription);
//#if __has_include("Bugly/Bugly.h")
//            [Bugly reportError:error];
//#endif
//
//        }
        if (isSuccess){
//            WLog(@"写入成功");
        }else{
//            WLog(@"写入失败");
        }
    }
}
#pragma mark - 判断文件夹是否存在，不存在则创建


// MARK: 创建文件路径
+(BOOL)createFileDirectories:(NSString *)folderPath{
    
    BOOL ret = YES;
    BOOL isExist = [self fileIsExistOfPath:folderPath];
    if (!isExist) {
        NSError *error;
         ret = [[NSFileManager defaultManager] createDirectoryAtPath:folderPath withIntermediateDirectories:YES attributes:nil error:&error];
//        if (!isSuccess) {
//            ret = NO;
//            WLog(@"Create Audio Directory Failed.--->%@",[error localizedDescription]);
//#if __has_include("Bugly/Bugly.h")
//            [Bugly reportError:error];
//#endif
//
//        }
    }
    return ret;
    
}

// MARK: 判断文件是否创建

//判断文件是否存在于某个路径中
+ (BOOL)fileIsExistOfPath:(NSString *)filePath{
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isDir = FALSE;
    
    BOOL isDirExist = [fileManager fileExistsAtPath:filePath isDirectory:&isDir];

    
    return isDirExist&&isDir;
}



+ (id)readDataFromDir:(NSString *)directory
             filename:(NSString *)filename {
    
    if ([HKNullUtils isNull:directory])return [NSData data];
    if ([HKNullUtils isNull:filename])return [NSData data];
    
    NSData *data = nil;
    
    NSString *filePath = [directory stringByAppendingPathComponent:filename];
    
    data = [[NSFileManager defaultManager] contentsAtPath:filePath];
    
    return data;
}

+ (NSUInteger)dataSizeInDir:(NSString *)directory {
    
    if (!directory) {
        return 0;
    }
    
    BOOL isDir = NO;
    NSUInteger total = 0;
    if ([[NSFileManager defaultManager] fileExistsAtPath:directory isDirectory:&isDir]) {
        if (isDir) {
            NSError *error = nil;
            NSArray *array = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:directory error:&error];
            if (!error) {
                for (NSString *subFile in array) {
                    NSString *filePath = [directory stringByAppendingPathComponent:subFile];
                    NSDictionary *attributes = [[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:&error];
                    
                    if (!error) {
                        total += [attributes[NSFileSize] unsignedIntegerValue];
                    }
                }
            }
        }
    }
    
    return total;
}

+ (void)clearDataIinDir:(NSString *)directory {
    if (directory) {
        if ([[NSFileManager defaultManager] fileExistsAtPath:directory isDirectory:nil]) {
            NSError *error = nil;
            [[NSFileManager defaultManager] removeItemAtPath:directory error:&error];
            if (error) {
//                WLog(@"清理缓存是出现错误：%@",error.localizedDescription);
            }
        }
    }
}

+ (void)deleteCache:(NSString *)fileUrl {
    if (fileUrl) {
        if ([[NSFileManager defaultManager] fileExistsAtPath:fileUrl]) {
            NSError *error = nil;
            [[NSFileManager defaultManager] removeItemAtPath:fileUrl error:&error];
            if (error) {
//                WLog(@"删除文件出现错误出现错误：%@",error.localizedDescription);
            }
        }else {
//            WLog(@"不存在文件");
        }
    }
}


@end
