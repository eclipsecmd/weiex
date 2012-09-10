//
//  LocationAnnotationButton.h
//  WeiTansuo
//
//  Created by chenyan on 8/28/11.
//  Copyright 2011 Invidel. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "WLocation.h"

@interface LocationAnnotationButton : UIButton {
    WLocation * mWLocation;
}

@property (nonatomic, assign) WLocation * wLocation;

@end
