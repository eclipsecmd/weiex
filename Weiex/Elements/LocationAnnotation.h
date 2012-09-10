//
//  LocationAnnotation.h
//  WeiTansuo
//
//  Created by chenyan on 8/27/11.
//  Copyright 2011 Invidel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

#import "WLocation.h"

@interface LocationAnnotation : NSObject<MKAnnotation>{
    WLocation * mWLocation;
    int mIndexTag;
}

@property (nonatomic, retain) WLocation * wLocation;
@property (nonatomic, assign) int indexTag;

@end
