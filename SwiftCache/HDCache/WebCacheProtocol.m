
//
//  WebCacheProtocol.m
//  BabelAd
//
//  Created by zhangyuhe on 16/3/21.
//  Copyright © 2016年 Babeltime. All rights reserved.
//

#import "WebCacheProtocol.h"



//缓存的请求对象标识符
static NSString * RNCachingURLHeader = @"WebCache";

//缓存信息对应的key
static NSString *const kDataKey = @"data";
static NSString *const kResponseKey = @"response";
static NSString *const kRedirectRequestKey = @"redirectRequest";

#warning - 可在此设置是否使用webview缓存功能 YES使用，反之NO
static const BOOL usecacahe  = YES;


@interface WebCacheProtocol () <NSURLConnectionDataDelegate>

@property (nonatomic,readwrite,strong) NSMutableData   *tempData;
@property (nonatomic,readwrite,strong) NSURLConnection *currentConnection;
@property (nonatomic,readwrite,strong) NSURLResponse   *currentResponse;

@end



@implementation WebCacheProtocol

#warning - canInitWithRequest 返回值yes 代表拦截原有请求，no表示不拦截
#warning 一旦拦截，canonicalRequestForRequest startLoading这些方法就会生效

+ (BOOL)canInitWithRequest:(NSURLRequest *)request
{
    if ([request valueForHTTPHeaderField:RNCachingURLHeader] == nil)
    {
        return YES;
    }
    return NO;
}


+ (NSURLRequest *)canonicalRequestForRequest:(NSURLRequest *)request
{
    return request;
}


- (NSString *)cachePathWithRequest:(NSURLRequest *)aRequest
{
    NSString *cacheFileName = [aRequest.URL.absoluteString  sha1];
    //沙盒缓存目录
    NSString *sanCachePath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
    //在沙盒目录下创建子文件夹 用于存放webview的缓存
//    NSString *  cachePath= [sanCachePath stringByAppendingPathComponent:_WebCacheFolder];
    NSString * path = [sanCachePath stringByAppendingString:@"/webViewCache"];
    NSString * cacheFolderPath = [path stringByAppendingPathComponent:_WebCacheFolder];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isDir;
    if ([fileManager fileExistsAtPath:cacheFolderPath isDirectory:&isDir] && isDir) {
        
    } else {
        [fileManager createDirectoryAtPath:cacheFolderPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return [cacheFolderPath stringByAppendingPathComponent:cacheFileName];
    
}


/**
 *  根据request建立请求连接对象NSURLConnection
 */
- (void)creatConnectForRequest:(NSURLRequest *)request
{
    NSMutableURLRequest *connectionRequest = [request mutableCopyWorkaround];
    //自定义一个请求头用于标识
    [connectionRequest setValue:@"cachedrequest" forHTTPHeaderField:RNCachingURLHeader];
    NSURLConnection *connection = [NSURLConnection connectionWithRequest:connectionRequest delegate:self];
    self.currentConnection  = connection;
    
}

#warning - 先检查canonicalRequestForRequest方法，根据返回值得到确切 NSURLRequest请求对象
#warning 再开始加载（startLoading）
- (void)startLoading
{
    
    
    if (!usecacahe)
    {   //不使用缓存功能,直接网络流量加载
        [self creatConnectForRequest:self.request];
    }
    //使用缓存功能  要添加缓存时间判断 以及删除所有缓存数据
    else
    {   //根据当前的request请求 从本地取对应的缓存信息
        NSString *cacheDataPath = [self cachePathWithRequest:self.request];
        WebCacheInfo *cacheInfo = [NSKeyedUnarchiver unarchiveObjectWithFile:cacheDataPath];
        if (cacheInfo)
        { //有缓存数据
            NSData *cacheData = cacheInfo.cachedData;
            NSURLResponse *cacheResponse = cacheInfo.cachedResponse;
            NSURLRequest *redirectRequest = cacheInfo.cachedRedirectRequest;
            if (redirectRequest) {
                //缓存信息存在重定向请求 就直接加载
                [self.client URLProtocol:self wasRedirectedToRequest:redirectRequest redirectResponse:cacheResponse];
                
            } else {
                //重定向请求不存在，直接取本地缓存数据加载到网页
                [self.client URLProtocol:self didReceiveResponse:cacheResponse cacheStoragePolicy:NSURLCacheStorageNotAllowed];
                [self.client URLProtocol:self didLoadData:cacheData];
                [self.client URLProtocolDidFinishLoading:self];
            }
        }
        else
        {    //没有缓存数据 从网络加载
            [self creatConnectForRequest:self.request];
        }
    }
    
}


#pragma -mark NSURLConnection 代理方法
/**
 *  将要发请求前调用
 *  @param request    具体重定向请求对象
 *  @param response   如果response有值代表有重定向请求
 *
 *  @return 最终确定的请求对象
 */
- (NSURLRequest *)connection:(NSURLConnection *)connection willSendRequest:(NSURLRequest *)request redirectResponse:(NSURLResponse *)response
{
    //willSendRequest将要发请求前，如果response有值代表有重定向请求
    if (response) {
        NSMutableURLRequest *redirectableRequest = [request mutableCopyWorkaround];
        // 添加一个请求头信息 用于标示此次重定向请求
        [redirectableRequest setValue:nil forHTTPHeaderField:RNCachingURLHeader];
        
        //存储本次重定向的缓存数据
        WebCacheInfo *cacheInfo = [WebCacheInfo new];
        cacheInfo.cachedData = self.tempData;
        cacheInfo.cachedResponse = response;
        cacheInfo.cachedRedirectRequest = redirectableRequest;
        NSString *cacheDataPath = [self cachePathWithRequest:self.request];
        [NSKeyedArchiver archiveRootObject:cacheInfo toFile:cacheDataPath];
        
        //让客户端处理本次重定向请求
        [self.client URLProtocol:self wasRedirectedToRequest:redirectableRequest redirectResponse:response];
        return redirectableRequest;
        
    } else {
        return request;
    }
    
}

/**
 *  收到请求后调用，把得到的响应 传给self.client
 */
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    self.currentResponse = response;
    [self.client URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageNotAllowed];
}

- (void)appendData:(NSData *)newData
{
    if (!self.tempData) {
        self.tempData = [newData mutableCopy];
    } else {
        [self.tempData appendData:newData];
    }
}
/**
 *  接受数据（调用多次）data传给self.client
 */
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [self.client URLProtocol:self didLoadData:data];
    [self appendData:data];
    
}

