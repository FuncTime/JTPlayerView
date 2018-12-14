//
//  JTPlayerView.h
//  JTPlayerView
//
//  Created by xujiangtao on 2018/12/11.
//  Copyright © 2018年 xujiangtao. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum : NSUInteger {
    PlayerControlStyleDefault,
    PlayerControlStyleSimple,
} PlayerControlStyle;

@interface JTPlayerView : UIView

//****  切换竖屏时的回调,在这里设置竖屏的约束  ****//
@property (nonatomic, copy) void(^orientationPortraitBlock)(JTPlayerView *playerView);

//返回按钮点击回调
@property (nonatomic, copy) void(^backButtonClickBlock)(UIButton *sender);

//播放完成监听回调
@property (nonatomic, copy) void(^playerDidPlayToEndTimeBlock)(NSNotification *notification);
//点击显示隐藏方法
@property (nonatomic, copy) void(^hiddenTapBlock)(BOOL isShowControlView);
//自动显示隐藏方法
@property (nonatomic, copy) void(^autoHiddenBlock)(BOOL isShowControlView);
//播放器UI类型
@property (nonatomic, assign) PlayerControlStyle playerControlStyle;
//视频链接
@property (nonatomic, strong) NSURL *URL;
//初始化方法
+ (instancetype)playerWithURL:(NSURL *)URL;
//初始化方法
- (instancetype)initWithPlayerURL:(NSURL *)URL;
//跳到结束位置
- (void)forwardPlaybackEndTime;
//跳到开始位置
- (void)reversePlaybackEndTime;

@end
