//
//  StatusAnnotation.m
//  WeiTansuo
//
//  Created by Tu Jianfeng on 8/13/11.
//  Copyright 2011 Invidel. All rights reserved.
//

#import "StatusAnnotation.h"


@implementation StatusAnnotation

@synthesize status = mStatus;
@synthesize indexTag = mIndexTag;

- (CLLocationCoordinate2D)coordinate
{
    CLLocationCoordinate2D coordinate;
    
    coordinate.latitude = mStatus.latitude;
    coordinate.longitude = mStatus.longitude;
    
    return coordinate;
}

- (NSString *)title
{
    return mStatus.user.name;
}

- (NSString *)subtitle
{
    return mStatus.text;
}


- (void)dealloc
{
    [mStatus release];
    [super dealloc];    
}

@end
