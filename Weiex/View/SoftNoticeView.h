//
//  SoftNoticeView.h
//  WeiTansuo
//
//  Created by CMD on 9/13/11.
//  Copyright 2011 Invidel. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SoftNoticeView : UIView
{
    UIActivityIndicatorView * mActivityIndicatorView;
    UILabel * mTitle;
    float mDelay;
}

@property (nonatomic, retain) UIActivityIndicatorView *activityindicatorview;
@property (nonatomic, assign) float delay;

- (void)setMessage:(NSString *)message;
- (void)setActivityindicatorHidden:(BOOL)hidden;
- (void)start;
- (void)stop;

- (void)showMeDelay: (int)delay;


@end
