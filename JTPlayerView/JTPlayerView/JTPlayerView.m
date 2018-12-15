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
#import "JTPlayerBottomSimpleView.h"
#import "JTPlayerTopView.h"
#import "CenterControlSimpleView.h"
#import "UIView+Extension.h"
#import "RotationScreen.h"

@interface JTPlayerView ()

@property (nonatomic, strong) JTPlayerBottomView *bottomView;
@property (nonatomic, strong) JTPlayerBottomSimpleView *bottomSimpleView;

@property (nonatomic, strong) JTPlayerTopView *topView;

@property (nonatomic, strong) CenterControlSimpleView *centerSimpleView;

@property (nonatomic, strong) JTPlayer *AVPlayerView;
//是否在拖动点,用来防止小圆点随时间跳动
@property (nonatomic, assign) BOOL isPanPoint;

//是否显示/隐藏控制view
@property (nonatomic, assign) BOOL isShowControlView;

@property (nonatomic, strong) UIView *controlBgView;

#pragma mark - 将controlView的属性在创建时赋值给self,以免判断style
@property (nonatomic, strong) UIButton *playButton;//播放按钮
@property (nonatomic, strong) UIProgressView *currentPlayProgress;//当前播放进度
@property (nonatomic, strong) UIProgressView *bufferProgressView;//缓冲进度
@property (nonatomic, strong) UIButton *fullScreenButton;
@end

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
        [self addNotification];
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
        [self addNotification];
    }
    return self;
}

- (void)createPlayerView {
    
    //player
    [self addSubview:self.AVPlayerView];
    [self.AVPlayerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.bottom.equalTo(self);
    }];
    //放各种控制的view
    self.controlBgView = [[UIView alloc] initWithFrame:CGRectZero];
    [self addSubview:self.controlBgView];
    
    [self.controlBgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.bottom.equalTo(self).priorityHigh();
    }];
    
    //播放器播放时间监听回调
    [self playerTimeObserver];
    //播放状态监听回调
    [self playerStatusObserver];
    //本次缓冲范围监听回调
    [self playerLoadedTimeRangesObserver];
    //播放完成监听回调
    [self playerDidPlayToEndTime];
    //添加远程控制回调
    [self remoteEvent];
}

- (void)defaultSetting {
    self.playerControlStyle = PlayerControlStyleDefault;
    self.isShowControlView = YES;
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
//创建默认UI---default
- (void)createDefaultViews {
    
    __weak typeof(self) weakSelf = self;
    //上方的view
    [self.controlBgView addSubview:self.topView];
    [self.topView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.right.equalTo(self.controlBgView);
        make.height.mas_equalTo(64);
    }];
    
    self.topView.backButtonClickBlock = ^(UIButton *sender) {
        if (weakSelf.backButtonClickBlock) {
            weakSelf.backButtonClickBlock(sender);
        }
        [RotationScreen forceOrientation:(UIInterfaceOrientationPortrait)];
    };
    
    //下方的view
    [self.controlBgView addSubview:self.bottomView];
    [self.bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.controlBgView);
        make.height.mas_equalTo(44);
        if (@available(iOS 11.0, *)) {
            make.bottom.equalTo(self.controlBgView.mas_safeAreaLayoutGuideBottom);
        } else {
            make.bottom.equalTo(self.controlBgView);
        }
    }];
    
    self.bottomView.playButtonClickBlock = ^(UIButton *sender) {
        if (!sender.selected) {
            [weakSelf play];
        }else {
            [weakSelf pause];
        }
    };
    
    self.bottomView.fullScreenButtonClickBlock = ^(UIButton *sender) {
        [weakSelf fullScreenClick:sender];
    };
    
    self.bottomView.pointPanClock = ^(UIPanGestureRecognizer *pan) {
        
        if (pan.state == UIGestureRecognizerStateBegan) {
            
            weakSelf.isPanPoint = YES;
            [weakSelf cancleTimingMethod];
        }else if (pan.state == UIGestureRecognizerStateChanged) {
            
            CMTime duration = weakSelf.AVPlayerView.duration;
            float durationSec = duration.value / duration.timescale;
            NSInteger sec = weakSelf.bottomView.sliderProgress.progress * durationSec;
            weakSelf.bottomView.currentTimeLabel.text = [weakSelf getMMSSFromSS:sec];
            
        }else if (pan.state == UIGestureRecognizerStateEnded) {
            
            NSInteger durationSec = CMTimeGetSeconds(weakSelf.AVPlayerView.duration);
            NSInteger sec = weakSelf.bottomView.sliderProgress.progress * durationSec;
            CMTime time = CMTimeMake(sec, 1);
            [weakSelf.AVPlayerView seekToTime:time completionHandler:^(BOOL finished) {
                
                weakSelf.isPanPoint = NO;
                [weakSelf addTimingMethod];
            }];
            
        }
    };
    
    [self addTimingMethod];
}
//创建简单UI
- (void)createSimpleViews {
    
    [self.controlBgView addSubview:self.bottomSimpleView];
    [self.bottomSimpleView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self.controlBgView);
        make.height.mas_equalTo(44);
    }];
    
    __weak typeof(self) weakSelf = self;
    self.bottomSimpleView.fullScreenButtonClickBlock = ^(UIButton *sender) {
        [weakSelf fullScreenClick:sender];
    };
    
    [self.controlBgView addSubview:self.centerSimpleView];
    [self.centerSimpleView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.controlBgView);
        make.width.height.mas_equalTo(48);
    }];
    
    self.centerSimpleView.playButtonClickBlock = ^(UIButton *sender) {
        if (!sender.selected) {
            [weakSelf play];
        }else {
            [weakSelf pause];
        }
    };
}

