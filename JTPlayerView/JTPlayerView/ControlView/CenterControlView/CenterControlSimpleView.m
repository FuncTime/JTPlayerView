//
//  CenterControlSimpleView.m
//  JTPlayerView
//
//  Created by xujiangtao on 2018/12/13.
//  Copyright © 2018年 xujiangtao. All rights reserved.
//

#import "CenterControlSimpleView.h"

@implementation CenterControlSimpleView
- (IBAction)playButtonClick:(UIButton *)sender {
    if (self.playButtonClickBlock) {
        self.playButtonClickBlock(sender);
    }
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
