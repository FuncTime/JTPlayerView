//
//  JTPlayerBottomView.m
//  JTPlayerView
//
//  Created by xujiangtao on 2018/12/11.
//  Copyright © 2018年 xujiangtao. All rights reserved.
//

#import "JTPlayerBottomView.h"
#import "CustomSliderView.h"

@interface JTPlayerBottomView ()

@property (nonatomic, strong) CustomSliderView *customSlider;

@end

@implementation JTPlayerBottomView

- (void)awakeFromNib {
    [super awakeFromNib];
    
    __weak typeof(self) weakSelf = self;
    self.customSlider = [[CustomSliderView alloc] init];
    self.sliderProgress = self.customSlider.sliderProgress;
    [self addSubview:self.customSlider];
    [self.customSlider mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.progressView);
        make.height.mas_equalTo(20);
        make.width.equalTo(self.progressView);
    }];
    
    self.customSlider.pointPanBlock = ^(UIPanGestureRecognizer *pan) {
        if (weakSelf.pointPanClock) {
            weakSelf.pointPanClock(pan);
        }
    };
}

- (IBAction)playButtonClick:(UIButton *)sender {
    if (self.playButtonClickBlock) {
        self.playButtonClickBlock(sender);
    }
}
- (IBAction)fullScreenButtonClick:(UIButton *)sender {
    if (self.fullScreenButtonClickBlock) {
        self.fullScreenButtonClickBlock(sender);
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
