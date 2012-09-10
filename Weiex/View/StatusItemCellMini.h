//
//  StatusItemCellMini.h
//  WeiTansuo
//
//  Created by CMD on 10/5/11.
//  Copyright 2011 Invidel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UrlImageView.h"
#import <QuartzCore/QuartzCore.h>

@interface StatusItemCellMini : UITableViewCell
{
    UILabel * mUserName;
    UILabel * mContentView;
    UILabel * mTimeLabel;
    UILabel * mRelativeLocation;
    UrlImageView * mMiddlePicView;
    UrlImageView * mUserPicView;
    UIView * mBtmRightCornerView;  
    UIImageView * mRelativeLocationImage;
    UIImageView * mTimeLabelImage;
}

@property (nonatomic, retain) UILabel * userName;
@property (nonatomic, retain) UILabel * cellContentView;
@property (nonatomic, retain) UILabel * timeLabel;
@property (nonatomic, retain) UILabel * relativeLocation;
@property (nonatomic, retain) UrlImageView * middlePicView;
@property (nonatomic, retain) UrlImageView * userPicView;
@property (nonatomic, retain) UIView * btmRightCornerView;

- (CGFloat) getCellHeight;
- (void) resetMiddlePicImage;

@end