- (void)fullScreenClick:(UIButton *)sender {
    if ([RotationScreen isOrientationLandscape]) { // 如果是横屏，
        [RotationScreen forceOrientation:(UIInterfaceOrientationPortrait)]; // 切换为竖屏
    } else {
        [RotationScreen forceOrientation:(UIInterfaceOrientationLandscapeRight)]; // 否则，切换为横屏
    }
}

- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection {
    [super traitCollectionDidChange:previousTraitCollection];
    
    // 横竖屏切换时重新添加约束
    CGRect bounds = [UIScreen mainScreen].bounds;
    
    if ([RotationScreen isOrientationLandscape]) { // 竖屏
        self.fullScreenButton.selected = YES;
        NSLog(@"横屏");
        [self mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.left.equalTo(@(0));
            make.width.equalTo(@(bounds.size.width));
            make.height.equalTo(@(bounds.size.height));
        }];
    } else { // 横屏
        self.fullScreenButton.selected = NO;
        NSLog(@"竖屏");
        if (self.orientationPortraitBlock) {
            self.orientationPortraitBlock(self);
        }
    }
}

//隐藏显示方法
- (void)addHiddenGesture {
    
    self.userInteractionEnabled = YES;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hiddenTap:)];
    [self addGestureRecognizer:tap];
}

- (void)hiddenTap:(UITapGestureRecognizer *)tap {
    
    if (self.isShowControlView) {
        [self hiddenControlView];
    }else {
        [self showControlView];
        
    }
    if (self.hiddenTapBlock) {
        self.hiddenTapBlock(self.isShowControlView);
    }
}

