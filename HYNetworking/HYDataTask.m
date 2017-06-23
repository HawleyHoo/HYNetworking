//
//  HYDataTask.m
//  HYNetworking
//
//  Created by 胡杨 on 2017/5/11.
//  Copyright © 2017年 net.fitcome.www. All rights reserved.
//

#import "HYDataTask.h"

#define kBoundary  @"boundary"

@implementation HYDataTask

#pragma mark - 创建PNG格式的图片
NSData * createPNGPicture(NSString *formBoundary, UIImage *image,
                          NSString *name,         NSString *filename)
{
    NSString *start = [NSString stringWithFormat:@"--%@", formBoundary];
    
    // 添加分界线，换行
    NSMutableString *subBody = [[NSMutableString alloc] init];
    [subBody appendFormat:@"\r\n%@\r\n", start];
    [subBody appendFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"%@\"\r\n",
     name, filename];
    
    // 声明上传文件的格式
    [subBody appendFormat:@"Content-Type: image/png\r\n\r\n"];
    
    // 图片data
    NSData *imageData = UIImagePNGRepresentation(image);
    
    // 生成图片data
    NSMutableData *tmpData = [NSMutableData data];
    [tmpData appendData:[subBody dataUsingEncoding:NSUTF8StringEncoding]];
    [tmpData appendData:imageData];
    
    return [NSData dataWithData:tmpData];
}


+ (void)getWithURLString:(NSString *)urlstr
                  params:(NSDictionary *)params
                 success:(void (^)(id json))success
                 failure:(void (^)(NSError *error))failure {
//    NSLog(@"get  currentThread %@", [NSThread currentThread]);
//    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    
    NSURL *URL = [NSURL URLWithString:urlstr];
    if (URL) {
        NSURLRequest *request = [NSURLRequest requestWithURL:URL];
        // 3.获得会话对象
        NSURLSession *session = [NSURLSession sharedSession];
        // 4.根据会话对象，创建一个Task任务：
        NSURLSessionDataTask *sessionDataTask = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            
//            NSLog(@"session currentThread %@", [NSThread currentThread]);
//            dispatch_semaphore_signal(semaphore);
            
            dispatch_async(dispatch_get_main_queue(), ^{
//                NSLog(@"block currentThread %@", [NSThread currentThread]);
                if (data) {
                    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:(NSJSONReadingMutableLeaves) error:nil];
                    success(dict);
//                    NSLog(@"从服务器获取到数据");
                } else {
                    failure(error);
                }
                
            });
            
        }];
        // 5.最后一步，执行任务（resume也是继续执行）:
        [sessionDataTask resume];
        
//        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
//        NSLog(@"wait  currentThread %@", [NSThread currentThread]);
        
    } else {
        NSString *reason = [NSString stringWithFormat:@"get URL 是空。 URLStr = %@", urlstr];
        [[NSException exceptionWithName:@"错误" reason:reason userInfo:nil] raise];
    }
}

+ (void)postWithURLString:(NSString *)urlstr
                   params:(NSDictionary *)params
                  success:(void (^)(id json))success
                  failure:(void (^)(NSError *error))failure {
    
    // 1.创建一个网络路径
    NSURL *URL = [NSURL URLWithString:urlstr];
    if (URL) {
        // 2.创建一个网络请求，分别设置请求方法、请求参数
        NSMutableURLRequest *request =[NSMutableURLRequest requestWithURL:URL];
        request.HTTPMethod = @"POST";
        request.timeoutInterval = 20.0f;
        
        NSMutableString *mutstr = [NSMutableString string];
        for (NSString *key in params.allKeys) {
            [mutstr appendFormat:@"&%@=%@", key, params[key]];
        }
        if (mutstr.length) {
            [mutstr deleteCharactersInRange:NSMakeRange(0, 1)];
        }
        
        request.HTTPBody = [mutstr.copy dataUsingEncoding:NSUTF8StringEncoding];
        // 3.获得会话对象
        NSURLSession *session = [NSURLSession sharedSession];
        // 4.根据会话对象，创建一个Task任务
        NSURLSessionDataTask *sessionDataTask = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                if ([self isValidWithData:data response:response]) {
                    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:(NSJSONReadingMutableLeaves) error:nil];
                    success(dict);
                } else {
                    failure(error);
                }
                
            });
            
            
        }];
        //5.最后一步，执行任务，(resume也是继续执行)。
        [sessionDataTask resume];
    } else {
        NSString *reason = [NSString stringWithFormat:@"post URL 是空。 URLStr = %@", urlstr];
        [[NSException exceptionWithName:@"错误" reason:reason userInfo:nil] raise];
    }
    
}

