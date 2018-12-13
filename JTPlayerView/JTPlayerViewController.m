//
//  JTPlayerViewController.m
//  JTPlayerView
//
//  Created by xujiangtao on 2018/12/11.
//  Copyright © 2018年 xujiangtao. All rights reserved.
//

#import "JTPlayerViewController.h"
#import "JTPlayerView.h"

@interface JTPlayerViewController ()

@property (nonatomic, strong) JTPlayerView *player;

@end

@implementation JTPlayerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    
    //    [self.navigationController setNavigationBarHidden:YES animated:YES];
    
    __weak typeof(self) weakSelf = self;
    
    self.player = [JTPlayerView playerWithURL:[NSURL URLWithString:@"http://wvideo.spriteapp.cn/video/2016/0328/56f8ec01d9bfe_wpd.mp4"]];
    self.player.backgroundColor = [UIColor blackColor];
    [self.view addSubview:self.player];
    [self.player mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.top.equalTo(self.view).offset(64);
        make.height.mas_equalTo(self.view.mas_width).multipliedBy(9.0/16.0);
    }];
    
    self.player.fullScreenButtonClickBlock = ^(UIButton *sender) {
        if ([UIDevice currentDevice].orientation == UIInterfaceOrientationPortrait) {
            
            [weakSelf interfaceOrientation:UIInterfaceOrientationLandscapeRight];
        }else {
            
            [weakSelf interfaceOrientation:UIInterfaceOrientationPortrait];
        }
    };
}

// 强制转屏
- (void)interfaceOrientation:(UIInterfaceOrientation)orientation
{
    if ([[UIDevice currentDevice] respondsToSelector:@selector(setOrientation:)]) {
        SEL selector  = NSSelectorFromString(@"setOrientation:");
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[UIDevice instanceMethodSignatureForSelector:selector]];
        [invocation setSelector:selector];
        [invocation setTarget:[UIDevice currentDevice]];
        int val = orientation;
        // 从2开始是因为0 1 两个参数已经被selector和target占用
        [invocation setArgument:&val atIndex:2];
        [invocation invoke];
    }
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
