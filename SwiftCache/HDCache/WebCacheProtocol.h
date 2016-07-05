//
//  WebCacheProtocol.h
//  BabelAd
//
//  Created by zhangyuhe on 16/3/21.
//  Copyright © 2016年 Babeltime. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CommonCrypto/CommonDigest.h>

@interface WebCacheProtocol : NSURLProtocol

@property (nonatomic, strong) NSString *WebCacheFolder;
+ (void)deleteCache:(NSString *)floderName;
//彻底删除缓存目录下的文件
+ (void)deleteCacheFolderWithFolderName:(NSString*)floderName floderSize:(unsigned long long)size;
//存放缓存文件的文件夹名



@end



@interface NSString (Sha1)
/**
 * Creates a SHA1 (hash) representation of NSString.
 */
- (NSString *)sha1;

@end

//缓存信息类
@interface WebCacheInfo : NSObject <NSCoding>

@property (nonatomic,readwrite,strong) NSData         *cachedData;
@property (nonatomic,readwrite,strong) NSURLRequest   *cachedRedirectRequest;
@property (nonatomic,readwrite,strong) NSURLResponse  *cachedResponse;

@end

//自定义NSURLRequest的拷贝
@interface NSURLRequest(MutableCopyWorkaround)
- (id) mutableCopyWorkaround;
@end
