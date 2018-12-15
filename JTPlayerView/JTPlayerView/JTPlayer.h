//
//  JTPlayer.h
//  JTPlayerView
//
//  Created by xujiangtao on 2018/12/12.
//  Copyright © 2018年 xujiangtao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "AVPlayerLayerView.h"

@interface JTPlayer : UIView
//播放时间监听回调
@property (nonatomic, copy) void(^playerTimeObserverBlock)(CMTime time);
//播放状态监听回调
@property (nonatomic, copy) void(^playerStatusObserverBlock)(AVPlayerItemStatus status);
//播放完成监听回调
@property (nonatomic, copy) void(^playerDidPlayToEndTimeBlock)(NSNotification *notification);
//播放器速率监听回调
@property (nonatomic, copy) void(^playerRateObserverBlock)(float rate);
//更改播放资源监听回调
@property (nonatomic, copy) void(^playerChangeItemObserverBlock)(AVPlayerItem *item);
//本次缓冲范围监听回调
@property (nonatomic, copy) void(^playerLoadedTimeRangesObserverBlock)(NSArray *array);
//跳转时间成功回调
@property (nonatomic, copy) void(^seekTimecompletionBlock)(BOOL finished);
//锁屏界面播放按钮点击回调
@property (nonatomic, copy) void(^remotePlayEventBlock)(void);
//锁屏按钮暂停按钮点击回调
@property (nonatomic, copy) void(^remotePauseEventBlock)(void);
//播放器
@property (nonatomic, strong) AVPlayer *player;
//播放界面
@property (nonatomic, strong) AVPlayerLayer *playerLayer;
//视频链接
@property (nonatomic, strong) NSURL *URL;
//总时间
@property (nonatomic, assign) CMTime duration;
//是否后台播放 默认NO
@property (nonatomic, assign) BOOL playInTheBackground;
//视频名称
@property (nonatomic, copy) NSString *title;
//当前时间
- (CMTime)currentTime;
//初始化方法
- (instancetype)initWithPlayerURL:(NSURL *)URL;
//播放
- (void)play;
//暂停
- (void)pause;
//跳转时间
- (void)seekToTime:(CMTime)time;
//跳转时间 + 成功回调
- (void)seekToTime:(CMTime)time completionHandler:(void (^)(BOOL finished))completionHandler NS_AVAILABLE(10_7, 5_0);

@end
