//
//  StatusItemCellNotice.h
//  WeiTansuo
//
//  Created by CMD on 10/19/11.
//  Copyright 2011 Invidel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UrlImageView.h"
#import "ClickImageView.h"
#import <QuartzCore/QuartzCore.h>

@interface StatusItemCellNotice : UITableViewCell {
    UILabel * mUserName;
    UILabel * mContentLabel;
    UILabel * mTimeLabel;
    UILabel * mOriContentLabel;
    UIView * mOriContentView;
    UrlImageView * mUserPicView; 
    UIImageView * mTimeLabelImage;
    UIButton * mReplyButton;    
    UILabel * mOriContentUserLabel;
}

@property (nonatomic, retain) UILabel * userName;
@property (nonatomic, retain) UILabel * contentLabel;
@property (nonatomic, retain) UILabel * timeLabel;
@property (nonatomic, retain) UILabel * oriContentLabel;
@property (nonatomic, retain) UrlImageView * userPicView;
@property (nonatomic, retain) UIButton * replayButton;
@property (nonatomic, retain) UILabel * oriContentUserLabel;

- (CGFloat) getCellHeight;
- (void)pleaseComment;
- (void)seeUserProfile;
- (void)seeOriStatus;

@end
