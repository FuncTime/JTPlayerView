//
//  JTPlayer.m
//  JTPlayerView
//
//  Created by xujiangtao on 2018/12/12.
//  Copyright © 2018年 xujiangtao. All rights reserved.
//

#import "JTPlayer.h"
#import "AVPlayerLayerView.h"

@interface JTPlayer ()

@property (nonatomic, strong) AVPlayerItem *item;//播放单元
@property (nonatomic, strong) AVPlayerLayer *playerLayer;//播放界面
@property (nonatomic, strong) AVPlayerLayerView *videoLayer;
@property (nonatomic, strong) id timeObserverToken;

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
        }
    }
    return self;
}

- (void)createViews {
    
    //初始化player对象
    self.player = [[AVPlayer alloc] init];
    
    //初始化一个可以约束的AVPlayerLayer(这操作真骚)
    self.videoLayer = [[AVPlayerLayerView alloc] init];
    [self addSubview:self.videoLayer];
    [self.videoLayer mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.bottom.equalTo(self);
    }];
    
    //设置播放页面
    self.playerLayer = (AVPlayerLayer *)self.videoLayer.layer;
    self.playerLayer.player = self.player;
    
}

- (void)play {
    [self.player play];
}

- (void)pause {
    [self.player pause];
}

- (void)seekToTime:(CMTime)time {
    [self.player seekToTime:time];
}

- (void)seekToTime:(CMTime)time completionHandler:(void (^)(BOOL finished))completionHandler NS_AVAILABLE(10_7, 5_0) {
    [self.player seekToTime:time completionHandler:completionHandler];
}

- (void)setURL:(NSURL *)URL {
    _URL = URL;
    
    [self removeObserver];
    //设置播放的项目
    self.item = [[AVPlayerItem alloc] initWithURL:self.URL];
    [self.player replaceCurrentItemWithPlayerItem:self.item];
    [self addObserver];
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

- (void)dealloc {
    NSLog(@"JTPlayer---dealloc");
    [self removeObserver];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
