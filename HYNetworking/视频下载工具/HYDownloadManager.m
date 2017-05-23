//
//  HYDownloadManager.m
//  珍夕健康
//
//  Created by 胡杨 on 16/6/14.
//  Copyright © 2016年 fitcome. All rights reserved.
//

#import "HYDownloadManager.h"



// 文件的已下载长度
#define HYDownloadLength(url) [[[NSFileManager defaultManager] attributesOfItemAtPath:HYFileFullpath(url) error:nil][NSFileSize] integerValue]

// 存储文件总长度的文件路径（caches）
#define HYTotalLengthFullpath [HYCachesDirectory stringByAppendingPathComponent:@"totalLength.plist"]


@interface HYDownloadManager ()<NSURLSessionDelegate>
/** 保存所有任务(注：用下载地址作为key) */
@property (nonatomic, strong) NSMutableDictionary *tasks;
/** 保存所有下载相关信息 */
@property (nonatomic, strong) NSMutableDictionary *sessionModels;



@end

@implementation HYDownloadManager

- (NSString *)fileNameWithURLString:(NSString *)urlStirng {
    NSRange range = [urlStirng rangeOfString:@"/" options:NSBackwardsSearch];
    NSString * fileName = [urlStirng substringFromIndex:range.location+range.length];
    return fileName;
}

static HYDownloadManager *_downloadManager;

- (NSMutableDictionary *)tasks
{
    if (!_tasks) {
        _tasks = [NSMutableDictionary dictionary];
    }
    return _tasks;
}

- (NSMutableDictionary *)sessionModels
{
    if (!_sessionModels) {
        _sessionModels = [NSMutableDictionary dictionary];
    }
    return _sessionModels;
}

+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _downloadManager = [[self allocWithZone:NULL] init];
    });
    return _downloadManager;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _downloadManager = [super allocWithZone:zone];
    });
    return _downloadManager;
}

- (nonnull id)copyWithZone:(nullable NSZone *)zone
{
    return _downloadManager;
}
/**
 *  创建缓存目录文件
 */
- (void)createCacheDirectory
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:HYCachesDirectory]) {
        [fileManager createDirectoryAtPath:HYCachesDirectory withIntermediateDirectories:YES attributes:nil error:NULL];
    }
}

/**
 *  开启任务下载资源
 */
+ (void)download:(NSString *)url
        progress:(void(^)(NSInteger receivedSize, NSInteger expectedSize, CGFloat progress))progressBlock
   didStartBlock:(void(^)())didStartBlock
  didFailedBlock:(void(^)())didFailedBlock
 didSuspendBlock:(void(^)())didSuspendBlock
  didFinishBlock:(void(^)())didFinishBlock {
    HYDownloadManager *manager = [HYDownloadManager sharedInstance];
    if (!url) return;
    if ([manager isCompletion:url]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            didFinishBlock();
        });
        NSLog(@"----该资源已下载完成");
        return;
    }
    
    [manager createCacheDirectory];
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:manager delegateQueue:[[NSOperationQueue alloc] init]];
    // 创建流
    NSOutputStream *stream = [NSOutputStream outputStreamToFileAtPath:HYFileFullpath(url) append:YES];
    // 创建请求
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
    // 设置请求头
    NSString *range = [NSString stringWithFormat:@"bytes=%zd-", HYDownloadLength(url)];
    [request setValue:range forHTTPHeaderField:@"Range"];
    
    // 创建一个Data任务
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request];
    NSUInteger taskIdentifier = arc4random() % (arc4random() % 10000 + arc4random() % 10000);
    [task setValue:@(taskIdentifier) forKeyPath:@"taskIdentifier"];
    
    // 保存任务
    [manager.tasks setValue:task forKey:HYFileName(url)];
    
    HYSessionModel *sessionModel = [[HYSessionModel alloc] init];
    sessionModel.stream = stream;
    sessionModel.url = url;
    sessionModel.progressBlock = progressBlock;
    sessionModel.stateBlock = ^(HYDownloadState state) {
        dispatch_async(dispatch_get_main_queue(), ^{
            switch (state) {
                case HYDownloadStateStart: {
                    didStartBlock();
                } break;
                case HYDownloadStateSuspended: {
                    didSuspendBlock();
                } break;
                case HYDownloadStateFailed: {
                    didFailedBlock();
                } break;
                case HYDownloadStateCompleted: {
                    didFinishBlock();
                } break;
            }
        });
    };
    
    [manager.sessionModels setValue:sessionModel forKey:@(task.taskIdentifier).stringValue];
    
    [manager start:url];
}

#pragma mark - 代理
#pragma mark NSURLSessionDataDelegate
/**
 * 接收到响应
 */
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSHTTPURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition))completionHandler
{
    
    HYSessionModel *sessionModel = [self getSessionModel:dataTask.taskIdentifier];
    
    // 打开输出流
    [sessionModel.stream open];
    
    // 获得服务器这次请求 返回数据的总长度
    NSInteger totalLength = [response.allHeaderFields[@"Content-Length"] integerValue] + HYDownloadLength(sessionModel.url);
    sessionModel.totalLength = totalLength;
    
    // 存储总长度
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithContentsOfFile:HYTotalLengthFullpath];
    if (dict == nil) dict = [NSMutableDictionary dictionary];
    dict[HYFileName(sessionModel.url)] = @(totalLength);
    [dict writeToFile:HYTotalLengthFullpath atomically:YES];
    
    // 接收这个请求，允许接收服务器的数据
    completionHandler(NSURLSessionResponseAllow);
}

