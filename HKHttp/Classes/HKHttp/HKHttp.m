//
//  HKHttp.m
//  Pods
//
//  Created by inory on 2019/7/30.
//

#import "HKHttp.h"
#import "AFNetworking.h"
#import "HKHttp+RequestManager.h"
#import "AFNetworkActivityIndicatorManager.h"

static NSString         *defaultDomain;

static NSMutableArray   *requestTasksPool;

static NSDictionary     *headers;

static HKNetworkStatus  networkStatus;

static NSTimeInterval   requestTimeout = 40.f;

#define HK_ERROR_IMFORMATION @"网络出现错误，请检查网络连接"

#define HK_ERROR [NSError errorWithDomain:@"com.HKNetworking.ErrorDomain" code:-999 userInfo:@{ NSLocalizedDescriptionKey:HK_ERROR_IMFORMATION}]



@implementation HKHttp

+ (HKGetConfigModel *)GET{
    HKGetConfigModel *config = [[HKGetConfigModel alloc]init];
    return config;
}

+ (HKPostConfigModel *)POST{
    HKPostConfigModel *config = [[HKPostConfigModel alloc]init];
    return config;
}

+ (HKDownloadConfigModel *)Download{
    HKDownloadConfigModel *config = [[HKDownloadConfigModel alloc]init];
    return config;
}
+ (void)hk_setDefaultDomain:(NSString *)domain{
    defaultDomain = domain;
}

+ (void)cancleAllRequest {
    @synchronized (self) {
        [[self allTasks] enumerateObjectsUsingBlock:^(HKURLSessionTask  *_Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj isKindOfClass:[HKURLSessionTask class]]) {
                [obj cancel];
            }
        }];
        [[self allTasks] removeAllObjects];
    }
}

+ (void)cancelRequestWithURL:(NSString *)url {
    if (!url) return;
    @synchronized (self) {
        [[self allTasks] enumerateObjectsUsingBlock:^(HKURLSessionTask * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj isKindOfClass:[HKURLSessionTask class]]) {
                if ([obj.currentRequest.URL.absoluteString hasSuffix:url]) {
                    [obj cancel];
                    *stop = YES;
                }
            }
        }];
    }
}

+ (NSMutableArray *)allTasks {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (requestTasksPool == nil) requestTasksPool = [NSMutableArray array];
    });
    
    return requestTasksPool;
}

+ (NSArray *)currentRunningTasks {
    return [[self allTasks] copy];
}

@end
@interface HKHttpConfigModel()

@property (nonatomic , assign) BOOL  isRefresh;
@property (nonatomic , assign) BOOL  isCache;
@property (nonatomic , strong) NSDictionary   * params ;
@property (nonatomic , strong) NSDictionary   * header ;
@property (nonatomic , assign) NSTimeInterval   timeout;
@property (nonatomic , copy )  NSString       * baseUrl;
@property (nonatomic , copy )  NSString       * domain;
@property (nonatomic , copy ) void (^ResponseSuccessBlock)(id response);
@property (nonatomic , copy ) void (^ResponseFailBlock)(NSString *errorString);
@property (nonatomic , copy ) void (^ResponseErrorBlock)(NSError *error);
@property (nonatomic , copy ) void (^LoadingProgressBlock)(int64_t bytesRead,int64_t totalBytes);
@property (nonatomic , copy ) void (^HttpStartRequst)(void);

@end

@implementation HKHttpConfigModel


-(instancetype)init{
    if (self = [super init]){
        __weak typeof(self) weakSelf = self;
        self.HttpStartRequst = ^{
            __strong typeof(weakSelf) self = weakSelf;
            if (!self) return;
            
            [self startRequest];
        };
    }
    return self;
}

- (HKConfigToBool)hkRefresh{
    return ^(BOOL is){
        self.isRefresh = is;
        return self;
    };
}

- (HKConfigToBool)hkCache{
    return ^(BOOL is){
        self.isCache = is;
        return self;
    };
}

- (HKConfigToDic)hkParams{
    return ^(NSDictionary *dic){
        self.params = dic;
        return self;
    };
}

- (HKConfigToDic)hkHeader{
    return ^(NSDictionary *dic){
        self.header = dic;
        return self;
    };
}

- (HKConfigToTime)hkTimeOut{
    return ^(NSTimeInterval time){
        requestTimeout = time;
        return self;
    };
}

- (HKConfigToString)hkBaseUrl{
    return ^(NSString *string){
        self.baseUrl = string;
        return self;
    };
}
- (HKConfigToObjectBlock)hkResponseSuccessBlock{
    
    __weak typeof(self) weakSelf = self;
    
    return ^(void(^block)(NSDictionary *respone)){
        
        if (weakSelf) if(block) weakSelf.ResponseSuccessBlock = block;
        
        return weakSelf;
    };
}

