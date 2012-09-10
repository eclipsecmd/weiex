//
//  LocationAnnotation.m
//  WeiTansuo
//
//  Created by chenyan on 8/27/11.
//  Copyright 2011 Invidel. All rights reserved.
//

#import "LocationAnnotation.h"

@implementation LocationAnnotation

@synthesize wLocation = mWLocation;
@synthesize indexTag = mIndexTag;

- (CLLocationCoordinate2D)coordinate
{
    CLLocationCoordinate2D coordinate;
    
    coordinate.latitude = mWLocation.latitude;
    coordinate.longitude = mWLocation.longitude;
    
    return coordinate;
}

- (NSString *)title
{
    return mWLocation.title;
}

- (NSString *)subtitle
{
    return mWLocation.subtitle;
}

- (void)dealloc
{
    [mWLocation release];
    [super dealloc];
}
@end
