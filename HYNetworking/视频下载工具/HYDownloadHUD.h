//
//  HYDownloadHUD.h
//  珍夕健康
//
//  Created by 胡杨 on 16/6/15.
//  Copyright © 2016年 fitcome. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HYDownloadHUD : UIView


+ (instancetype)hud;

- (void)setProgress:(CGFloat)progress;

@end
