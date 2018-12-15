//
//  UIViewController+Category.m
//  JTPlayerView
//
//  Created by xujiangtao on 2018/12/14.
//  Copyright © 2018年 xujiangtao. All rights reserved.
//

#import "UIViewController+Category.h"
#import "UIView+Extension.h"
#import <objc/runtime.h>
#import "JTPlayerView.h"

@implementation UIViewController (Category)

- (NSInteger)getNavigationBarHeght {
    return self.navigationController.navigationBar.height;
}

- (NSInteger)getNavigationBarAndStatusBarHeight {
    for (UIView *view in self.navigationController.navigationBar.subviews) {
        
        if ([NSStringFromClass([view class]) isEqualToString:@"_UIBarBackground"]) {
            return view.height;
        }
    }
    return 64;
}

- (NSInteger)getStatusBarHeight {
    return [self getNavigationBarAndStatusBarHeight] - [self getNavigationBarHeght];
}

+ (void)load {
    
    //原本的viewWillAppear方法
    Method viewWillAppear = class_getInstanceMethod(self, @selector(viewWillAppear:));
    //需要替换成 能够输出日志的viewWillAppear
    Method logViewWillAppear = class_getInstanceMethod(self, @selector(logViewWillAppear:));
    //两方法进行交换
    method_exchangeImplementations(viewWillAppear, logViewWillAppear);
    
    
    Method viewDidLoad = class_getInstanceMethod(self, @selector(viewDidLoad));
    Method logViewDidLoad = class_getInstanceMethod(self, @selector(logViewDidLoad));
    method_exchangeImplementations(viewDidLoad, logViewDidLoad);
    
    Method viewWillDisappear = class_getInstanceMethod(self, @selector(viewWillDisappear:));
    Method logViewWillDisappear = class_getInstanceMethod(self, @selector(logViewWillDisappear:));
    method_exchangeImplementations(viewWillDisappear, logViewWillDisappear);
}

- (void)logViewWillAppear:(BOOL)animated {
//    NSString *className = NSStringFromClass([self class]);
//    NSLog(@"%@ viewWillAppear", className);
    
    [self logViewWillAppear:animated];
}

- (void)logViewDidLoad {
//    NSString *className = NSStringFromClass([self class]);
//    NSLog(@"%@ viewDidLoad", className);
    
    [self logViewDidLoad];
}

- (void)logViewWillDisappear:(BOOL)animated {
//    NSString *className = NSStringFromClass([self class]);
//    NSLog(@"%@ viewWillDisappear", className);
    
    for (UIView *view in self.view.subviews) {
        if ([NSStringFromClass([view class]) isEqualToString:@"JTPlayerView"]) {
            JTPlayerView *playerView = (JTPlayerView *)view;
            [playerView cancleTimingMethod];
        }
    }
    
    [self logViewWillDisappear:animated];
}


@end
