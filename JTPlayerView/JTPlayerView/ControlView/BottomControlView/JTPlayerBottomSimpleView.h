//
//  JTPlayerBottomSimpleView.h
//  JTPlayerView
//
//  Created by xujiangtao on 2018/12/13.
//  Copyright © 2018年 xujiangtao. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JTPlayerBottomSimpleView : UIView

@property (nonatomic, copy) void(^fullScreenButtonClickBlock)(UIButton *sender);

@property (weak, nonatomic) IBOutlet UIProgressView *progressView;
@property (weak, nonatomic) IBOutlet UIButton *fullScreenButton;
@property (weak, nonatomic) IBOutlet UIProgressView *currentPlayProgress;

@end