- (void)addNotification {
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self
               selector:@selector(appDidEnterBackgroundNotification)
                   name:UIApplicationDidEnterBackgroundNotification
                 object:nil];
    [center addObserver:self
               selector:@selector(appWillEnterForegroundNotification)
                   name:UIApplicationWillEnterForegroundNotification
                 object:nil];
}
- (void)removeNotification {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
- (void)appDidEnterBackgroundNotification {
    
    if (self.playInTheBackground) {
        self.AVPlayerView.playerLayer.player = nil;
    }else {
        [self pause];
    }
}
- (void)appWillEnterForegroundNotification {
    
    if (self.playInTheBackground) {
        self.AVPlayerView.playerLayer.player = self.AVPlayerView.player;
    }else {
        [self play];
    }
}

////播放时间监听回调
- (void)playerTimeObserver {
    
    __weak typeof(self) weakSelf = self;
    self.AVPlayerView.playerTimeObserverBlock = ^(CMTime time) {
        
        if (!weakSelf.isPanPoint) {
            float sec = time.value / time.timescale;
            weakSelf.bottomView.currentTimeLabel.text = [weakSelf getMMSSFromSS:sec];
        
            if (weakSelf.AVPlayerView.duration.value) {
                
                CMTime duration = weakSelf.AVPlayerView.duration;
                float durationSec = duration.value / duration.timescale;
                float currentProgress = sec / durationSec;
                if (currentProgress > 0.01) {
                    
                    [weakSelf.currentPlayProgress setProgress:currentProgress animated:YES];
                }
            }
        }
    };
}
//播放状态监听回调
- (void)playerStatusObserver {
    
    __weak typeof(self) weakSelf = self;
    self.AVPlayerView.playerStatusObserverBlock = ^(AVPlayerItemStatus status) {
        switch (status) {
            case AVPlayerItemStatusReadyToPlay:
            {
                NSLog(@"准备播放");
                // 开始播放
                [weakSelf play];
                NSInteger durationSec = CMTimeGetSeconds(weakSelf.AVPlayerView.duration);
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
    self.AVPlayerView.playerLoadedTimeRangesObserverBlock = ^(NSArray *array) {
        //本次缓冲时间范围
        CMTimeRange timeRange = [array.firstObject CMTimeRangeValue];
        float startSeconds = CMTimeGetSeconds(timeRange.start);
        float durationSeconds = CMTimeGetSeconds(timeRange.duration);
        //缓冲总长度
        NSTimeInterval totalBuffer = startSeconds + durationSeconds;
        
        if (weakSelf.AVPlayerView.duration.value) {
            
            NSInteger durationSec = CMTimeGetSeconds(weakSelf.AVPlayerView.duration);
            [weakSelf.bufferProgressView setProgress:(totalBuffer/durationSec) animated:YES];
        }
    };
}
//播放完成监听回调
- (void)playerDidPlayToEndTime {
    
    __weak typeof(self) weakSelf = self;
    self.AVPlayerView.playerDidPlayToEndTimeBlock = ^(NSNotification *notification) {
        NSLog(@"播放完成");
        [weakSelf pause];
        if (weakSelf.playerDidPlayToEndTimeBlock) {
            weakSelf.playerDidPlayToEndTimeBlock(notification);
        }
    };
}
//添加远程控制回调
- (void)remoteEvent {
    
    __weak typeof(self) weakSelf = self;
    self.AVPlayerView.remotePlayEventBlock = ^{
        [weakSelf play];
    };
    self.AVPlayerView.remotePauseEventBlock = ^{
        [weakSelf pause];
    };
}

- (void)setURL:(NSURL *)URL {
    _URL = URL;
    
    self.AVPlayerView.URL = URL;
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
    if (self.autoHiddenBlock) {
        self.autoHiddenBlock(self.isShowControlView);
    }
}

- (void)showControlView {
    
    self.isShowControlView = YES;
    [self addTimingMethod];
    [UIView animateWithDuration:0.3 animations:^{
        
        switch (self.playerControlStyle) {
            case PlayerControlStyleDefault:
                
                self.topView.alpha = 1.0;
                self.bottomView.alpha = 1.0;
                break;
            case PlayerControlStyleSimple:
                
                self.bottomSimpleView.alpha = 1.0;
                self.centerSimpleView.alpha = 1.0;
                break;
            default:
                break;
        }
    }];
}

- (void)hiddenControlView {
    
    self.isShowControlView = NO;
    [self cancleTimingMethod];
    [UIView animateWithDuration:0.3 animations:^{
        
        switch (self.playerControlStyle) {
            case PlayerControlStyleDefault:
                
                self.topView.alpha = 0.0;
                self.bottomView.alpha = 0.0;
                break;
            case PlayerControlStyleSimple:
                
                self.bottomSimpleView.alpha = 0.0;
                self.centerSimpleView.alpha = 0.0;
                break;
            default:
                break;
        }
    }];
}

- (void)play {
    self.playButton.selected = YES;
    [self.AVPlayerView play];
}

- (void)pause {
    self.playButton.selected = NO;
    [self.AVPlayerView pause];
}

//跳到结束位置
- (void)forwardPlaybackEndTime {
    [self.AVPlayerView.player.currentItem forwardPlaybackEndTime];
}
//跳到开始位置
- (void)reversePlaybackEndTime {
    [self.AVPlayerView.player.currentItem reversePlaybackEndTime];
}

- (JTPlayer *)AVPlayerView {
    if (!_AVPlayerView) {
        _AVPlayerView = [[JTPlayer alloc] init];
    }
    return _AVPlayerView;
}

- (JTPlayerBottomView *)bottomView {
    if (!_bottomView) {
        _bottomView = [[[NSBundle mainBundle] loadNibNamed:@"JTPlayerBottomView" owner:self options:nil] firstObject];
        self.fullScreenButton = _bottomView.fullScreenButton;
        self.playButton = _bottomView.playButton;
        self.currentPlayProgress = _bottomView.sliderProgress;
        self.bufferProgressView = _bottomView.progressView;
    }
    return _bottomView;
}

- (JTPlayerBottomSimpleView *)bottomSimpleView {
    if (!_bottomSimpleView) {
        _bottomSimpleView = [[[NSBundle mainBundle] loadNibNamed:@"JTPlayerBottomSimpleView" owner:self options:nil] firstObject];
        self.fullScreenButton = _bottomSimpleView.fullScreenButton;
        self.currentPlayProgress = _bottomSimpleView.currentPlayProgress;
        self.bufferProgressView = _bottomSimpleView.progressView;
    }
    return _bottomSimpleView;
}

- (JTPlayerTopView *)topView {
    if (!_topView) {
        _topView = [[[NSBundle mainBundle] loadNibNamed:@"JTPlayerTopView" owner:self options:nil] firstObject];
    }
    return _topView;
}

- (CenterControlSimpleView *)centerSimpleView {
    if (!_centerSimpleView) {
        _centerSimpleView = [[[NSBundle mainBundle] loadNibNamed:@"CenterControlSimpleView" owner:self options:nil] firstObject];
        self.playButton = _centerSimpleView.playButton;
    }
    return _centerSimpleView;
}

- (void)setPlayInTheBackground:(BOOL)playInTheBackground {
    _playInTheBackground = playInTheBackground;
    self.AVPlayerView.playInTheBackground = playInTheBackground;
}

- (void)setTitle:(NSString *)title {
    _title = title;
    self.AVPlayerView.title = title;
}

- (NSString *)getHHMMSSFromSS:(NSInteger)totalTime {
    
    NSInteger seconds = totalTime;
    NSString *str_hour = [NSString stringWithFormat:@"%02ld",seconds/3600];
    NSString *str_minute = [NSString stringWithFormat:@"%02ld",(seconds%3600)/60];
    NSString *str_second = [NSString stringWithFormat:@"%02ld",seconds%60];
    NSString *format_time = [NSString stringWithFormat:@"%@:%@:%@",str_hour,str_minute,str_second];
    return format_time;
}
- (NSString *)getMMSSFromSS:(NSInteger)totalTime {
    
    NSInteger seconds = totalTime;
    NSString *str_minute = [NSString stringWithFormat:@"%02ld",seconds/60];
    NSString *str_second = [NSString stringWithFormat:@"%02ld",seconds%60];
    NSString *format_time = [NSString stringWithFormat:@"%@:%@",str_minute,str_second];
    return format_time;
}

- (void)dealloc {
    NSLog(@"JTPlayerView---dealloc");
    [self removeNotification];
}

@end
