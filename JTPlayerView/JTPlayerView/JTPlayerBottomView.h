//
//  JTPlayerBottomView.h
//  JTPlayerView
//
//  Created by xujiangtao on 2018/12/11.
//  Copyright © 2018年 xujiangtao. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JTPlayerBottomView : UIView

@property (nonatomic, copy) void(^playButtonClickBlock)(UIButton *sender);

@property (nonatomic, copy) void(^fullScreenButtonClickBlock)(UIButton *sender);

@property (nonatomic, copy) void(^pointPanClock)(UIPanGestureRecognizer *pan);

@property (weak, nonatomic) IBOutlet UIButton *playButton;

@property (weak, nonatomic) IBOutlet UIProgressView *progressView;
@property (weak, nonatomic) IBOutlet UILabel *durationLabel;
@property (weak, nonatomic) IBOutlet UILabel *currentTimeLabel;

@property (nonatomic, strong) UIProgressView *sliderProgress;

@end
