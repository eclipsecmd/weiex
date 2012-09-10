//
//  HotPlace.m
//  WeiTansuo
//
//  Created by hyq on 10/28/11.
//  Copyright 2011 Invidel. All rights reserved.
//

#import "HotPlace.h"

@implementation HotPlace


@synthesize latitude     = mLatitude;
@synthesize longitude    = mLongitude;
@synthesize title        = mTitle;
@synthesize starNum      = mStarNum;
@synthesize clickNum     = mClickNum;
@synthesize descrption   = mDescrption;
@synthesize placeId      = mPlaceId;
@synthesize imgUrls      = mImgUrls;
@synthesize userName     = mUserName;
@synthesize userImageUrl = mUserImageUrl;


- (id) init
{
    self = [super init];
    if (self) {
        mTitle = [NSString stringWithFormat:@""];
        mImgUrls = [[NSMutableArray alloc]init];
    }
    return self;
}
- (void) dealloc
{
    [mTitle release];
    [mImgUrls release];
    [super dealloc];
}

- (void) format
{
    if (mTitle == nil) mTitle = @"";
}

@end