+ (void)postWithURLString:(NSString *)urlstr
                   params:(NSDictionary *)params
                   images:(NSArray <UIImage *>*)array
                  success:(void (^)(id))success
                  failure:(void (^)(NSError *))failure {
    // 1.创建一个网络路径
    NSURL *URL = [NSURL URLWithString:urlstr];
    if (URL) {
        // 2.创建一个网络请求，分别设置请求方法、请求参数
        NSMutableURLRequest *request =[NSMutableURLRequest requestWithURL:URL];
        request.HTTPMethod = @"POST";
        request.timeoutInterval = 20.0f;
        
        
        NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@",@"boundary"];
        [request setValue:contentType forHTTPHeaderField:@"Content-Type"];
        
        NSMutableData *data = [NSMutableData data];
        
        // 生成了头部信息
        NSString        *start = [NSString stringWithFormat:@"--%@", kBoundary];
        NSMutableString *body  = [[NSMutableString alloc] init];
        NSArray         *keys  = [params allKeys];
        
        [keys enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            NSString *key = keys[idx];
            
            [body appendFormat:@"\r\n%@\r\n", start];
            [body appendFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", key];
            [body appendFormat:@"%@",params[key]];
        }];
        NSData *paramsData = [body dataUsingEncoding:NSUTF8StringEncoding];
        
        // 图片
        NSMutableData *tmpData = [NSMutableData data];
        for (int index = 0; index < array.count; index++) {
            NSString *name = @"pic"; // 表单控件名称
            NSString *filename = @"test.png"; // 上传后文件名
            // 添加分界线，换行
            NSMutableString *subBody = [[NSMutableString alloc] init];
            [subBody appendFormat:@"\r\n%@\r\n", start];
            [subBody appendFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"%@\"\r\n",
             name, filename];
            
            // 声明上传文件的格式
            [subBody appendFormat:@"Content-Type: image/png\r\n\r\n"];
            
            // 图片data
            UIImage *image = array[index];
            NSData *imageData = UIImagePNGRepresentation(image);
            
            // 生成图片data
            [tmpData appendData:[subBody dataUsingEncoding:NSUTF8StringEncoding]];
            [tmpData appendData:imageData];
        }
        NSData *fileData = [NSData dataWithData:tmpData];
        
        // POST尾部信息
        NSData *enddata = [[NSString stringWithFormat:@"\r\n--%@--\r\n", @"boundary"] dataUsingEncoding:NSUTF8StringEncoding];
        
        [data appendData:paramsData];
        [data appendData:fileData];
        [data appendData:enddata];
        
        NSLog(@"data=%@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
        request.HTTPBody = data.copy;
        [request setValue:[NSString stringWithFormat:@"%lu",(unsigned long)data.length] forHTTPHeaderField:@"Content-Length"];
        
        // 3.获得会话对象
        NSURLSession *session = [NSURLSession sharedSession];
        // 4.根据会话对象，创建一个Task任务
        NSURLSessionDataTask *sessionDataTask = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                if ([self isValidWithData:data response:response]) {
                    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:(NSJSONReadingMutableLeaves) error:nil];
                    success(dict);
                } else {
                    failure(error);
                }
                
            });
            
            
        }];
        //5.最后一步，执行任务，(resume也是继续执行)。
        [sessionDataTask resume];
    } else {
        NSString *reason = [NSString stringWithFormat:@"post URL 是空。 URLStr = %@", urlstr];
        [[NSException exceptionWithName:@"错误" reason:reason userInfo:nil] raise];
    }
    
}


+ (BOOL)isValidWithData:(NSData *)data response:(NSURLResponse *)response {
    if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
        NSHTTPURLResponse *HTTPURLResponse = (NSHTTPURLResponse *)response;
        if (HTTPURLResponse.statusCode == 200) {
            if (data.length > 0) {
                return YES;
            } else {
                return NO;
            }
        } else {
            return NO;
        }
    } else {
        return NO;
    }
}
@end
