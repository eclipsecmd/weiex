//
//  myCheckBox.m
//  WeiTansuo
//
//  Created by Sai Li on 9/3/11.
//  Copyright 2011 Invidel. All rights reserved.
//

#import "myCheckBox.h"


@implementation myCheckBox

@synthesize checkSelected = mCheckedSelected;

- (id)initWithFrame:(CGRect)frame rightTitle:(NSString *)rightTitle
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setFrame:frame];
        mCheckedSelected = NO;
        mButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 17, 17)];
        [mButton setBackgroundImage:[UIImage imageNamed:@"no.png"]
                             forState:UIControlStateNormal];
        [mButton setBackgroundImage:[UIImage imageNamed:@"yes.png"]
                             forState:UIControlStateSelected];
        [mButton setBackgroundImage:[UIImage imageNamed:@"yesPressed.png"]
                             forState:UIControlStateHighlighted];
        mButton.adjustsImageWhenHighlighted=YES;
        [mButton addTarget:self action:(@selector(ischeck:)) forControlEvents:UIControlEventTouchUpInside];
        
        [self addSubview:mButton];
        
        mRightTitle = [[UILabel alloc] initWithFrame:CGRectMake(20, 2, frame.size.width - 15, 15)];
        [mRightTitle setTextColor:[UIColor blackColor]];
        [mRightTitle setBackgroundColor:[UIColor clearColor]];
        [mRightTitle setFont:[UIFont fontWithName:@"Arial" size:14]];
        [mRightTitle setText:rightTitle];
        [self addSubview:mRightTitle]; 
        [self setBackgroundColor:[UIColor clearColor]];
        // Initialization code
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (void)justfiyFrame:(CGRect)frame
{
    [mButton setFrame:CGRectMake(frame.origin.x, frame.origin.y, 15, 15)];
    [mRightTitle setFrame:CGRectMake(frame.size.height + frame.origin.x + 5, frame.origin.y, frame.size.width - 15, frame.size.height - 15)];
}

- (void)dealloc
{
    [mButton release];
    [mRightTitle release];
    [super dealloc];
}

-(void)setRightContent:(NSString *)rightContent
{
    if (mRightTitle != nil) {
        mRightTitle.text = rightContent;
    }
}

-(void)ischeck:(id)sender
{
    mCheckedSelected = !mCheckedSelected;
    [mButton setSelected:mCheckedSelected];
}

@end
