//
//  StatusItemCellPro.h
//  WeiTansuo
//
//  Created by CMD on 9/20/11.
//  Copyright 2011 Invidel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UrlImageView.h"
#import "BigImageViewController.h"
#import <QuartzCore/QuartzCore.h>

@interface StatusItemCellPro : UITableViewCell
{
    UILabel * mContentView;
    UILabel * mTimeLabel;
    UILabel * mRelativeLocation;
    UrlImageView * mMiddlePicView;
    UIView * mBtmRightCornerView;  
    
    UIView * mReTeweetView;
    UILabel * mOrigialName;
    UILabel * mOrigialContent;
    UrlImageView * mOrigialSmallPic;
    BOOL mIsRetwwet;
    NSString * mMiddlePicUrl;
    NSString * mOrigialPicUrl;
    
}

- (CGFloat) getCellHeight;
- (void) resetMiddlePicImage;
- (void) resetOrigialSmallPicImage;

@property (nonatomic,assign) id bigImgTarget;
@property (nonatomic,assign) SEL showBigImgAction;
@property (nonatomic, retain) UILabel * cellContentView;
@property (nonatomic, retain) UILabel * timeLabel;
@property (nonatomic, retain) UILabel * relativeLocation;
@property (nonatomic, retain) UrlImageView * middlePicView;
@property (nonatomic, retain) UIView * btmRightCornerView;
@property (nonatomic, retain) UIView * reTeweetView;
@property (nonatomic, retain) UILabel * origialName;
@property (nonatomic, retain) UILabel * origialContent;
@property (nonatomic, retain) UrlImageView * origialSmallPic;
@property (nonatomic, assign) BOOL isRetweet;
@property (nonatomic, retain) NSString * middlePicUrl;
@property (nonatomic, retain) NSString * origialPicUrl;

@end
