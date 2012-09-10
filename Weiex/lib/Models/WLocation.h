//
//  WLocation.h
//  WeiTansuo
//
//  Created by Sai Li on 8/13/11.
//  Copyright 2011 Invidel. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface WLocation : NSObject {
    double mLongitude;
    double mLatitude;
    NSString *mTitle;
	NSString *mSubtitle;
	NSString *mStreetAddress;
	NSString *mCity;
	NSString *mRegion;
	NSString *mCountry;
    NSString *mGuid;                //街旁地点ID
    long long mPlaceId;
    
}

@property (nonatomic, assign) double longitude;// The distance north or south of the equator
@property (nonatomic, assign) double latitude;//the distance east or west of the Greenwich meridianan imaginary line
@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) NSString *subtitle;
@property (nonatomic, retain) NSString *streetAddress;
@property (nonatomic, retain) NSString *city;
@property (nonatomic, retain) NSString *region;
@property (nonatomic, retain) NSString *country;
@property (nonatomic, retain) NSString *guid;
@property (nonatomic, assign) long long placeId;

- (id)init;
- (void)format;

@end
