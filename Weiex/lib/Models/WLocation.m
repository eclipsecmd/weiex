//
//  WLocation.m
//  WeiTansuo
//
//  Created by Sai Li on 8/13/11.
//  Copyright 2011 Invidel. All rights reserved.
//

#import "WLocation.h"

@implementation WLocation

@synthesize latitude = mLatitude;
@synthesize longitude = mLongitude;
@synthesize title = mTitle;
@synthesize subtitle = mSubtitle;
@synthesize streetAddress = mStreetAddress;
@synthesize city = mCity;
@synthesize region = mRegion;
@synthesize country = mCountry;
@synthesize guid = mGuid;
@synthesize placeId = mPlaceId;

- (id) init
{
    self = [super init];
    if (self) {
        mTitle = [NSString stringWithFormat:@""];
        mSubtitle = [NSString stringWithFormat:@""];
        mStreetAddress = [NSString stringWithFormat:@""];
        mCity = [NSString stringWithFormat:@""];
        mRegion = [NSString stringWithFormat:@""];
        mCountry = [NSString stringWithFormat:@""];
        mGuid = [NSString stringWithFormat:@""];
    }
    return self;
}
- (void) dealloc
{
    [mGuid release];
    [mCountry release];
    [mRegion release];
    [mCity release];
    [mStreetAddress release];
    [mSubtitle release];
    [mTitle release];
    [super dealloc];
}

- (void) format
{
    if (mTitle == nil) mTitle = @"";
    if (mSubtitle == nil) mSubtitle = @"";
    if (mStreetAddress == nil) mStreetAddress = @"";
}
@end
