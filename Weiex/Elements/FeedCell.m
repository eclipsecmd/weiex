//
//  FeedCell.m
//  WeiTansuo
//
//  Created by hyq on 11/25/11.
//  Copyright (c) 2011 Invidel. All rights reserved.
//

#import "FeedCell.h"


@implementation FeedCell

@synthesize userName = mUserName;
@synthesize userPicView = mUserPicView;
@synthesize middlePicView = mMiddlePicView;
@synthesize location = mLocation;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        //用户头像
        mUserPicView = [[UrlImageView alloc] initWithFrame:CGRectMake(10.f, 34, 50.f, 50.f)];        
        mUserPicView.highlighted = YES;
        mUserPicView.layer.masksToBounds = YES;
        mUserPicView.layer.cornerRadius = 5.f;
        [self addSubview:mUserPicView];
        //用户头像按钮
        UIButton * userPicViewButton = [[UIButton alloc] initWithFrame:mUserPicView.frame];
        [userPicViewButton setBackgroundColor:[UIColor clearColor]];
        [userPicViewButton addTarget:self action:@selector(toUserProfile) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:userPicViewButton];
        [userPicViewButton release];
        
        //用户名
        mUserName = [[UILabel alloc] initWithFrame:CGRectMake(67, 37, 95, 16.f)];
        mUserName.font = [UIFont fontWithName:@"TrebuchetMS-Bold" size:13];
        [mUserName setTextColor:[UIColor colorWithRed:0.2 green:0.2 blue:0.2 alpha:1]];
        [self addSubview:mUserName];
       
//        UIImage * heart = [UIImage imageNamed:@"like.png"];
         UIImage * heart = [UIImage imageNamed:@"heart.png"];
        UIImageView * heartView = [[UIImageView alloc] initWithFrame:CGRectMake(67, 64, 15, 15)];
        heartView.image = heart;
        [self addSubview:heartView];
        
        //微薄大图
        mMiddlePicView = [[UrlImageView alloc] initWithFrame:CGRectMake(200, 10.f, 100.f, 100.f)];
        mMiddlePicView.highlighted = YES;     
        mMiddlePicView.layer.masksToBounds = YES;
        mMiddlePicView.layer.cornerRadius = 5.0;
        [self addSubview:mMiddlePicView];

        
        //相对位置
        //位置背景
//        UIImageView * mLocationBg = [[UIImageView alloc]initWithFrame:CGRectMake(0, 90, 77, 27)];
//        [mLocationBg setImage:[UIImage imageNamed:@"Location_bg2.png"]]; 
//        
//        mLocation = [[UILabel alloc] initWithFrame:CGRectMake(10, 6, 100, 14.f)];        
//        mLocation.font = [UIFont fontWithName:@"Arial" size:10];
//        mLocation.textColor = [UIColor whiteColor];
//        [mLocation setBackgroundColor:[UIColor clearColor]];
//
//        [mLocationBg addSubview:mLocation];
//        [self addSubview:mLocationBg];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (CGFloat) getCellHeight
{
 
    return 130.f;
}


@end
