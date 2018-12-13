//
//  JTPlayerView.m
//  JTPlayerView
//
//  Created by xujiangtao on 2018/12/11.
//  Copyright © 2018年 xujiangtao. All rights reserved.
//

#import "JTPlayerView.h"
#import <AVFoundation/AVFoundation.h>
#import "JTPlayer.h"
#import "JTPlayerBottomView.h"
#import "JTPlayerTopView.h"
#import "UIView+Extension.h"

@interface JTPlayerView ()

@property (nonatomic, strong) JTPlayerBottomView *bottomView;

@property (nonatomic, strong) JTPlayerTopView *topView;

@property (nonatomic, strong) JTPlayer *player;
//是否在拖动点,用来防止小圆点随时间跳动
@property (nonatomic, assign) BOOL isPanPoint;

@property (nonatomic, strong) UIView *controlBgView;

@end

//自动隐藏时间
#define HiddenLimit 5.0

@implementation JTPlayerView

+ (instancetype)playerWithURL:(NSURL *)URL {

    return [[self alloc] initWithPlayerURL:URL];
}

- (instancetype)initWithPlayerURL:(NSURL *)URL {
    self = [super init];
    if (self) {
        [self createPlayerView];
        [self defaultSetting];
        [self addHiddenGesture];
        self.URL = URL;
    }
    return self;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self createPlayerView];
        [self defaultSetting];
        [self addHiddenGesture];
    }
    return self;
}

- (void)createPlayerView {
    
    //player
    [self addSubview:self.player];
    [self.player mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.bottom.equalTo(self);
    }];
    //放各种控制的view
    self.controlBgView = [[UIView alloc] initWithFrame:CGRectZero];
    [self addSubview:self.controlBgView];
    [self.controlBgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.right.bottom.left.equalTo(self);
    }];
}

- (void)defaultSetting {
    self.playerControlStyle = PlayerControlStyleDefault;
}

- (void)setPlayerControlStyle:(PlayerControlStyle)playerControlStyle {
    _playerControlStyle = playerControlStyle;
    [self.controlBgView removeAllSubViews];
    if (playerControlStyle == PlayerControlStyleDefault) {
        
        [self createDefaultViews];
    }else if (playerControlStyle == PlayerControlStyleSimple) {
        
        [self createSimpleViews];
    }
}
//创建默认UI
- (void)createDefaultViews {
    
    __weak typeof(self) weakSelf = self;
    //播放器播放时间监听回调
    [self playerTimeObserver];
    //播放状态监听回调
    [self playerStatusObserver];
    //本次缓冲范围监听回调
    [self playerLoadedTimeRangesObserver];
    //播放完成监听回调
    [self playerDidPlayToEndTime];
    
    //上方的view
    [self.controlBgView addSubview:self.topView];
    [self.topView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.right.equalTo(self);
        make.height.mas_equalTo(40);
    }];
    
    self.topView.backButtonClickBlock = ^(UIButton *sender) {
        if (weakSelf.backButtonClickBlock) {
            weakSelf.backButtonClickBlock(sender);
        }
    };
    
    //下方的view
    [self.controlBgView addSubview:self.bottomView];
    [self.bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self);
        make.height.mas_equalTo(40);
    }];
    
    self.bottomView.playButtonClickBlock = ^(UIButton *sender) {
        if (sender.selected) {
            [weakSelf.player play];
        }else {
            [weakSelf.player pause];
        }
    };
    
    self.bottomView.fullScreenButtonClickBlock = ^(UIButton *sender) {
        if (weakSelf.fullScreenButtonClickBlock) {
            weakSelf.fullScreenButtonClickBlock(sender);
        }
    };
    
    self.bottomView.pointPanClock = ^(UIPanGestureRecognizer *pan) {
        
        if (pan.state == UIGestureRecognizerStateBegan) {
            
            weakSelf.isPanPoint = YES;
            [weakSelf cancleTimingMethod];
        }else if (pan.state == UIGestureRecognizerStateChanged) {
            
            CMTime duration = weakSelf.player.duration;
            float durationSec = duration.value / duration.timescale;
            NSInteger sec = weakSelf.bottomView.sliderProgress.progress * durationSec;
            weakSelf.bottomView.currentTimeLabel.text = [weakSelf getMMSSFromSS:sec];
            
        }else if (pan.state == UIGestureRecognizerStateEnded) {
            
            CMTime duration = weakSelf.player.duration;
            NSInteger durationSec = duration.value / duration.timescale;
            NSInteger sec = weakSelf.bottomView.sliderProgress.progress * durationSec;
            CMTime time = CMTimeMake(sec, 1);
            [weakSelf.player seekToTime:time completionHandler:^(BOOL finished) {
                
                weakSelf.isPanPoint = NO;
                [weakSelf addTimingMethod];
            }];
        }
    };
    
    [self addTimingMethod];
}
//创建简单UI
- (void)createSimpleViews {
    
}

//隐藏显示方法
- (void)addHiddenGesture {
    
    self.userInteractionEnabled = YES;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hiddenTap:)];
    [self addGestureRecognizer:tap];
}

- (void)hiddenTap:(UITapGestureRecognizer *)tap {
    
    if (self.topView.alpha == 1.0) {
        [self hiddenControlView];
    }else {
        [self showControlView];
        
    }
}

