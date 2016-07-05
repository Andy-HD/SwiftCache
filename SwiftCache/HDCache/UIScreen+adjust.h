//
//  UIScreen+adjust.h
//  BTSDK
//
//  Created by zhangyuhe on 16/4/19.
//  Copyright © 2016年 BT. All rights reserved.
//

#import <UIKit/UIKit.h>
@interface UIScreen (adjust)

- (CGRect)adjustBounds;
- (CGPoint)adjustCenter;

- (CGFloat)adjustWidth;
- (CGFloat)adjustHeight;

- (CGFloat)adjustCenterX;
- (CGFloat)adjustCenterY;

@end
