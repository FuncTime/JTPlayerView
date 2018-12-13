//
//  CustomSliderView.m
//  JTPlayerViewDemo
//
//  Created by xujiangtao on 2018/12/12.
//  Copyright © 2018年 xujiangtao. All rights reserved.
//

#import "CustomSliderView.h"
#import "UIView+Extension.h"

@interface CustomSliderView ()

@end

@implementation CustomSliderView

- (instancetype)init {
    self = [super init];
    if (self) {
        self.userInteractionEnabled = YES;
        [self createViews];
    }
    return self;
}

- (void)createViews {
    
    self.sliderProgress = [[UIProgressView alloc] initWithFrame:CGRectZero];
    self.sliderProgress.progressTintColor = [UIColor redColor];
    self.sliderProgress.trackTintColor = [UIColor clearColor];
    [self.sliderProgress setProgress:0.01 animated:YES];
    [self addSubview:self.sliderProgress];
    [self.sliderProgress mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self);
        make.centerY.equalTo(self);
        make.height.mas_equalTo(2);
    }];
    
    UIImageView *progressImageView = self.sliderProgress.subviews.lastObject;
    
    UIView *point = [[UIView alloc] initWithFrame:CGRectZero];
    point.layer.cornerRadius = 10;
    point.layer.masksToBounds = YES;
    point.backgroundColor = [UIColor whiteColor];
    [self addSubview:point];
    [point mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.sliderProgress);
        make.centerX.equalTo(progressImageView.mas_right);
        make.width.height.mas_equalTo(20);
    }];
    
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pointPan:)];
    [self addGestureRecognizer:pan];
}

- (void)pointPan:(UIPanGestureRecognizer *)pan {
    
    if (self.pointPanBlock) {
        self.pointPanBlock(pan);
    }
    
    if (pan.state == UIGestureRecognizerStateBegan) {
        
        
    }else if (pan.state == UIGestureRecognizerStateChanged) {
        
        
    }else if (pan.state == UIGestureRecognizerStateEnded) {
        
        
    }
    
    CGPoint point = [pan locationInView:pan.view];
    
    float progress = point.x / pan.view.width;
    
    if (progress >= 0 || progress <= 1) {
        
        [self.sliderProgress setProgress:progress];
    }

}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
