//
//  AppDelegate.h
//  JTPlayerView
//
//  Created by xujiangtao on 2018/12/11.
//  Copyright © 2018年 xujiangtao. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
/***  是否允许横屏的标记 */
@property (nonatomic,assign) BOOL allowRotation;

@end

