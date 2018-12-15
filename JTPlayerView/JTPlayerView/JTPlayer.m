//
//  JTPlayer.m
//  JTPlayerView
//
//  Created by xujiangtao on 2018/12/12.
//  Copyright © 2018年 xujiangtao. All rights reserved.
//

#import "JTPlayer.h"
#import <MediaPlayer/MediaPlayer.h>

@interface JTPlayer () {
    AVPlayerItemVideoOutput *videoOutput;
}
//自定义可以约束的layer
@property (nonatomic, strong) AVPlayerLayerView *videoLayer;
//播放单元
@property (nonatomic, strong) AVPlayerItem *item;
//播放时间定时器
@property (nonatomic, strong) id timeObserverToken;
//锁屏控制信息
@property (nonatomic, strong) NSMutableDictionary *playingInfoDict;
//第一帧图片
@property (nonatomic, strong) UIImage *firstFrameImage;

@end

@implementation JTPlayer

- (instancetype)initWithPlayerURL:(NSURL *)URL {
    self = [super init];
    if (self) {
        self.URL = URL;
    }
    return self;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        
        if (!self.URL) {
            
            [self createViews];
            [self createRemoteCommandCenter];
            [self addAudioSession];
        }
    }
    return self;
}

- (void)createViews {
    
    //初始化一个可以约束的AVPlayerLayer
    [self addSubview:self.videoLayer];
    [self.videoLayer mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.bottom.equalTo(self);
    }];
}

- (void)play {
    [self.player play];
    [self updateLockScreenInfo];
}

- (void)pause {
    [self.player pause];
    [self updateLockScreenInfo];
}

- (void)seekToTime:(CMTime)time {
    [self.player seekToTime:time];
}

- (void)seekToTime:(CMTime)time completionHandler:(void (^)(BOOL finished))completionHandler NS_AVAILABLE(10_7, 5_0) {
    __weak typeof(self) weakSelf = self;
    [self.player seekToTime:time completionHandler:^(BOOL finished) {
        completionHandler(finished);
        [weakSelf updateLockScreenInfo];
    }];
}

- (void)setURL:(NSURL *)URL {
    _URL = URL;
    
    [self removeObserver];
    //设置播放的项目
    self.item = [[AVPlayerItem alloc] initWithURL:self.URL];
    [self.player replaceCurrentItemWithPlayerItem:self.item];
    [self addObserver];
    
    //准备参数字典
    NSDictionary *settings = @{(id)kCVPixelBufferPixelFormatTypeKey:
                                   [NSNumber numberWithInt:kCVPixelFormatType_32BGRA]
                               };
    //创建AVPlayerItemVideoOutput
    videoOutput = [[AVPlayerItemVideoOutput alloc] initWithPixelBufferAttributes:settings];
    //向playerItem添加AVPlayerItemVideoOutput
    [self.item addOutput:videoOutput];
}

//获取时间帧的图片
- (UIImage *)getCurrentImageWithTime:(CMTime)time {
    
    //获取对应时间的缓存上下文
    CVPixelBufferRef buffer = [videoOutput copyPixelBufferForItemTime:time itemTimeForDisplay:nil];
    if (buffer == nil) {
        return nil;
    }
    //生成CIImage
    CIImage *ciImage = [CIImage imageWithCVPixelBuffer:buffer];
    //生成CGImage
    CIContext *temporaryContext = [CIContext contextWithOptions:nil];
    CGImageRef videoImage = [temporaryContext createCGImage:ciImage fromRect:CGRectMake(0, 0, CVPixelBufferGetWidth(buffer), CVPixelBufferGetHeight(buffer))];
    //转化成UIImage
    UIImage *image = [UIImage imageWithCGImage:videoImage];
    
    return image;
}

- (void)addObserver {
    
    //监控状态属性，注意AVPlayer也有一个status属性，通过监控它的status也可以获得播放状态
    [self.player.currentItem addObserver:self forKeyPath:@"status" options:(NSKeyValueObservingOptionOld|NSKeyValueObservingOptionNew) context:nil];
    
    //监控缓冲加载情况属性
    [self.player.currentItem addObserver:self forKeyPath:@"loadedTimeRanges" options:NSKeyValueObservingOptionOld|NSKeyValueObservingOptionNew context:nil];
    
    //监控播放完成通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playbackFinished:) name:AVPlayerItemDidPlayToEndTimeNotification object:self.player.currentItem];
    __weak typeof(self) weakSelf = self;
    
    CMTime interval = CMTimeMakeWithSeconds(0.5, NSEC_PER_SEC);
    dispatch_queue_t mainQueue = dispatch_get_main_queue();
    self.timeObserverToken =
    [self.player addPeriodicTimeObserverForInterval:interval
                                              queue:mainQueue
                                         usingBlock:^(CMTime time) {
                                             if (weakSelf.playerTimeObserverBlock) {
                                                 weakSelf.playerTimeObserverBlock(time);
                                             }
                                         }];
    
}

