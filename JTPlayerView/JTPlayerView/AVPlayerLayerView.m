//
//  AVPlayerLayerView.m
//  JTPlayerView
//
//  Created by xujiangtao on 2018/12/11.
//  Copyright © 2018年 xujiangtao. All rights reserved.
//

#import "AVPlayerLayerView.h"
#import <AVFoundation/AVFoundation.h>

@implementation AVPlayerLayerView

+ (Class)layerClass {
    return [AVPlayerLayer class];
}

- (void)dealloc {
    NSLog(@"AVPlayerLayerViewDealloc");
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
