//
//  CenterControlSimpleView.h
//  JTPlayerView
//
//  Created by xujiangtao on 2018/12/13.
//  Copyright © 2018年 xujiangtao. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CenterControlSimpleView : UIView

@property (nonatomic, copy) void(^playButtonClickBlock)(UIButton *sender);

@property (weak, nonatomic) IBOutlet UIButton *playButton;

@end
