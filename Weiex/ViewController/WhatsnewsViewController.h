//
//  WhatsnewsViewController.h
//  WeiTansuo
//
//  Created by CMD on 2/4/12.
//  Copyright (c) 2012 Invidel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LoginMainViewControllerProtocol.h"


@interface WhatsnewsViewController : UIViewController <UIScrollViewDelegate, LoginMainViewControllerProtocol>
{
    UIScrollView *scrollView;
	UIPageControl *pageControl;
    NSMutableArray *viewControllers;
    NSArray *contentList;
    // To be used when scrolls originate from the UIPageControl
    BOOL pageControlUsed;
    id <LoginMainViewControllerProtocol> delegate;
    UIButton * button;
}

@property (nonatomic, retain) UIScrollView *scrollView;
@property (nonatomic, retain) UIPageControl *pageControl;
@property (nonatomic, retain) NSArray *contentList;
@property (nonatomic, retain) NSMutableArray *viewControllers;
@property (nonatomic, assign) id <LoginMainViewControllerProtocol> delegate;
@property (nonatomic, retain) UIButton * myButton;

@property (nonatomic, assign) id finishTarget;
@property (nonatomic, assign) SEL finishAction;

- (void)loadScrollViewWithPage:(int)page;
- (void)scrollViewDidScroll:(UIScrollView *)sender;

- (void)initDataWithPlist;

@end

