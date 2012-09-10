//
//  SoftNoticeView.m
//  WeiTansuo
//
//  Created by CMD on 9/13/11.
//  Copyright 2011 Invidel. All rights reserved.
//

#import "SoftNoticeView.h"

@implementation SoftNoticeView

@synthesize activityindicatorview = mActivityIndicatorView;
@synthesize delay = mDelay;


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        UIImageView *bgImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        [bgImageView setImage:[UIImage imageNamed:@"alertView-bg.png"]];
        [bgImageView setAlpha:0.7];
        [self addSubview:bgImageView];;
        [bgImageView release];
        

        mTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, (frame.size.width-40)/2, frame.size.width, 20)];
        [mTitle setBackgroundColor:[UIColor clearColor]];
        [mTitle setTextAlignment:UITextAlignmentCenter];
        [mTitle setFont:[UIFont fontWithName:@"Arial" size:14]];
        [mTitle setTextColor:[UIColor whiteColor]];
        [self addSubview:mTitle];
        
        mActivityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        [mActivityIndicatorView setFrame:CGRectMake((frame.size.width-20)/2, (frame.size.height-40)/2+20, 20, 20)];
        [self addSubview:mActivityIndicatorView];
    }
    return self;
}

- (void)setMessage:(NSString *)message
{
    mTitle.text = message;
}
- (void)setActivityindicatorHidden:(BOOL)hidden
{
    if (hidden) {
        [mActivityIndicatorView removeFromSuperview];
        [mTitle setFrame:CGRectMake(0, (self.frame.size.width-20)/2, self.frame.size.width, 20)];
    } 
    else {
        [self addSubview:mActivityIndicatorView];
        [mTitle setFrame:CGRectMake(0, (self.frame.size.width-40)/2, self.frame.size.width, 20)];
    }
}

- (void)start
{
    [mActivityIndicatorView startAnimating];
}

- (void)stop
{
    [mActivityIndicatorView stopAnimating];
}


- (void)showMeDelay: (int)delay
{
    [self start];
    [self performSelector:@selector(stop) withObject:nil afterDelay:delay];
}

- (void)dealloc
{
    [mActivityIndicatorView release];
    [mTitle release];
    [super dealloc];
}

@end
