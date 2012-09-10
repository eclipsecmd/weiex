//
//  FeedStruct.m
//  WeiTansuo
//
//  Created by hyq on 11/25/11.
//  Copyright (c) 2011 Invidel. All rights reserved.
//

#import "FeedStruct.h"

@implementation FeedStruct

@synthesize userName = mUserName;
@synthesize userHeadUrl = mUserHeadUrl;
@synthesize imgUrl = mImgUrl;
@synthesize location = mLocation;
@synthesize weiboId = mWeiboId;

- (id) init{
    self = [super init];
    if(self){
        mUserName = [NSString stringWithFormat:@""];
        mUserHeadUrl = [NSString stringWithFormat:@""];
        mImgUrl = [NSString stringWithFormat:@""];
        mLocation = [NSString stringWithFormat:@""];
    }
    return self;
}

- (void) dealloc{
    [super dealloc];
}

- (void) format{
    if (mUserName == nil) mUserName = @"";
    if (mUserHeadUrl == nil) mUserHeadUrl = @"";
    if (mImgUrl == nil) mImgUrl = @"";
    if (mLocation == nil) mLocation = @"";
}

@end