- (void)removeObserver {
    [self.player.currentItem removeObserver:self forKeyPath:@"status"];
    [self.player.currentItem removeObserver:self forKeyPath:@"loadedTimeRanges"];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
    [self.player removeTimeObserver:self.timeObserverToken];
}

#pragma mark - KVO
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    
    AVPlayerItem *playerItem = object;
    if ([keyPath isEqualToString:@"status"]) {
        AVPlayerItemStatus status = [change[@"new"] integerValue];
        if (status == AVPlayerItemStatusReadyToPlay) {
            self.duration = self.player.currentItem.duration;
        }
        if (self.playerStatusObserverBlock) {
            self.playerStatusObserverBlock(status);
        }
        
    } else if([keyPath isEqualToString:@"loadedTimeRanges"]){
        
        NSArray *array = playerItem.loadedTimeRanges;
        if (self.playerLoadedTimeRangesObserverBlock) {
            self.playerLoadedTimeRangesObserverBlock(array);
        }
        if (!self.firstFrameImage) {
            
            self.firstFrameImage = [self getCurrentImageWithTime:self.player.currentItem.currentTime];
            [self updateLockScreenInfo];
        }
        
    } else if ([keyPath isEqualToString:@"rate"]) {
        // rate=1:播放，rate!=1:非播放
        float rate = self.player.rate;
        if (self.playerRateObserverBlock) {
            self.playerRateObserverBlock(rate);
        }
        
    } else if ([keyPath isEqualToString:@"currentItem"]) {
        NSLog(@"新的currentItem");
        if (self.playerChangeItemObserverBlock) {
            self.playerChangeItemObserverBlock(self.player.currentItem);
        }
    }
}

- (void)playbackFinished:(NSNotification *)notification {
    
    if (self.playerDidPlayToEndTimeBlock) {
        self.playerDidPlayToEndTimeBlock(notification);
    }
}

- (CMTime)currentTime {
    return self.player.currentItem.currentTime;
}

- (AVPlayerLayerView *)videoLayer {
    if (!_videoLayer) {
        _videoLayer = [[AVPlayerLayerView alloc] init];
        //设置播放页面
        self.playerLayer = (AVPlayerLayer *)_videoLayer.layer;
        self.playerLayer.player = self.player;
    }
    return _videoLayer;
}

- (AVPlayer *)player {
    if (!_player) {
        _player = [[AVPlayer alloc] init];
    }
    return _player;
}

- (void)setPlayInTheBackground:(BOOL)playInTheBackground {
    _playInTheBackground = playInTheBackground;
    [self updateLockScreenInfo];
    [self createRemoteCommandCenter];
}

- (void)setTitle:(NSString *)title {
    _title = title;
    [self updateLockScreenInfo];
}

// 更新锁屏界面信息
- (void)updateLockScreenInfo {
    
    if (!_player && !_playInTheBackground) {
        return;
    }
    
    // 1.获取锁屏中心
    MPNowPlayingInfoCenter *playingInfoCenter = [MPNowPlayingInfoCenter defaultCenter];
    // 初始化一个存放音乐信息的字典
    NSMutableDictionary *playingInfoDict = [NSMutableDictionary dictionary];
    
    // 2、设置歌曲名
    [playingInfoDict setObject:self.title == nil ? @"" : self.title forKey:MPMediaItemPropertyTitle];
//    [playingInfoDict setObject:@"哈哈哈哈哈" forKey:MPMediaItemPropertyAlbumTitle];
    
    // 3、设置封面的图片
    UIImage *image = self.firstFrameImage;
    if (image) {
        MPMediaItemArtwork *artwork = [[MPMediaItemArtwork alloc] initWithImage:image];
        [playingInfoDict setObject:artwork forKey:MPMediaItemPropertyArtwork];
    }
    
    // 4、设置歌曲的时长和已经消耗的时间
    NSNumber *playbackDuration = @(CMTimeGetSeconds(_player.currentItem.duration));
    NSNumber *elapsedPlaybackTime = @(CMTimeGetSeconds(_player.currentItem.currentTime));
    
    if (!playbackDuration || !elapsedPlaybackTime) {
        return;
    }
    [playingInfoDict setObject:playbackDuration
                        forKey:MPMediaItemPropertyPlaybackDuration];
    [playingInfoDict setObject:elapsedPlaybackTime
                        forKey:MPNowPlayingInfoPropertyElapsedPlaybackTime];
    [playingInfoDict setObject:@(_player.rate) forKey:MPNowPlayingInfoPropertyPlaybackRate];
    
    //音乐信息赋值给获取锁屏中心的nowPlayingInfo属性
    playingInfoCenter.nowPlayingInfo = playingInfoDict;
}