/**
 *  结束网络加载 存储得到的相应数据 清空对应的临时对象
 */
- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    [self.client URLProtocolDidFinishLoading:self];
    //存储本次请求的缓存数据
    WebCacheInfo *cacheInfo = [WebCacheInfo new];
    cacheInfo.cachedData = self.tempData;
    cacheInfo.cachedResponse = self.currentResponse;
    NSString *cacheDataPath = [self cachePathWithRequest:self.request];
    [NSKeyedArchiver archiveRootObject:cacheInfo toFile:cacheDataPath];
    
    self.currentConnection = nil;
    self.tempData = nil;
    self.currentResponse = nil;
    
}
/**
 * 网络加载失败 清空对应的临时对象
 */
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    [self.client URLProtocol:self didFailWithError:error];
    self.currentConnection = nil;
    self.tempData = nil;
    self.currentResponse = nil;
}

/**
 *  取消请求
 */
- (void)stopLoading {
    [self.currentConnection cancel];
}
+ (void)deleteCache:(NSString *)floderName{
    //沙盒缓存目录
    NSString *sanCachePath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
    NSString * path = [sanCachePath stringByAppendingString:@"/webViewCache"];
    //在沙盒目录下创建子文件夹 用于存放webview的缓存
    NSString *cacheFolderPath = [path stringByAppendingPathComponent:floderName];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSLog(@"%@",cacheFolderPath);
    if ([fileManager fileExistsAtPath:path]){
        unsigned long long sizeNow = [[fileManager attributesOfItemAtPath:path error:nil] fileSize];
        [fileManager removeItemAtPath:path error:nil];
        NSLog(@"清除缓存");
        NSLog(@"%llu",sizeNow) ;
    }

}

//彻底删除缓存目录下的文件
+ (void)deleteCacheFolderWithFolderName:(NSString*)floderName floderSize:(unsigned long long)size{
    //沙盒缓存目录
    NSString *sanCachePath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
    NSString * path = [sanCachePath stringByAppendingString:@"/webViewCache"];
    //在沙盒目录下创建子文件夹 用于存放webview的缓存
    NSString *cacheFolderPath = [path stringByAppendingPathComponent:floderName];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSLog(@"%@",cacheFolderPath);
    if ([fileManager fileExistsAtPath:path]){
       unsigned long long sizeNow = [[fileManager attributesOfItemAtPath:path error:nil] fileSize];
        if (sizeNow >= size) {
            [fileManager removeItemAtPath:path error:nil];
        }
        
        NSLog(@"%llu",size) ;
    }
}


@end



@implementation NSString (Sha1)

- (NSString *)sha1
{
    NSData *data = [self dataUsingEncoding:NSUTF8StringEncoding];
    uint8_t digest[CC_SHA1_DIGEST_LENGTH];
    
    CC_SHA1(data.bytes, data.length, digest);
    
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_SHA1_DIGEST_LENGTH * 2];
    
    for (int i = 0; i < CC_SHA1_DIGEST_LENGTH; i++) {
        [output appendFormat:@"%02x", digest[i]];
    }
    
    return output;
}
@end

@implementation WebCacheInfo

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self) {
        self.cachedData = [aDecoder decodeObjectForKey:kDataKey];
        self.cachedResponse = [aDecoder decodeObjectForKey:kResponseKey];
        self.cachedRedirectRequest = [aDecoder decodeObjectForKey:kRedirectRequestKey];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.cachedData forKey:kDataKey];
    [aCoder encodeObject:self.cachedResponse forKey:kResponseKey];
    [aCoder encodeObject:self.cachedRedirectRequest forKey:kRedirectRequestKey];
    
}

@end


@implementation NSURLRequest(MutableCopyWorkaround)

- (id) mutableCopyWorkaround {
    NSMutableURLRequest *mutableURLRequest = [[NSMutableURLRequest alloc] initWithURL:self.URL
                                                                          cachePolicy:self.cachePolicy
                                                                      timeoutInterval:self.timeoutInterval];
    [mutableURLRequest setAllHTTPHeaderFields:self.allHTTPHeaderFields];
    if (self.HTTPBodyStream) {
        [mutableURLRequest setHTTPBodyStream:self.HTTPBodyStream];
    } else {
        [mutableURLRequest setHTTPBody:self.HTTPBody];
    }
    [mutableURLRequest setHTTPMethod:self. HTTPMethod];
    
    return mutableURLRequest;
}

@end

