//
//  HotPlaceCell.h
//  WeiTansuo
//
//  Created by hyq on 10/21/11.
//  Copyright 2011 Invidel. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "UrlImageView.h"
#import "ClickImageView.h"

@interface HotPlaceCell : UITableViewCell {
   
    UIView * mImgArea;
    UIView * mInfoArea;
    
    UILabel * mPlaceDescription;
    UILabel * mPlaceInfo;
    UILabel * mPlaceClick;
//    UILabel * mPlaceLike;
    
    UIImageView * mStarImage;
    UILabel * mStarAmount;
    UIImageView * mViewImage;
    UILabel * mViewAmount; 
    
    UrlImageView * mPlaceImg1;
    UrlImageView * mPlaceImg2;
    UrlImageView * mPlaceImg3;
    UrlImageView * mPlaceImg4;
    UrlImageView * mPlaceImg5;
   
//    NSString * mPlaceImgUrl1;    
//    NSString * mPlaceImgUrl2;
//    NSString * mPlaceImgUrl3;
//    NSString * mPlaceImgUrl4;
//    NSString * mPlaceImgUrl5;
    
}

@property (nonatomic, retain) UILabel * placeDescription;
@property (nonatomic, retain) UILabel * placeInfo;
//@property (nonatomic, retain) UILabel * placeLike;
@property (nonatomic, retain) UIImageView * starImage;
@property (nonatomic, retain) UILabel * starAmount;
@property (nonatomic, retain) UIImageView * viewImage;
@property (nonatomic, retain) UILabel * viewAmount;
@property (nonatomic, retain) UrlImageView * placeImg1;
@property (nonatomic, retain) UrlImageView * placeImg2;
@property (nonatomic, retain) UrlImageView * placeImg3;
@property (nonatomic, retain) UrlImageView * placeImg4;
@property (nonatomic, retain) UrlImageView * placeImg5;

- (CGFloat) getCellHeight;


@end
