//
//  JTPlayerView.h
//  JTPlayerView
//
//  Created by xujiangtao on 2018/12/11.
//  Copyright © 2018年 xujiangtao. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JTPlayerView : UIView

//全屏按钮点击回调
@property (nonatomic, copy) void(^fullScreenButtonClickBlock)(UIButton *sender);
//播放完成监听回调
@property (nonatomic, copy) void(^playerDidPlayToEndTimeBlock)(NSNotification *notification);

@property (nonatomic, strong) NSURL *URL;

+ (instancetype)playerWithURL:(NSURL *)URL;

- (instancetype)initWithPlayerURL:(NSURL *)URL;


@end
