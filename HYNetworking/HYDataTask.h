//
//  HYDataTask.h
//  HYNetworking
//
//  Created by 胡杨 on 2017/5/11.
//  Copyright © 2017年 net.fitcome.www. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


@interface HYDataTask : NSObject

+ (void)getWithURLString:(NSString *)urlstr
                  params:(NSDictionary *)params
                 success:(void (^)(id json))success
                 failure:(void (^)(NSError *error))failure;

+ (void)postWithURLString:(NSString *)urlstr
                   params:(NSDictionary *)params
                  success:(void (^)(id json))success
                  failure:(void (^)(NSError *error))failure;


+ (void)postWithURLString:(NSString *)urlstr
                   params:(NSDictionary *)params
                   images:(NSArray <UIImage *>*)array
                  success:(void (^)(id json))success
                  failure:(void (^)(NSError *error))failure;
@end
