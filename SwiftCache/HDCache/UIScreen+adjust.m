//
//  UIScreen+adjust.m
//  BTSDK
//
//  Created by zhangyuhe on 16/4/19.
//  Copyright © 2016年 BT. All rights reserved.
//

#import "UIScreen+adjust.h"
//判断版本是否低于ios
#define IOS_BELOW_8 (([UIDevice currentDevice].systemVersion.floatValue < 8.0)? (YES):(NO))
//屏幕方向
#define AppOrientation [UIApplication sharedApplication].statusBarOrientation
//判断是否是ios7横屏
#define ios7Landscape (((AppOrientation == UIInterfaceOrientationLandscapeLeft || AppOrientation ==UIInterfaceOrientationLandscapeRight) && IOS_BELOW_8)? YES: NO)

@implementation UIScreen (adjust)

- (CGRect)adjustBounds {
    CGFloat MainScreenW = [self adjustWidth];
    CGFloat MainScreenH = [self adjustHeight];
    return CGRectMake(0, 0, MainScreenW, MainScreenH);
}

- (CGFloat)adjustWidth {
    if (ios7Landscape) {
        return self.bounds.size.height;
    } else {
        return self.bounds.size.width;
    }
}
- (CGFloat)adjustHeight {
    if (ios7Landscape) {
        return self.bounds.size.width;
    } else {
        return self.bounds.size.height;
    }
}

- (CGPoint)adjustCenter {
    CGFloat MainScreenW = [self adjustWidth];
    CGFloat MainScreenH = [self adjustHeight];
    return CGPointMake(MainScreenW * 0.5, MainScreenH * 0.5);
}

- (CGFloat)adjustCenterX {
    
    return [self adjustWidth] * 0.5;
}


- (CGFloat)adjustCenterY {
    
    return [self adjustHeight] * 0.5;
}
@end
