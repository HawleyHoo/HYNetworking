//
//  HYSessionModel.h
//  珍夕健康
//
//  Created by 胡杨 on 16/6/14.
//  Copyright © 2016年 fitcome. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
typedef enum {
    HYDownloadStateStart = 0,     /** 下载中 */
    HYDownloadStateSuspended,     /** 下载暂停 */
    HYDownloadStateCompleted,     /** 下载完成 */
    HYDownloadStateFailed         /** 下载失败 */
}HYDownloadState;

@interface HYSessionModel : NSObject

/** 流 */
@property (nonatomic, strong) NSOutputStream *stream;

/** 下载地址 */
@property (nonatomic, copy) NSString *url;

/** 获得服务器这次请求 返回数据的总长度 */
@property (nonatomic, assign) NSInteger totalLength;

/** 下载进度 */
@property (nonatomic, copy) void(^progressBlock)(NSInteger receivedSize, NSInteger expectedSize, CGFloat progress);

/** 下载状态 */
@property (nonatomic, copy) void(^stateBlock)(HYDownloadState state);


@end
