//
//  DataController.m
//  WeiTansuo
//
//  Created by chishaq on 11-8-19.
//  Copyright 2011年 Invidel. All rights reserved.
//

#import "DataController.h"

#define DefaultLatitude            39.91553;
#define DefaultLongitude           116.397185;
#define DefaultLatitudeDelta       0.024872;
#define DefaultLongitudeDelta      0.024872;
#define SearchLatitudeDelta        100;
#define SearchLongitudeDelta       100;
#define KOAuthConsumerKey          @"2375310633";		//REPLACE ME 3983859935 
#define KOAuthConsumerSecret       @"2469b03e646c57b7c987b261c638629f";//REPLACE ME 201fea7b1e1203a76a10f3be570f5abb

static int mTimeline = 0;
static long long mKLocateSelfDistence = 1000;
static NSString * mLocationDescription = @"";
static NSString * mMinLocationDescription = @"";
static User * mUser;
static MKCoordinateRegion mDefaultRegion;
static float mDefaultLatitude = DefaultLatitude;
static float mDefaultLongitude = DefaultLongitude;
static BOOL mShenbianVCNeedRefreash = NO;
static UIImage * mImageForCamera;

//热点缓存数组
static NSMutableArray * gHotPlace;
//赞列表缓存数组
static NSMutableArray * gFeeds;

@implementation DataController

+ (NSMutableArray *) getHotPlace
{
    return gHotPlace;
}

+ (void) setHotPlace: (NSMutableArray *)hotPlace
{
    gHotPlace = hotPlace;
}

+ (NSMutableArray *) getFeeds
{
    return gFeeds;
}

+ (void) setFeeds: (NSMutableArray *)feeds
{
    gFeeds = feeds;
}

+ (UIImage *) getCamera
{
    return mImageForCamera;
}
+ (void) setCamera: (UIImage *)img
{
    mImageForCamera = [img copy];
}

+ (void)setTimeline:(int)timeline
{
    mTimeline = timeline;
}
+ (int)getTimeline
{
    return mTimeline;
}

+ (long long)getKLocateSelfDistence
{
    return mKLocateSelfDistence;
}

+ (void)setKLocateSelfDistence:(long long)distance
{
    mKLocateSelfDistence = distance;
}

+ (User *) getUser
{
    return mUser;
}
+ (void) setUser: (User *)user
{
    mUser = user;
}


+ (float) getDefaultLatitude
{
    return mDefaultLatitude;
}
+ (void) setDefaultLatitude:(float)newLatitude
{
    mDefaultLatitude = newLatitude;
}

+ (float) getDefaultLongitude
{
    return mDefaultLongitude;
}
+ (void) setDefaultLongitude:(float)newLongitude
{
    mDefaultLongitude = newLongitude ;
}

+ (float) getDefaultLatitudeDelta
{
    return DefaultLatitudeDelta;
}

+ (float) getDefaultLongitudeDelta
{
    return DefaultLongitudeDelta;
}

+ (void) setDefaultRegion:(MKCoordinateRegion)newregion
{
    mDefaultRegion = newregion;
    mDefaultRegion.span.latitudeDelta = DefaultLatitudeDelta;
    mDefaultRegion.span.longitudeDelta = DefaultLongitudeDelta;
}

+ (MKCoordinateRegion) getDefaultRegion
{
    if (mDefaultRegion.center.latitude<=0 || mDefaultRegion.center.longitude<=0) {
        mDefaultRegion.center.latitude = mDefaultLatitude;
        mDefaultRegion.center.longitude = mDefaultLongitude;
        mDefaultRegion.span.latitudeDelta = DefaultLatitudeDelta;
        mDefaultRegion.span.longitudeDelta = DefaultLongitudeDelta;
    }
    
    return mDefaultRegion;
}

+ (MKCoordinateRegion) getDefaultSearchRegion
{
    MKCoordinateRegion mDefaultRegion;
    mDefaultRegion.center.latitude = mDefaultLatitude;
    mDefaultRegion.center.longitude = mDefaultLongitude;
    mDefaultRegion.span.latitudeDelta = SearchLatitudeDelta;
    mDefaultRegion.span.longitudeDelta = SearchLongitudeDelta;
    
    return mDefaultRegion;
}

+ (NSString *) getKOAuthConsumerKey
{
    return KOAuthConsumerKey;
}

+ (NSString *) getKOAuthConsumerSecret
{
    return KOAuthConsumerSecret;
}

+(void) setLocationDescription:(NSString *)locationDescription
{
    mLocationDescription = locationDescription;
}

+(NSString *) getLocationDescription
{
    return mLocationDescription;
}

+(void) setMinLocationDescription:(NSString *)minLocationDescription
{
    mMinLocationDescription = minLocationDescription;
}

+(NSString *) getMinLocationDescription
{
    return mMinLocationDescription;
}

+(void) setShenbianVCNeedRefreash:(BOOL)shenbianVCNeedRefreash
{
    mShenbianVCNeedRefreash = shenbianVCNeedRefreash;
}

+(BOOL) getShenbianVCNeedRefreash
{
    return mShenbianVCNeedRefreash;
}
+ (NSString *) getUserScreenName{
    return @"";
}
@end
