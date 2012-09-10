//
//  UIViewController.m
//  WeiTansuo
//
//  Created by chenyan on 9/20/11.
//  Copyright 2011 Invidel. All rights reserved.
//

#import "UIViewControllerCategory.h"

@implementation UIViewController (UIViewControllerCategory)

-(void)setBackBarItem:(SEL) method
{
    UIButton * backImageView = [[UIButton alloc] initWithFrame:CGRectMake(10, 0, 30, 30)];
    [backImageView setImage:[UIImage imageNamed:@"back.png"] forState:UIControlStateNormal];
    [backImageView setImage:[UIImage imageNamed:@"back2.png"] forState:UIControlStateHighlighted];
    [backImageView addTarget:self action:method forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem * barButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backImageView];
    self.navigationItem.leftBarButtonItem = barButtonItem;
    [barButtonItem release];
    [backImageView release];
}

@end
