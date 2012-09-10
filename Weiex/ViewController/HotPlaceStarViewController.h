//
//  HotPlaceStarViewController.h
//  WeiTansuo
//
//  Created by Yuqing Huang on 11/30/11.
//  Copyright (c) 2011 Invidel. All rights reserved.
//
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "SortRootViewController.h"
#import <QuartzCore/QuartzCore.h>

@interface HotPlaceStarViewController :UIViewController<UITextViewDelegate>{
    UITextView * mContentText;
    NSString   * mNowRegion;
}
@property (nonatomic,retain) UITextView * contentText;
@property (nonatomic,retain) NSString * nowRegion;
@property (nonatomic,assign) double  regionLat;
@property (nonatomic,assign) double  regionLng;
@property (nonatomic,retain) NSString * regionProvince;
@property (nonatomic,assign) int     regionType;

-(void) back;
@end
