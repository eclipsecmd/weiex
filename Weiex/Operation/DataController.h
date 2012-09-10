//
//  DataController.h
//  WeiTansuo
//
//  Created by chishaq on 11-8-19.
//  Copyright 2011年 Invidel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import "User.h"

@interface DataController : NSObject {
    
}

+ (UIImage *) getCamera;
+ (void) setCamera: (UIImage *)img;

+ (User *) getUser;
+ (void) setUser: (User *)user;

+ (NSString *) getUserScreenName;
+ (long long) getKLocateSelfDistence;
+ (void)setKLocateSelfDistence:(long long)distance;
+ (float) getDefaultLatitude;
+ (void) setDefaultLatitude:(float)newLatitude;
+ (float) getDefaultLongitude;
+ (void) setDefaultLongitude:(float)newLongitude;
+ (float) getDefaultLatitudeDelta;
+ (float) getDefaultLongitudeDelta;
+ (MKCoordinateRegion) getDefaultRegion;
+ (void) setDefaultRegion:(MKCoordinateRegion)newregion;
+ (MKCoordinateRegion) getDefaultSearchRegion;
+ (NSString *) getKOAuthConsumerKey;
+ (NSString *) getKOAuthConsumerSecret;
+ (void) setLocationDescription:(NSString *)locationDescription;
+ (NSString *) getLocationDescription;
+ (void) setMinLocationDescription:(NSString *)minLocationDescription;
+ (NSString *) getMinLocationDescription;
+ (void) setShenbianVCNeedRefreash:(BOOL)shenbianVCNeedRefreash;
+ (BOOL) getShenbianVCNeedRefreash;

+ (NSMutableArray *) getHotPlace;
+ (void) setHotPlace:(NSMutableArray *)hotPlace;
+ (NSMutableArray *) getFeeds;
+ (void) setFeeds:(NSMutableArray *)feeds;

+ (void)setTimeline:(int)timeline;
+ (int)getTimeline;

@end
