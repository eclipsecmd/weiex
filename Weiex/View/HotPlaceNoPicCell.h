//
//  HotPlaceNoPicCell.h
//  WeiTansuo
//
//  Created by Yuqing Huang on 11/19/11.
//  Copyright (c) 2011 Invidel. All rights reserved.
//
#import <UIKit/UIKit.h>

#import "UrlImageView.h"
#import "ClickImageView.h"

@interface HotPlaceNoPicCell : UITableViewCell {
    
    UIView  *  mInfoArea;
    UILabel * mPlaceDescription;
    UILabel * mPlaceInfo;
    
    UIImageView * mStarImage;
    UILabel     * mStarAmount;
    UIImageView * mViewImage;
    UILabel     * mViewAmount; 
}

@property (nonatomic, retain) UIView  * infoArea;
@property (nonatomic, retain) UILabel * placeDescription;
@property (nonatomic, retain) UILabel * placeInfo;
@property (nonatomic, retain) UIImageView * starImage;
@property (nonatomic, retain) UILabel     * starAmount;
@property (nonatomic, retain) UIImageView * viewImage;
@property (nonatomic, retain) UILabel     * viewAmount;

- (CGFloat) getCellHeight;

@end
