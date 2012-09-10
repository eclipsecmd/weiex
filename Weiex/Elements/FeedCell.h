//
//  FeedCell.h
//  WeiTansuo
//
//  Created by hyq on 11/25/11.
//  Copyright (c) 2011 Invidel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "UrlImageView.h"

@interface FeedCell : UITableViewCell{
    UrlImageView * mMiddlePicView;  //Feed图片
    UrlImageView * mUserPicView;    //用户头像
    UILabel * mUserName;            //用户名称
    UILabel * mLocation;            //所在位置
    UILabel * mHeartNum;            //心后面跟的数字
}

@property (nonatomic, retain) UrlImageView * middlePicView;
@property (nonatomic, retain) UrlImageView * userPicView;
@property (nonatomic, retain) UILabel * userName;
@property (nonatomic, retain) UILabel * location;

- (CGFloat) getCellHeight;
@end
