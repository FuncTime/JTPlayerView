//
//  JTPlayer.h
//  JTPlayerView
//
//  Created by xujiangtao on 2018/12/12.
//  Copyright © 2018年 xujiangtao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

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

@property (nonatomic, strong) AVPlayer *player;//播放器

@property (nonatomic, strong) NSURL *URL;

@property (nonatomic, assign) CMTime duration;

- (instancetype)initWithPlayerURL:(NSURL *)URL;

- (void)play;

- (void)pause;

- (void)seekToTime:(CMTime)time;

- (void)seekToTime:(CMTime)time completionHandler:(void (^)(BOOL finished))completionHandler NS_AVAILABLE(10_7, 5_0);

@end