////播放时间监听回调
- (void)playerTimeObserver {
    
    __weak typeof(self) weakSelf = self;
    self.player.playerTimeObserverBlock = ^(CMTime time) {
        
        float sec = time.value / time.timescale;
        weakSelf.bottomView.currentTimeLabel.text = [weakSelf getMMSSFromSS:sec];
        
        if (weakSelf.player.duration.value) {
            
            CMTime duration = weakSelf.player.duration;
            float durationSec = duration.value / duration.timescale;
//            NSLog(@"%f",(sec / durationSec));
            if (!weakSelf.isPanPoint) {
                
                float currentProgress = sec / durationSec;
                if (currentProgress > 0.01) {
                    
                    [weakSelf.bottomView.sliderProgress setProgress:currentProgress animated:YES];
                }
            }
        }
        
    };
}
//播放状态监听回调
- (void)playerStatusObserver {
    
    __weak typeof(self) weakSelf = self;
    self.player.playerStatusObserverBlock = ^(AVPlayerItemStatus status) {
        switch (status) {
            case AVPlayerItemStatusReadyToPlay:
            {
                NSLog(@"准备播放");
                // 开始播放
                [weakSelf.player play];
                weakSelf.bottomView.playButton.selected = YES;
                CMTime duration = weakSelf.player.duration;
                NSInteger durationSec = duration.value / duration.timescale;
                weakSelf.bottomView.durationLabel.text = [weakSelf getMMSSFromSS:durationSec];
            }
                break;
            case AVPlayerItemStatusFailed:
            {
                NSLog(@"加载失败");
            }
                break;
            case AVPlayerItemStatusUnknown:
            {
                NSLog(@"未知资源");
            }
                break;
            default:
                break;
        }
    };
}
//本次缓冲范围监听回调
- (void)playerLoadedTimeRangesObserver {
    
    __weak typeof(self) weakSelf = self;
    self.player.playerLoadedTimeRangesObserverBlock = ^(NSArray *array) {
        //本次缓冲时间范围
        CMTimeRange timeRange = [array.firstObject CMTimeRangeValue];
        float startSeconds = CMTimeGetSeconds(timeRange.start);
        float durationSeconds = CMTimeGetSeconds(timeRange.duration);
        //缓冲总长度
        NSTimeInterval totalBuffer = startSeconds + durationSeconds;
        
        if (weakSelf.player.duration.value) {
            
            CMTime duration = weakSelf.player.duration;
            NSInteger durationSec = duration.value / duration.timescale;
            [weakSelf.bottomView.progressView setProgress:(totalBuffer/durationSec) animated:YES];
        }
    };
}
//播放完成监听回调
- (void)playerDidPlayToEndTime {
    
    __weak typeof(self) weakSelf = self;
    self.player.playerDidPlayToEndTimeBlock = ^(NSNotification *notification) {
        NSLog(@"播放完成");
        if (weakSelf.playerDidPlayToEndTimeBlock) {
            weakSelf.playerDidPlayToEndTimeBlock(notification);
        }
    };
}

- (void)setURL:(NSURL *)URL {
    _URL = URL;
    
    self.player.URL = URL;
}

- (void)addTimingMethod {
    [self cancleTimingMethod];
    [self performSelector:@selector(hiddenTiming) withObject:@"hidden" afterDelay:HiddenLimit];
}

- (void)cancleTimingMethod {
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hiddenTiming) object:@"hidden"];
}

- (void)hiddenTiming {
    NSLog(@"hidden");
    [self hiddenControlView];
}

- (void)showControlView {
    [self addTimingMethod];
    [UIView animateWithDuration:0.3 animations:^{
        
        self.topView.alpha = 1.0;
        self.bottomView.alpha = 1.0;
    }];
}

- (void)hiddenControlView {
    [self cancleTimingMethod];
    [UIView animateWithDuration:0.3 animations:^{
        
        self.topView.alpha = 0.0;
        self.bottomView.alpha = 0.0;
    }];
}

- (JTPlayer *)player {
    if (!_player) {
        _player = [[JTPlayer alloc] init];
    }
    return _player;
}

- (JTPlayerBottomView *)bottomView {
    if (!_bottomView) {
        _bottomView = [[[NSBundle mainBundle] loadNibNamed:@"JTPlayerBottomView" owner:self options:nil] firstObject];
        self.fullScreenButton = _bottomView.fullScreenButton;
    }
    return _bottomView;
}

- (JTPlayerTopView *)topView {
    if (!_topView) {
        _topView = [[[NSBundle mainBundle] loadNibNamed:@"JTPlayerTopView" owner:self options:nil] firstObject];
    }
    return _topView;
}

-(NSString *)getHHMMSSFromSS:(NSInteger)totalTime{
    
    NSInteger seconds = totalTime;
    NSString *str_hour = [NSString stringWithFormat:@"%02ld",seconds/3600];
    NSString *str_minute = [NSString stringWithFormat:@"%02ld",(seconds%3600)/60];
    NSString *str_second = [NSString stringWithFormat:@"%02ld",seconds%60];
    NSString *format_time = [NSString stringWithFormat:@"%@:%@:%@",str_hour,str_minute,str_second];
    return format_time;
}
-(NSString *)getMMSSFromSS:(NSInteger)totalTime{
    
    NSInteger seconds = totalTime;
    NSString *str_minute = [NSString stringWithFormat:@"%02ld",seconds/60];
    NSString *str_second = [NSString stringWithFormat:@"%02ld",seconds%60];
    NSString *format_time = [NSString stringWithFormat:@"%@:%@",str_minute,str_second];
    return format_time;
}

@end
