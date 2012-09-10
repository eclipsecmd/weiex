//
//  StatusAnnotation.h
//  WeiTansuo
//
//  Created by Tu Jianfeng on 8/13/11.
//  Copyright 2011 Invidel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

#import "Status.h"

@interface StatusAnnotation : NSObject <MKAnnotation> {
    Status * mStatus;
    int mIndexTag;
}

@property (nonatomic, retain) Status * status;
@property (nonatomic, assign) int indexTag;

@end
