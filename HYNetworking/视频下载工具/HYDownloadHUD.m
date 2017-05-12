//
//  HYDownloadHUD.m
//  珍夕健康
//
//  Created by 胡杨 on 16/6/15.
//  Copyright © 2016年 fitcome. All rights reserved.
//

#import "HYDownloadHUD.h"

static inline UIColor *RGBACOLOR(CGFloat r, CGFloat g, CGFloat b, CGFloat a) {
    return [UIColor colorWithRed:(r)/255.0f green:(g)/255.0f blue:(b)/255.0f alpha:(a)];
}

@interface HYDownloadHUD ()

@property (nonatomic, weak) UIProgressView *proressView;

@property (nonatomic, weak) UILabel *titleLabel;

@property (nonatomic, weak) UILabel *detailLabel;

@end

@implementation HYDownloadHUD

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        CGFloat width = 240;
        CGFloat height = 100;
        self.frame = CGRectMake(0, 0, width, height);
        self.backgroundColor = RGBACOLOR(90, 90, 90, 0.6);//[[UIColor blackColor] colorWithAlphaComponent:0.3];
        self.layer.cornerRadius = 5;
        self.clipsToBounds = YES;
        
        UILabel *titleLabel = [[UILabel alloc] init];
        titleLabel.frame = CGRectMake(0, 12, width, 20);
        self.titleLabel = titleLabel;
        titleLabel.text = @"正在下载";
        titleLabel.textAlignment = NSTextAlignmentCenter;
        titleLabel.textColor = [UIColor whiteColor];
        titleLabel.font = [UIFont systemFontOfSize:13];
        [self addSubview:titleLabel];
        
        UILabel *detailLabel = [[UILabel alloc] init];
        detailLabel.frame = CGRectMake(0, CGRectGetMaxY(titleLabel.frame), width, 20);
        self.detailLabel= detailLabel;
        detailLabel.text = @"下载完成后，下次可直接播放";
        detailLabel.textAlignment = NSTextAlignmentCenter;
        detailLabel.textColor = [UIColor whiteColor];
        detailLabel.font = [UIFont systemFontOfSize:13];
        [self addSubview:detailLabel];
        
        UIProgressView *progressView = [[UIProgressView alloc] init];
        progressView.frame = CGRectMake(20, CGRectGetMaxY(detailLabel.frame) + 12, width - 40, 20);
        self.proressView = progressView;
        //progressView.progressViewStyle = UIProgressViewStyleBar;
        progressView.progressTintColor = [UIColor redColor];
        progressView.trackTintColor = [UIColor whiteColor];
        progressView.progress = 0.0;
        [self addSubview:progressView];
        
    }
    return self;
}

+ (instancetype)hud {
    return [[self alloc] initWithFrame:CGRectZero];
}

- (void)setProgress:(CGFloat)progress {
    self.proressView.progress = progress;
    
}
- (void)layoutSubviews {
    [super layoutSubviews];
    
    
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
