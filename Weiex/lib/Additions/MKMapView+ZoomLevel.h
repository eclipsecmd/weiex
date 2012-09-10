//
//  MKMapView+ZoomLevel.h
//  WeiTansuo
//
//  Created by CMD on 11/25/11.
//  Copyright (c) 2011 Invidel. All rights reserved.
//

#import <MapKit/MapKit.h>

@interface MKMapView (ZoomLevel)

- (void)setCenterCoordinate:(CLLocationCoordinate2D)centerCoordinate
                  zoomLevel:(NSUInteger)zoomLevel
                   animated:(BOOL)animated;

@end
