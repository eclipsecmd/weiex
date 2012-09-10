//
//  HotPlace.h
//  WeiTansuo
//
//  Created by hyq on 10/28/11.
//  Copyright 2011 Invidel. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HotPlace : NSObject 
{
    double mLongitude;
    double mLatitude;
    NSString * mTitle;
    long long mPlaceId;
    long long mClickNum;       //点击浏览次数
    long long mStarNum;        //喜欢次数 
    NSString * mDescrption;    //热点地区描述
    NSMutableArray * mImgUrls; //图片地址
    NSString * mUserName;
    NSString * mUserImageUrl;
}

@property (nonatomic, assign) double longitude;
@property (nonatomic, assign) double latitude;
@property (nonatomic, retain) NSString *title;
@property (nonatomic, assign) long long placeId;
@property (nonatomic, assign) long long starNum;
@property (nonatomic, assign) long long clickNum;
@property (nonatomic, retain) NSString * descrption;
@property (nonatomic, retain) NSMutableArray * imgUrls;
@property (nonatomic, retain) NSString * userName;
@property (nonatomic, retain) NSString * userImageUrl;

- (id)init;
- (void)format;



@end