- (HKConfigToStringBlock)hkResponseFailBlock{
    
    __weak typeof(self) weakSelf = self;
    
    return ^(void(^block)(NSString *errorString)){
        
        if (weakSelf) if (block) weakSelf.ResponseFailBlock = block;
        
        return weakSelf;
    };
}

- (HKConfigToObjectBlock)hkResponseErrorBlock{
    __weak typeof(self) weakSelf = self;
    return ^(void(^block)(NSError *error)){
        if (weakSelf)if (block)weakSelf.ResponseErrorBlock = block;
        return weakSelf;
    };
}

- (HKConfigToProgressBlock)hkLoadingProgressBlock{
    
    __weak typeof(self) weakSelf = self;
    
    return ^(void(^block)(int64_t bytesRead,int64_t totalBytes)){
        
        if (weakSelf) if (block) weakSelf.LoadingProgressBlock = block;
        
        return weakSelf;
    };
}

- (HKConfigToEmpty)hkStartRequest{
    
    __weak typeof(self) weakSelf = self;
    
    return ^{
        
        if (weakSelf) weakSelf.HttpStartRequst();
        
        return weakSelf;
    };
}


+ (AFHTTPSessionManager *)sharedInstance{
    static dispatch_once_t once;
    static AFHTTPSessionManager * manager;
    dispatch_once( &once, ^{
        [AFNetworkActivityIndicatorManager sharedManager].enabled = YES;
        
        manager = [AFHTTPSessionManager manager];
        
        //默认解析模式
        manager.requestSerializer = [AFHTTPRequestSerializer serializer];
        
        manager.requestSerializer.stringEncoding = NSUTF8StringEncoding;
        
        manager.requestSerializer.timeoutInterval = requestTimeout;
        
        [manager.requestSerializer setValue:@"gzip" forHTTPHeaderField:@"Content-Encoding"];
        [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
        [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        manager.responseSerializer = [AFHTTPResponseSerializer serializer];
        
        
        //配置响应序列化
        manager.responseSerializer.acceptableContentTypes = [NSSet setWithArray:@[@"application/json",
                                                                                  @"text/html",
                                                                                  @"text/json",
                                                                                  @"text/plain",
                                                                                  @"text/javascript",
                                                                                  @"text/xml",
                                                                                  @"image/*",
                                                                                  @"application/octet-stream",
                                                                                  @"application/zip"]];
    });
    
    //每次网络请求的时候，检查此时磁盘中的缓存大小，阈值默认是40MB，如果超过阈值，则清理LRU缓存,同时也会清理过期缓存，缓存默认SSL是7天，磁盘缓存的大小和SSL的设置可以通过该方法[RYCacheManager shareManager] setCacheTime: diskCapacity:]设置
    //    [[RYCacheManager shareManager] clearLRUCache];
    return manager;
}

// MARK: 检查网络状态
+ (void)checkNetworkStatus {
    AFNetworkReachabilityManager *manager = [AFNetworkReachabilityManager sharedManager];
    
    [manager startMonitoring];
    
    [manager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        
        switch (status) {
                case AFNetworkReachabilityStatusNotReachable:
                networkStatus = HKNetworkStatusNotReachable;
                break;
                case AFNetworkReachabilityStatusUnknown:
                networkStatus = HKNetworkStatusUnknown;
                break;
                case AFNetworkReachabilityStatusReachableViaWWAN:
                networkStatus = HKNetworkStatusReachableViaWWAN;
                break;
                case AFNetworkReachabilityStatusReachableViaWiFi:
                networkStatus = HKNetworkStatusReachableViaWiFi;
                break;
            default:
                networkStatus = HKNetworkStatusUnknown;
                break;
        }
        
    }];
}

-(void)startRequest{
    
    [HKHttpConfigModel checkNetworkStatus];
    
    if (networkStatus == HKNetworkStatusNotReachable) {
        if (self.ResponseFailBlock){
            self.ResponseFailBlock(HK_ERROR_IMFORMATION);
        }
        if (self.ResponseErrorBlock){
            self.ResponseErrorBlock(HK_ERROR);
        }
        return ;
    }
}


@end

@implementation HKGetConfigModel

-(void)startRequest{
    AFHTTPSessionManager *manager = [HKHttpConfigModel sharedInstance];
    
    __block HKURLSessionTask *session = nil;
    
    session=[manager GET:self.baseUrl parameters:self.params progress:^(NSProgress * _Nonnull downloadProgress) {
        if (self.LoadingProgressBlock)
        self.LoadingProgressBlock(downloadProgress.completedUnitCount,  downloadProgress.totalUnitCount);
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (self.ResponseSuccessBlock)self.ResponseSuccessBlock(responseObject);
        [[HKHttp allTasks] removeObject:session];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if ([error code] == NSURLErrorCancelled){
            return ;
        }
        if (self.ResponseErrorBlock)self.ResponseErrorBlock(error);
        if (self.ResponseFailBlock)self.ResponseFailBlock(error.localizedDescription);
        [[HKHttp allTasks] removeObject:session];
    }];
    if ([HKHttp hkHaveSameRequestInTasksPool:session] && !self.isRefresh) {
        [session cancel];
        return;
    }else {
        HKURLSessionTask *oldTask = [HKHttp hkCancleSameRequestInTasksPool:session];
        if (oldTask) [[HKHttp allTasks] removeObject:oldTask];
        if (session) [[HKHttp allTasks] addObject:session];
        [session resume];
        return ;
    }
    
}

@end

@implementation HKPostConfigModel

-(void)startRequest{
    
    AFHTTPSessionManager *manager = [HKHttpConfigModel sharedInstance];
    
    __block HKURLSessionTask *session = nil;
    
    session = [manager POST:self.baseUrl parameters:self.params progress:^(NSProgress * _Nonnull uploadProgress) {
        if (self.LoadingProgressBlock)
        self.LoadingProgressBlock(uploadProgress.completedUnitCount,  uploadProgress.totalUnitCount);
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        if (self.ResponseSuccessBlock)self.ResponseSuccessBlock(responseObject);
        [[HKHttp allTasks] removeObject:session];
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        if ([error code] == NSURLErrorCancelled){
            return ;
        }
        if (self.ResponseErrorBlock)self.ResponseErrorBlock(error);
        if (self.ResponseFailBlock)self.ResponseFailBlock(error.localizedDescription);
        [[HKHttp allTasks] removeObject:session];
        
    }];
    
    if ([HKHttp hkHaveSameRequestInTasksPool:session] && !self.isRefresh) {
        [session cancel];
        return;
    }else {
        HKURLSessionTask *oldTask = [HKHttp hkCancleSameRequestInTasksPool:session];
        if (oldTask) [[HKHttp allTasks] removeObject:oldTask];
        if (session) [[HKHttp allTasks] addObject:session];
        [session resume];
        return ;
    }
}
@end

@interface HKUploadConfigModel ()

@property (nonatomic , copy ) NSString *fileType;
@property (nonatomic , copy ) NSString *mimeType;
@property (nonatomic , copy ) NSString *fileName;
@property (nonatomic , strong) NSData * data ;

@end

@implementation HKUploadConfigModel



-(void)startRequest{
    
    AFHTTPSessionManager *manager = [HKHttpConfigModel sharedInstance];
    __block HKURLSessionTask *session = nil;
    
    session = [manager POST:self.baseUrl
                 parameters:nil
  constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
      NSString *fileName = nil;
      
      NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
      formatter.dateFormat = @"yyyyMMddHHmmss";
      
      NSString *day = [formatter stringFromDate:[NSDate date]];
      
      fileName = [NSString stringWithFormat:@"%@.%@",day,self.fileType];
      
      [formData appendPartWithFileData:self.data name:self.fileName fileName:fileName mimeType:self.mimeType];
      
  } progress:^(NSProgress * _Nonnull uploadProgress) {
      if (self.LoadingProgressBlock) self.LoadingProgressBlock (uploadProgress.completedUnitCount,uploadProgress.totalUnitCount);
      
  } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
      if (self.ResponseSuccessBlock) self.ResponseSuccessBlock(responseObject);
      [[HKHttp allTasks] removeObject:session];
      
  } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
      if (self.ResponseErrorBlock)self.ResponseErrorBlock(error);
      if (self.ResponseFailBlock)self.ResponseFailBlock(error.localizedDescription);
      [[HKHttp allTasks] removeObject:session];
  }];
    
    [session resume];
    
    if (session) [[HKHttp allTasks] addObject:session];
    
}

- (HKConfigToData)HKUploadData{
    return ^(NSData * data){
        self.data = data;
        return self;
    };
}

- (HKConfigToString)HKFileName{
    return ^(NSString *string){
        self.fileName = string;
        return self;
    };
}

- (HKConfigToString)HKFileType{
    return ^(NSString *string){
        self.fileType = string;
        return self;
    };
}

- (HKConfigToString)HKMimeType{
    return ^(NSString *string){
        self.mimeType = string;
        return self;
    };
}


@end

@interface HKDownloadConfigModel ()

@property (nonatomic , copy ) void (^DownloadSuccessBlock)(NSString *filePath,BOOL isUnzip);

@end

@implementation HKDownloadConfigModel
-(void)startRequest{
    
}
@end
