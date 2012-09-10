//
//  StatusItemLeftCell.h
//  WeiTansuo
//
//  Created by hyq on 10/22/11.
//  Copyright 2011 Invidel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

#import "UrlImageView.h"
#import "BasicCell.h"

@interface StatusItemLeftCell : BasicCell

- (CGFloat) getCellHeight;
//- (void) resetMiddlePicImage;
- (void)showBigImage;
@end