// 添加远程控制
- (void)createRemoteCommandCenter {
    
    if (!_playInTheBackground) {
        return;
    }
    
    MPRemoteCommandCenter *commandCenter = [MPRemoteCommandCenter sharedCommandCenter];
    
    MPRemoteCommand *pauseCommand = [commandCenter pauseCommand];
    [pauseCommand setEnabled:YES];
    [pauseCommand addTarget:self action:@selector(remotePauseEvent)];
    
    MPRemoteCommand *playCommand = [commandCenter playCommand];
    [playCommand setEnabled:YES];
    [playCommand addTarget:self action:@selector(remotePlayEvent)];
    
    MPRemoteCommand *nextCommand = [commandCenter nextTrackCommand];
    [nextCommand setEnabled:YES];
    [nextCommand addTarget:self action:@selector(remoteNextEvent)];
    
    MPRemoteCommand *previousCommand = [commandCenter previousTrackCommand];
    [previousCommand setEnabled:YES];
    [previousCommand addTarget:self action:@selector(remotePreviousEvent)];
    
    if (@available(iOS 9.1, *)) {
        MPRemoteCommand *changePlaybackPositionCommand = [commandCenter changePlaybackPositionCommand];
        [changePlaybackPositionCommand setEnabled:YES];
        [changePlaybackPositionCommand addTarget:self action:@selector(remoteChangePlaybackPosition:)];
    }
}

- (void)remotePlayEvent {
    if (self.remotePlayEventBlock) {
        self.remotePlayEventBlock();
    }
}

- (void)remotePauseEvent {
    if (self.remotePauseEventBlock) {
        self.remotePauseEventBlock();
    }
}

- (void)remoteNextEvent {
    
//    [self playNextVideo];
}

- (void)remotePreviousEvent {
    
//    [self playPreviousVideo];
}

- (void)remoteChangePlaybackPosition:(MPRemoteCommandEvent *)event {
    
    MPChangePlaybackPositionCommandEvent * playbackPositionEvent = (MPChangePlaybackPositionCommandEvent *)event;
    CMTime duration = _player.currentItem.duration;
    CMTime currentTime = CMTimeMakeWithSeconds(playbackPositionEvent.positionTime, duration.timescale);
    [self.player seekToTime:currentTime completionHandler:^(BOOL finished) {
        // 同步锁屏界面进度
        [self updateLockScreenInfo];
    }];
}

- (void)removeCommandCenterTargets
{
    MPRemoteCommandCenter *commandCenter = [MPRemoteCommandCenter sharedCommandCenter];
    [[commandCenter playCommand] removeTarget:self];
    [[commandCenter pauseCommand] removeTarget:self];
    [[commandCenter nextTrackCommand] removeTarget:self];
    [[commandCenter previousTrackCommand] removeTarget:self];
    
    if (@available(iOS 9.1, *)) {
        [commandCenter.changePlaybackPositionCommand removeTarget:self];
    }
}

//耳机控制添加
- (void)addAudioSession {
    [[AVAudioSession sharedInstance] setActive:YES error:nil];//创建单例对象并且使其设置为活跃状态.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(audioRouteChangeListenerCallback:)   name:AVAudioSessionRouteChangeNotification object:nil];//设置通知
    
}
//通知方法的实现
- (void)audioRouteChangeListenerCallback:(NSNotification*)notification {
    
    NSDictionary *interuptionDict = notification.userInfo;
    NSInteger routeChangeReason = [[interuptionDict valueForKey:AVAudioSessionRouteChangeReasonKey] integerValue];
    switch (routeChangeReason) {
        case AVAudioSessionRouteChangeReasonNewDeviceAvailable:
            NSLog(@"耳机插入");
            break;
        case AVAudioSessionRouteChangeReasonOldDeviceUnavailable:
            NSLog(@"耳机拔出");
            if (self.remotePauseEventBlock) {
                self.remotePauseEventBlock();
            }
            break;
        case AVAudioSessionRouteChangeReasonCategoryChange:
            // called at start - also when other audio wants to play
            NSLog(@"AVAudioSessionRouteChangeReasonCategoryChange");
            if (self.remotePauseEventBlock) {
                self.remotePauseEventBlock();
            }
            break;
    }
}

- (void)dealloc {
    NSLog(@"JTPlayer---dealloc");
    [self removeObserver];
    [self removeCommandCenterTargets];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