/**
 * 接收到服务器返回的数据
 */
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data
{
    HYSessionModel *sessionModel = [self getSessionModel:dataTask.taskIdentifier];
    
    // 写入数据
    [sessionModel.stream write:data.bytes maxLength:data.length];
    
    // 下载进度
    NSUInteger receivedSize = HYDownloadLength(sessionModel.url);
    NSUInteger expectedSize = sessionModel.totalLength;
    CGFloat progress = 1.0 * receivedSize / expectedSize;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        sessionModel.progressBlock(receivedSize, expectedSize, progress);
    });
    
}

/**
 * 请求完毕（成功|失败）
 */
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error
{
//    NSLog(@"URLSession %@ id %lu \n self.sessionModels:%@", task, (unsigned long)task.taskIdentifier, self.sessionModels);
    HYSessionModel *sessionModel = [self getSessionModel:task.taskIdentifier];
    if (!sessionModel) return;
    
    if (error) {
        if (error.code == -1001) return;
        // 下载失败
        sessionModel.stateBlock(HYDownloadStateFailed);
    } else {
        if ([self isCompletion:sessionModel.url]) {
            // 下载完成
            sessionModel.stateBlock(HYDownloadStateCompleted);
        }
        
    }
    
    // 关闭流
    [sessionModel.stream close];
    sessionModel.stream = nil;
    
    // 清除任务
    [self.tasks removeObjectForKey:HYFileName(sessionModel.url)];
    [self.sessionModels removeObjectForKey:@(task.taskIdentifier).stringValue];
}

/* Error Domain=NSURLErrorDomain Code=-1001 "请求超时。" UserInfo={NSUnderlyingError=0x1395a8a90 {Error Domain=kCFErrorDomainCFNetwork Code=-1001 "(null)" UserInfo={_kCFStreamErrorCodeKey=-2102, _kCFStreamErrorDomainKey=4}}, NSErrorFailingURLStringKey=https://data.fitcome.net/static/video/blood-glucose.mp4, NSErrorFailingURLKey=https://data.fitcome.net/static/video/blood-glucose.mp4, _kCFStreamErrorDomainKey=4, _kCFStreamErrorCodeKey=-2102, NSLocalizedDescription=请求超时。}*/

/**
 *  开始下载
 */
- (void)start:(NSString *)url
{
    NSURLSessionDataTask *task = [self getTask:url];
    [task resume];
    
    [self getSessionModel:task.taskIdentifier].stateBlock(HYDownloadStateStart);
}

/**
 *  暂停下载
 */
- (void)pause:(NSString *)url
{
    NSURLSessionDataTask *task = [self getTask:url];
    [task suspend];
    
    if ([self getSessionModel:task.taskIdentifier].stateBlock) {
        [self getSessionModel:task.taskIdentifier].stateBlock(HYDownloadStateSuspended);
    }
    
}

/**
 *  根据url获得对应的下载任务
 */
- (NSURLSessionDataTask *)getTask:(NSString *)url
{
    return (NSURLSessionDataTask *)[self.tasks valueForKey:HYFileName(url)];
}
/**
 *  根据url获取对应的下载信息模型
 */
- (HYSessionModel *)getSessionModel:(NSUInteger)taskIdentifier
{
    return (HYSessionModel *)[self.sessionModels valueForKey:@(taskIdentifier).stringValue];
}

/**
 *  判断该文件是否下载完成
 */
- (BOOL)isCompletion:(NSString *)url
{
//    NSLog(@" %ld", (long)[self fileTotalLength:url]);
//    NSLog(@" %ld", (long)HYDownloadLength(url));
    if ([self fileTotalLength:url] && HYDownloadLength(url) == [self fileTotalLength:url]) {
        return YES;
    }
    return NO;
}
/**
 *  查询该资源的下载进度值
 */
- (CGFloat)progress:(NSString *)url
{
    return [self fileTotalLength:url] == 0 ? 0.0 : 1.0 * HYDownloadLength(url) /  [self fileTotalLength:url];
}
/**
 *  获取该资源总大小
 */
- (NSInteger)fileTotalLength:(NSString *)url
{
    return [[NSDictionary dictionaryWithContentsOfFile:HYTotalLengthFullpath][HYFileName(url)] integerValue];
}

#pragma mark - 删除
/**
 *  删除该资源
 */
- (void)deleteFile:(NSString *)url
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:HYFileFullpath(url)]) {
        
        // 删除沙盒中的资源
        [fileManager removeItemAtPath:HYFileFullpath(url) error:nil];
        // 删除任务
        [self.tasks removeObjectForKey:HYFileName(url)];
        [self.sessionModels removeObjectForKey:@([self getTask:url].taskIdentifier).stringValue];
        // 删除资源总长度
        if ([fileManager fileExistsAtPath:HYTotalLengthFullpath]) {
            
            NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithContentsOfFile:HYTotalLengthFullpath];
            [dict removeObjectForKey:HYFileName(url)];
            [dict writeToFile:HYTotalLengthFullpath atomically:YES];
            
        }
    }
}

+ (void)deleteAllFile
{
    HYDownloadManager *manager = [HYDownloadManager sharedInstance];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:HYCachesDirectory]) {
        // 删除沙盒中所有资源
        [fileManager removeItemAtPath:HYCachesDirectory error:nil];
        // 删除任务
        [[manager.tasks allValues] makeObjectsPerformSelector:@selector(cancel)];
        [manager.tasks removeAllObjects];
        
        for (HYSessionModel *sessionModel in [manager.sessionModels allValues]) {
            [sessionModel.stream close];
        }
        [manager.sessionModels removeAllObjects];
        
        // 删除资源总长度
        if ([fileManager fileExistsAtPath:HYTotalLengthFullpath]) {
            [fileManager removeItemAtPath:HYTotalLengthFullpath error:nil];
        }
    }
}




@end
