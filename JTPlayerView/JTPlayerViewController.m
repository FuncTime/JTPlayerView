//
//  JTPlayerViewController.m
//  JTPlayerView
//
//  Created by xujiangtao on 2018/12/11.
//  Copyright © 2018年 xujiangtao. All rights reserved.
//

#import "JTPlayerViewController.h"
#import "JTPlayerView.h"
#import "UIView+Extension.h"
#import "UIViewController+Category.h"
#import "AppDelegate.h"

@interface JTPlayerViewController ()

@property (nonatomic, strong) JTPlayerView *player;

@property (nonatomic, assign) BOOL hiddenStatusBar;

@end

@implementation JTPlayerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    
    __weak typeof(self) weakSelf = self;
    
    UIView *statusBarView = [[UIView alloc] initWithFrame:CGRectZero];
    statusBarView.backgroundColor = [UIColor blackColor];
    [self.view addSubview:statusBarView];
    [statusBarView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.equalTo(self.view);
        make.height.mas_equalTo([self getStatusBarHeight]);
    }];
    [self.view sendSubviewToBack:statusBarView];
    
    self.player = [JTPlayerView playerWithURL:[NSURL URLWithString:@"http://wvideo.spriteapp.cn/video/2016/0328/56f8ec01d9bfe_wpd.mp4"]];
    self.player.backgroundColor = [UIColor blackColor];
//    self.player.playerControlStyle = PlayerControlStyleSimple;
    self.player.playInTheBackground = YES;
//    self.player.title = @"哈哈哈哈哈";
    [self.view addSubview:self.player];
    
    self.player.orientationPortraitBlock = ^(JTPlayerView *playerView) {
        [playerView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo([weakSelf getStatusBarHeight] > 20 ? [weakSelf getStatusBarHeight] - 20 : 0);
            make.left.equalTo(@(0));
            make.width.equalTo(@(SCREEN_WIDTH));
            make.height.equalTo(weakSelf.view.mas_width).multipliedBy(9.0/16.0);
        }];
    };
    
    self.player.backButtonClickBlock = ^(UIButton *sender) {
        
        if ([UIDevice currentDevice].orientation == UIInterfaceOrientationPortrait) {
            [weakSelf.navigationController popViewControllerAnimated:YES];
        }
    };
    
    self.player.hiddenTapBlock = ^(BOOL isShowControlView) {
        weakSelf.hiddenStatusBar = !isShowControlView;
        [UIView animateWithDuration:0.3 animations:^{
            [weakSelf setNeedsStatusBarAppearanceUpdate];
        }];
    };
    self.player.autoHiddenBlock = ^(BOOL isShowControlView) {
        weakSelf.hiddenStatusBar = !isShowControlView;
        [UIView animateWithDuration:0.3 animations:^{
            [weakSelf setNeedsStatusBarAppearanceUpdate];
        }];
    };
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    appDelegate.allowRotation = YES;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    appDelegate.allowRotation = NO;
}

- (BOOL)prefersStatusBarHidden{
    return self.hiddenStatusBar;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (UIStatusBarAnimation )preferredStatusBarUpdateAnimation {
    return UIStatusBarAnimationFade;
}

- (void)dealloc {
    NSLog(@"JTPlayerViewController---dealloc");
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
