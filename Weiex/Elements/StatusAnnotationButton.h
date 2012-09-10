//
//  StatusDetailButton.h
//  WeiTansuo
//
//  Created by chenyan on 8/28/11.
//  Copyright 2011 Invidel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Status.h"

@interface StatusAnnotationButton : UIButton {
    Status * mStatus;
}

@property (nonatomic, assign) Status * status;

@end
