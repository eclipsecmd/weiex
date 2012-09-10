//
//  ClickImageView.m
//  WeiTansuo
//
//  Created by chenyan on 9/5/11.
//  Copyright 2011 Invidel. All rights reserved.
//

#import "ClickImageView.h"

@implementation ClickImageView

@synthesize responseTarget,responseAction;
@synthesize singleTap = mSingleTap;

- (id)initWithImage:(UIImage *)image frame:(CGRect)frame target:(id)target action:(SEL)action
{
    self = [super initWithImage:image];
    if (self) {
        self.responseTarget = target;
        self.responseAction = action;
        self.frame = frame;
        self.userInteractionEnabled = YES;
        mSingleTap = [[UITapGestureRecognizer alloc] initWithTarget:target action:action];
        [self addGestureRecognizer:mSingleTap];
    }
    
    return self;
}

- (id)initWithImage:(UIImage *)image frame:(CGRect)frame
{
    self = [super initWithImage:image];
    if (self) {
        self.frame = frame;
        self.userInteractionEnabled = YES;
        mSingleTap = [[UITapGestureRecognizer alloc] initWithTarget:nil action:nil];
        [self addGestureRecognizer:mSingleTap];
    }
    
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.frame = frame;
        self.userInteractionEnabled = YES;
        mSingleTap = [[UITapGestureRecognizer alloc] initWithTarget:nil action:nil];
        [self addGestureRecognizer:mSingleTap];
    }
    
    return self;
}

- (void)addTarget:(id)target action:(SEL)aciton
{
    self.responseTarget = target;
    self.responseAction = aciton;
    [mSingleTap addTarget:target action:aciton];
}

- (void)dealloc {
    [mSingleTap release];
    [super dealloc];
}

@end
