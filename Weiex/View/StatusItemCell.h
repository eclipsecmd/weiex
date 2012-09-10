//
//  StatusItemCell.h
//  WeiTansuo/Users/hyq/Documents/xcode/WeiTansuo-IOS/WeiTansuo.xcodeproj
//
//  Created by Tu Jianfeng on 8/7/11.
//  Copyright 2011 Invidel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

#import "UrlImageView.h"
#import "ClickImageView.h"
#import "BasicCell.h"

@interface StatusItemCell : BasicCell

- (CGFloat) getCellHeight;
- (void) resetMiddlePicImage;

@end
