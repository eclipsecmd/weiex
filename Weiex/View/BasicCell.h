//
//  BasicCell.h
//  WeiTansuo
//
//  Created by hyq on 10/29/11.
//  Copyright 2011 Invidel. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "UrlImageView.h"

@interface BasicCell : UITableViewCell {
    UILabel * mUserName;
    UILabel * mContentView;
    UILabel * mTimeLabel;
    UILabel * mRelativeLocation;
    UrlImageView * mMiddlePicView;
    UrlImageView * mUserPicView;
    UIView * mBtmRightCornerView;  
    UIImageView * mRelativeLocationImage;
    UIImageView * mTimeLabelImage;
    NSString * mBmiddlePicUrl;
    
    id bigImgTarget;
    SEL showBigImgAction;
    
    //add by max
    UIView * mImgArea;    
    UrlImageView * mStatusImgOne;
    UrlImageView * mStatusImgTwo;
    UrlImageView * mStatusImgThree;   
    
    //add by max 大图列表加星
    UIImageView * mStarOptImage;
    UILabel     * mStarAmount;
//    UIImageView * mViewHisImage;
//    UILabel     * mViewAmount;
}

@property (nonatomic, assign) id bigImgTarget;
@property (nonatomic, assign) SEL showBigImgAction;
@property (nonatomic, retain) UILabel * userName;
@property (nonatomic, retain) UILabel * cellContentView;
@property (nonatomic, retain) UILabel * timeLabel;
@property (nonatomic, retain) UILabel * relativeLocation;
@property (nonatomic, retain) UrlImageView * middlePicView;
@property (nonatomic, retain) UrlImageView * userPicView;
@property (nonatomic, retain) UIView * btmRightCornerView;
@property (nonatomic, retain) NSString * bmiddlePicUrl;

@property (nonatomic,retain) UrlImageView *  statusImgOne;
@property (nonatomic,retain) UrlImageView *  statusImgTwo;
@property (nonatomic,retain) UrlImageView *  statusImgThree;

@property (nonatomic,retain) UIImageView *  starOptImage;
@property (nonatomic,retain) UILabel     *  starAmount;
//@property (nonatomic,retain) UIImageView *  viewHisImage;
//@property (nonatomic,retain) UILabel     *  viewAmount;

- (CGFloat) getCellHeight;
- (void) sizeToFit;

@end
