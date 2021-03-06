//
//  HYDownloadManager.h
//  珍夕健康
//
//  Created by 胡杨 on 16/6/14.
//  Copyright © 2016年 fitcome. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HYSessionModel.h"

// 缓存主目录
#define HYCachesDirectory [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"HYCache"]

//// 保存文件名
#define HYFileName(url) [[HYDownloadManager sharedInstance] fileNameWithURLString:url]

// 文件的存放路径（caches）
#define HYFileFullpath(url) [HYCachesDirectory stringByAppendingPathComponent:[[HYDownloadManager sharedInstance] fileNameWithURLString:url]]

@interface HYDownloadManager : NSObject

+ (instancetype)sharedInstance;

- (NSString *)fileNameWithURLString:(NSString *)urlStirng;
/**
 *  开启任务下载资源
 *
 *  @param url           下载地址
 *  @param progressBlock 回调下载进度
 *  @param stateBlock    下载状态
 */
+ (void)download:(NSString *)url
        progress:(void(^)(NSInteger receivedSize, NSInteger expectedSize, CGFloat progress))progressBlock
   didStartBlock:(void(^)())didStartBlock
  didFailedBlock:(void(^)())didFailedBlock
 didSuspendBlock:(void(^)())didSuspendBlock
  didFinishBlock:(void(^)())didFinishBlock;

/**
 *  查询该资源的下载进度值
 *
 *  @param url 下载地址
 *
 *  @return 返回下载进度值
 */
- (CGFloat)progress:(NSString *)url;

/**
 *  获取该资源总大小
 *
 *  @param url 下载地址
 *
 *  @return 资源总大小
 */
- (NSInteger)fileTotalLength:(NSString *)url;

/**
 *  判断该资源是否下载完成
 *
 *  @param url 下载地址
 *
 *  @return YES: 完成
 */
- (BOOL)isCompletion:(NSString *)url;

/**
 *  暂停
 *
 *  @param url 下载地址
 */
- (void)pause:(NSString *)url;

/**
 *  删除该资源
 *
 *  @param url 下载地址
 */
- (void)deleteFile:(NSString *)url;

/**
 *  清空所有下载资源
 */
+ (void)deleteAllFile;


@end
