//
//  StatusLocationViewController.h
//  WeiTansuo
//
//  Created by chenyan on 9/13/11.
//  Copyright 2011 Invidel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import "WLocation.h"

@interface StatusLocationViewController : UIViewController <MKMapViewDelegate>
{
    MKCoordinateRegion          mRegion;                    //当前地区
    MKMapView *                 mMapView;                   //地图视图
    WLocation *                 mCurrentLocation;           //定位地址
    BOOL                        mIsFirstLoad;               
}

@property (nonatomic, assign) MKCoordinateRegion region;

- (id)init;
- (void)initMRegion;
- (void) mapViewBegin;


@end
