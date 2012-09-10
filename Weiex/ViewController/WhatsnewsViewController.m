//
//  WhatsnewsViewController.m
//  WeiTansuo
//
//  Created by CMD on 2/4/12.
//  Copyright (c) 2012 Invidel. All rights reserved.
//

#import "WhatsnewsViewController.h"
#import "MyViewController.h"


@implementation WhatsnewsViewController

@synthesize contentList;
@synthesize scrollView, pageControl, viewControllers;
@synthesize delegate;
@synthesize myButton;
@synthesize finishAction,finishTarget;

static NSUInteger kNumberOfPages = 0;

//static NSString *NameKey = @"title";
//static NSString *ImageKey = @"imageurl";
//static NSString *DescriptKey = @"descript";
//static NSString *ContentsKey = @"contents";


- (id)init
{
    self = [super init];
    if (self) {
        [self initDataWithPlist];
    }
    return self;
}

- (void)initDataWithPlist
{
    // load our data from a plist file inside our app bundle
    NSString *path = [[NSBundle mainBundle] pathForResource:@"whatsnews" ofType:@"plist"];
    self.contentList = [NSArray arrayWithContentsOfFile:path];
    NSMutableArray *controllers = [[NSMutableArray alloc] init];
    kNumberOfPages = [self.contentList count];
    for (unsigned i = 0; i < kNumberOfPages; i++)
    {
        [controllers addObject:[NSNull null]];
    }
    self.viewControllers = controllers;
    [controllers release];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

//#define FIRSTUSEME @"firstuseme"

// Implement loadView to create a view hierarchy programmatically, without using a nib.
//- (void)loadView
//{
//    [super loadView];
//    
//    
//    //    NSUserDefaults * def = [NSUserDefaults standardUserDefaults];
//    //    NSString * isFirstUseMe = (NSString *)[def objectForKey:FIRSTUSEME];
//    //    
//    //    if (isFirstUseMe == @"yes") {
//    //        
//    //        [def setObject:@"no" forKey:FIRSTUSEME];
//    //        [def synchronize];
//    //        
//    //        ShopViewController * shopViewController = [[ShopViewController alloc] init];
//    //        [self.navigationController pushViewController:shopViewController animated:NO];
//    //    }
//    
//}

- (void)viewDidLoad
{
    //set background Image
    //[self.view setBackgroundColor:[UIColor colorWithRed:255/255.f green:253/255.f blue:222/255.f alpha:1]];
    [self.view setBackgroundColor:[UIColor blackColor]];
    //    UIImage * backgroundImage = [UIImage imageNamed:@"background.jpg"];
    //    [self.view setBackgroundColor:[UIColor colorWithPatternImage:backgroundImage]];
    //    [backgroundImage release];
    
    // a page is the width of the scroll view
    scrollView = [[UIScrollView alloc] init];
    scrollView.frame = CGRectMake(0, 0, 320, 470);
    scrollView.pagingEnabled = YES;
    scrollView.contentSize = CGSizeMake(scrollView.frame.size.width * kNumberOfPages, scrollView.frame.size.height);
    scrollView.showsHorizontalScrollIndicator = NO;
    scrollView.showsVerticalScrollIndicator = NO;
    scrollView.scrollsToTop = NO;
    scrollView.delegate = self;
    
    //返回按钮    
    UIButton * backButton = [[UIButton alloc] initWithFrame:CGRectMake(9, 7, 40, 30)];
    [backButton setImage:[UIImage imageNamed:@"title_icon_5_nor.png"] forState:UIControlStateNormal];
    [backButton setImage:[UIImage imageNamed:@"title_icon_5_press.png"] forState:UIControlStateHighlighted];
    [backButton addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    [self.view insertSubview:backButton atIndex:1];
    [backButton release];
    
    pageControl = [[UIPageControl alloc] init];
    pageControl.frame = CGRectMake(0, 460, 320, 20);
    pageControl.numberOfPages = kNumberOfPages;
    pageControl.currentPage = 0;
    
    
    [self.view insertSubview:scrollView atIndex:0];
    [self.view addSubview:pageControl];
    
    [self loadScrollViewWithPage:0];
    [self loadScrollViewWithPage:1];
}

- (void)loadScrollViewWithPage:(int)page
{
    if (page < 0)
        return;
    if (page >= kNumberOfPages)
        return;
    // replace the placeholder if necessary
    MyViewController *controller = [viewControllers objectAtIndex:page];
    if ((NSNull *)controller == [NSNull null])
    {
        controller = [[MyViewController alloc] initWithPageNumber:page];        
        [viewControllers replaceObjectAtIndex:page withObject:controller];
        [controller release];
    }
    
    // add the controller's view to the scroll view
    if (controller.view.superview == nil)
    {
        CGRect frame = scrollView.frame;
        frame.origin.x = frame.size.width * page;
        frame.origin.y = 0;
        controller.view.frame = frame;
        [scrollView addSubview:controller.view];
        NSString *numberItem = (NSString *)[self.contentList objectAtIndex:page];
        controller.numberImage.image = [UIImage imageNamed:numberItem];
        
//        if (kNumberOfPages > 0 || page == (kNumberOfPages - 1)) {
//            myButton = [[UIButton alloc] init];
//            myButton.frame = CGRectMake(220, 430, 90, 40);
//            [myButton setBackgroundColor:[UIColor purpleColor]];
//            [myButton setTitle:@"点击这里" forState:UIControlStateNormal];
//            [buttondelegate TargetWithMethod:myButton];
//            [self.view insertSubview:myButton atIndex:0];
//        }
        
    }
}

-(void) back
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)helloworld
{
    NSLog(@"hello,world!");
}

- (void)scrollViewDidScroll:(UIScrollView *)sender
{
    // We don't want a "feedback loop" between the UIPageControl and the scroll delegate in
    // which a scroll event generated from the user hitting the page control triggers updates from
    // the delegate method. We use a boolean to disable the delegate logic when the page control is used.
    if (pageControlUsed)
    {
        // do nothing - the scroll was initiated from the page control, not the user dragging
        return;
    }
    // Switch the indicator when more than 50% of the previous/next page is visible
    CGFloat pageWidth = scrollView.frame.size.width;
    int page = floor((scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    pageControl.currentPage = page;
    if (scrollView.contentOffset.x > pageWidth * (kNumberOfPages - 1) + 80) {
        
//        [self dismissModalViewControllerAnimated:NO];
//        if ([finishTarget retainCount] > 0 && [finishTarget respondsToSelector:finishAction]) {
//            [finishTarget performSelector:finishAction];
//        }
        
        //here is delegate procols
        [delegate helloworld];
    }
    // load the visible page and the page on either side of it (to avoid flashes when the user starts scrolling)
    [self loadScrollViewWithPage:page - 1];
    [self loadScrollViewWithPage:page];
    [self loadScrollViewWithPage:page + 1];
    // A possible optimization would be to unload the views+controllers which are no longer visible
}



// At the begin of scroll dragging, reset the boolean used when scrolls originate from the UIPageControl
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    pageControlUsed = NO;
}

// At the end of scroll animation, reset the boolean used when scrolls originate from the UIPageControl
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    pageControlUsed = NO;
}

- (IBAction)changePage:(id)sender
{
    int page = pageControl.currentPage;
    // load the visible page and the page on either side of it (to avoid flashes when the user starts scrolling)
    [self loadScrollViewWithPage:page - 1];
    [self loadScrollViewWithPage:page];
    [self loadScrollViewWithPage:page + 1];
    
	// update the scroll view to the appropriate page
    CGRect frame = scrollView.frame;
    frame.origin.x = frame.size.width * page;
    frame.origin.y = 0;
    [scrollView scrollRectToVisible:frame animated:YES];
	// Set the boolean used when scrolls originate from the UIPageControl. See scrollViewDidScroll: above.
    pageControlUsed = YES;
}



/*
 // Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
 - (void)viewDidLoad
 {
 [super viewDidLoad];
 
 }
 */


- (void)dealloc
{
    [viewControllers release];
    [scrollView release];
    [pageControl release];
    [contentList release];
    [super dealloc];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    viewControllers = nil;
    scrollView = nil;
    pageControl = nil;
    contentList = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [self.navigationController.navigationBar setHidden:YES];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
