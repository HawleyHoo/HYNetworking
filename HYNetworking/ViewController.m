//
//  ViewController.m
//  HYNetworking
//
//  Created by 胡杨 on 2017/5/11.
//  Copyright © 2017年 net.fitcome.www. All rights reserved.
//

#import "ViewController.h"

#import "HYDataTask.h"


@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [HYDataTask getWithURLString:@"http://www.pinxuejianyou.cn/api/area/getarea" params:nil success:^(id json) {
//        NSLog(@" json %@", json);
        
    } failure:^(NSError *error) {
        NSLog(@" error %@", error);
    }];
    
    
//    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
//    // global queue 全局队列是一个并行队列
//    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
//    //    dispatch_queue_t queue = dispatch_queue_create("serial", DISPATCH_QUEUE_SERIAL);
//    NSLog(@"---begin task 1 %@", [NSThread currentThread]);
//    dispatch_async(queue, ^{
//        NSLog(@"---run task 1 %@", [NSThread currentThread]);
//        sleep(2);
//        NSLog(@"---complete task 1 %@", [NSThread currentThread]);
//        dispatch_semaphore_signal(semaphore);
//        
//        //        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), queue, ^{
//        //        });
//    });
//    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
//    NSLog(@"---wait task 1 %@", [NSThread currentThread]);
    

}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
