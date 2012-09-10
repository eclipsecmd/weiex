//
//  HotPlaceNewCell.h
//  WeiTansuo
//
//  Created by Yuqing Huang on 11/22/11.
//  Copyright (c) 2011 Invidel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>
#import "UrlImageView.h"
#import "ClickImageView.h"

@interface HotPlaceNewCell : UITableViewCell {
    UIView       * mInfoArea;
    UrlImageView * mUserImage;
    UILabel      * mUserName;
    UILabel      * mPlaceinfo;
    
    UIImageView  * mStarImage;   
    UIImageView       * mStarView;
    UILabel      * mStarAmount;
    UILabel      * mStarComment;
}

@property (nonatomic, retain) UIView       * infoArea;
@property (nonatomic, retain) UrlImageView * userImage;
@property (nonatomic, retain) UILabel      * userName;
@property (nonatomic, retain) UILabel      * placeinfo;
@property (nonatomic, retain) UIImageView  * starImage;
@property (nonatomic, retain) UIView       * starView;
@property (nonatomic, retain) UILabel      * starAmount;
@property (nonatomic, retain) UILabel      * starComment;

- (CGFloat) getCellHeight;

@end
