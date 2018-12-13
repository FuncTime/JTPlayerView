//
//  CustomSliderView.h
//  JTPlayerViewDemo
//
//  Created by xujiangtao on 2018/12/12.
//  Copyright © 2018年 xujiangtao. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CustomSliderView : UIView

@property (nonatomic, copy) void(^pointPanBlock)(UIPanGestureRecognizer *pan);

@property (nonatomic, strong) UIProgressView *sliderProgress;

@end
