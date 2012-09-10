//
//  UINavigationBarView.m
//  WeiTansuo
//
//  Created by CMD on 2/21/12.
//  Copyright (c) 2012 Invidel. All rights reserved.
//

#import "UINavigationBarView.h"

@implementation UINavigationBarView
@synthesize backButton;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        backButton = [[UIButton alloc] initWithFrame:CGRectMake(10, 5, 26, 26)];
        [backButton setImage:[UIImage imageNamed:@"title_icon_5_nor.png"] forState:UIControlStateNormal];
        [backButton setImage:[UIImage imageNamed:@"title_icon_5_press.png"] forState:UIControlStateHighlighted];
        [self addSubview:backButton];
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

@end
