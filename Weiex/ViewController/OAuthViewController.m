//
//  OAuthViewController.m
//  WeiTansuo
//
//  Created by chishaq on 11-8-17.
//  Copyright 2011年 Invidel. All rights reserved.
//

#import "OAuthViewController.h"

#define KEY_USER_SCREEN_NAME    @"keyScreenName" //the User's Screen name of the Object of User
#define KEY_USER_NAME           @"keyUserName"  //the UserName of the Object of User
#define KEY_USER_IMG            @"keyUserImg"   //the small User Avatar of the Object of the User
#define kOAuthConsumerKey		@"2375310633"	//Key of my weibo API, you can check from the account of your weibo developer panel
#define kOAuthConsumerSecret	@"2469b03e646c57b7c987b261c638629f"		//KeySecret of my weibo API, you can check from the account of your weibo developer panel

#define KEY_USER_SERVER_JSON_DATA      @"keyUserServerJsonData" //as title

#define KEY_USER_ALRIGHT_LOGIN      @"alreadylogin"

@implementation OAuthViewController

@synthesize finishTarget,finishAction;
@synthesize oAuthEngine = mOAuthEngine;
@synthesize opCommond = mOpCommond;

@synthesize scrollView = mScrollView;
@synthesize pageControl = mPageControl;
@synthesize contentList = contentList;

static NSUInteger kNumberOfPages = 0;

- (id)init
{
    self = [super init];
    if (self) {
        mOAuthEngine = [[OAuthEngine alloc] initOAuthWithDelegate: self];
        mOAuthEngine.consumerKey = kOAuthConsumerKey;
        mOAuthEngine.consumerSecret = kOAuthConsumerSecret;
        
        NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
        NSString * username = [defaults objectForKey:KEY_USER_NAME];
        if ([username length] > 0) {
            mOAuthEngine.username = username;
        }
        //初始化操作命令
        mOpCommond = 0;
    }
    return self;
}

- (void)dealloc
{
    [super dealloc];
    [mScrollView release];
    [mPageControl release];
    [contentList release];
    [loginButton release];
}

#pragma mark -
#pragma mark - 视图

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSUserDefaults * def = [NSUserDefaults standardUserDefaults];
    NSString * defAlrightLogin = (NSString *)[def objectForKey:KEY_USER_ALRIGHT_LOGIN];
    if (([defAlrightLogin length] > 0) && [defAlrightLogin isEqualToString:@"yes"]) {
        [self openAuthenticateView];
    } else {
        [def setObject:@"yes" forKey:KEY_USER_ALRIGHT_LOGIN];
        [def synchronize];
        [self showView];
    }    
}



- (void)initDataWithPlist
{
    // load our data from a plist file inside our app bundle
    NSString *path = [[NSBundle mainBundle] pathForResource:@"whatsnews" ofType:@"plist"];
    self.contentList = [NSArray arrayWithContentsOfFile:path];
    kNumberOfPages = [self.contentList count];
}


- (void)showView
{
//    [self.view setBackgroundColor:[UIColor whiteColor]];
//    WhatsnewsViewController * whatsnewvc = [[WhatsnewsViewController alloc] init];
//    whatsnewvc.finishTarget = self;
//    whatsnewvc.finishAction = @selector(finshSelector);
//    [self presentModalViewController:whatsnewvc animated:NO];
//    [whatsnewvc release];
    
    //滚动区
    //init the images from the plist
    [self initDataWithPlist];
    
    if (!mPageControl) {
        mPageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(0, 425, 320, 45)];
        [mPageControl setBackgroundColor:[UIColor blackColor]];
        [self.view addSubview:mPageControl];
    }
    
    if (!mScrollView) {
        mScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, 320, 460)];
        mScrollView.delegate = self;
        [mScrollView setBackgroundColor:[UIColor darkGrayColor]];
        [mScrollView setCanCancelContentTouches:NO];
        mScrollView.indicatorStyle = UIScrollViewIndicatorStyleWhite;
        mScrollView.clipsToBounds = YES;
        mScrollView.scrollEnabled = YES;
        mScrollView.pagingEnabled = YES;
        [mScrollView setShowsHorizontalScrollIndicator:NO];
        
        int nimages = 0;
        CGFloat cx = 0;
        for (nimages = 0; nimages < [contentList count]; nimages ++) {
            NSString * imageName = (NSString *)[contentList objectAtIndex:nimages];
            UIImage *image = [UIImage imageNamed:imageName];
            UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
            CGRect rect = imageView.frame;
            rect.size.height = image.size.height;
            rect.size.width = image.size.width;
            rect.origin.x = ((mScrollView.frame.size.width - image.size.width) / 2) + cx;
            rect.origin.y = ((mScrollView.frame.size.height - image.size.height) / 2);
            
            imageView.frame = rect;
            [mScrollView addSubview:imageView];
            [imageView release];
            
            cx += mScrollView.frame.size.width;
        }
//        for (nimages = 0 ; nimages < 4 ; nimages ++) {
//            NSString *imageName = [NSString stringWithFormat:@"welcome_image%d.png", nimages];
//            UIImage *image = [UIImage imageNamed:imageName];
//            UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
//            CGRect rect = imageView.frame;
//            rect.size.height = image.size.height;
//            rect.size.width = image.size.width;
//            rect.origin.x = ((mScrollView.frame.size.width - image.size.width) / 2) + cx;
//            rect.origin.y = ((mScrollView.frame.size.height - image.size.height) / 2);
//            
//            imageView.frame = rect;
//            [mScrollView addSubview:imageView];
//            [imageView release];
//            
//            cx += mScrollView.frame.size.width;
//        }
        mPageControl.numberOfPages = nimages;
        [mScrollView setContentSize:CGSizeMake(cx, [mScrollView bounds].size.height)];
        [self.view addSubview:mScrollView];
    }
    
    //登陆按钮
    loginButton = [UIButton buttonWithType:UIButtonTypeCustom];
    //[loginButton setTitle:@"点击登陆" forState:UIControlStateNormal];
    [loginButton setImage:[UIImage imageNamed:@"loginbutton.png"] forState:UIControlStateNormal];
    [loginButton setImage:[UIImage imageNamed:@"loginbutton2.png"] forState:UIControlStateHighlighted];
    [loginButton setFrame:CGRectMake(115, 420, 94, 35)];
    [loginButton addTarget:self action:(@selector(openAuthenticateView)) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:loginButton];
    
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    mScrollView = nil;
    mPageControl = nil;
    contentList = nil;
    loginButton = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:YES];
    //主流程开始
    if (mOpCommond == 1) {
        [self logout];
    }else {
//        [self openAuthenticateView];
    }
}
#pragma mark -
#pragma mark -  微博登录接口


/**删除缓存**/
- (void)removeCachedOAuthDataForUsername:(NSString *) username
{
	NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    [defaults removeObjectForKey:username];
    [defaults removeObjectForKey:KEY_USER_SCREEN_NAME];
    [defaults removeObjectForKey:KEY_USER_SERVER_JSON_DATA];
    [defaults synchronize];
}
/**存储缓存**/
- (void) storeCachedOAuthData: (NSString *) data forUsername: (NSString *) username
{
    if ([username length] > 0) {
        NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
       
        [defaults setObject:data forKey:username];
        [defaults setObject:username forKey:KEY_USER_NAME];
        [defaults synchronize];
    }
}
/**取出缓存**/
- (NSString *) cachedOAuthDataForUsername: (NSString *) username
{
    if (username == nil) {
        return nil;
    }
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    return [defaults objectForKey:username];
}

/**打开登录视图**/
- (void)openAuthenticateView
{
	UIViewController * controller = [OAuthController controllerToEnterCredentialsWithEngine:mOAuthEngine
                                                                                   delegate:self];
	if (controller) {
        [mScrollView removeFromSuperview];
        [loginButton removeFromSuperview];
		[self presentModalViewController:controller animated:NO];
    } else {
        //[DataController setUserScreenName:[defaults objectForKey:KEY_USER_SCREEN_NAME]];
        [self.navigationController popViewControllerAnimated:YES];
        if ([finishTarget retainCount] > 0 && [finishTarget respondsToSelector:finishAction]) {
            [finishTarget performSelector:finishAction  withObject:nil];
        }
        else {
            [DataController setShenbianVCNeedRefreash:YES];
            [self.tabBarController setSelectedIndex:0];
        }
    }
}
/**登录成功后，获取当前用户名,退出该视图(回调)**/
- (void) OAuthController: (OAuthController *) controller authenticatedWithUsername: (NSString *) username
{
    //NSLog(@"getuserinfo begin");
    [self getUserInfo:mOAuthEngine.username];
    
}
- (void)getUserInfo: (NSString *)UserID
{
    WeiboClient * weiboclient = [[WeiboClient alloc] initWithTarget:self engine:mOAuthEngine action:(@selector(getUserInfoFinished:obj:))];
    [weiboclient getUser:UserID];
}

- (void)getUserInfoFinished:(WeiboClient *)sender
                        obj:(NSObject*)obj
{
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults]; 
    if (sender.hasError) {
        [defaults setObject:@"Guest" forKey:KEY_USER_SCREEN_NAME];
        [defaults setObject:@"Guest" forKey:KEY_USER_NAME];
        [defaults setObject:@"" forKey:KEY_USER_IMG];
        [defaults synchronize];
    }
    else {        
        //NSLog(@"User Json Data:%@---------", obj);
        NSDictionary * dic = (NSDictionary *)obj;
        User * myuser = [User userWithJsonDictionary:dic];
        [DataController setUser:myuser];
        //NSLog(@"username:%@ screenname:%@" ,myuser.name, myuser.screenName);
        [defaults setObject:myuser.name forKey:KEY_USER_SCREEN_NAME];
        [defaults setObject:myuser.profileImageUrl forKey:KEY_USER_IMG];
        //[defaults setObject:obj forKey:KEY_USER_SERVER_JSON_DATA];
        [defaults synchronize];
    }
    [self.navigationController popViewControllerAnimated:YES];
    if ([finishTarget retainCount] > 0 && [finishTarget respondsToSelector:finishAction]) {
        [finishTarget performSelector:finishAction  withObject:nil];
    }
    else {
        [DataController setShenbianVCNeedRefreash:YES];
        [self.tabBarController setSelectedIndex:0 ];
    }
}
/**注销用户**/
- (void) logout
{
    //恢复默认
     mOpCommond = 0;
    //退出登陆
    [self removeCachedOAuthDataForUsername:mOAuthEngine.username];
	[mOAuthEngine signOut];
//    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
//    [defaults setObject:@"" forKey:KEY_USER_SCREEN_NAME];
//    [defaults setObject:@"" forKey:KEY_USER_SERVER_JSON_DATA];
//    [defaults synchronize];
    [self openAuthenticateView];
}
- (void)alertForLogout:(NSString *)message
{
    SoftNoticeView * msgBox = [[SoftNoticeView alloc] initWithFrame:CGRectMake(80, 160, 160, 160)];
    [msgBox setMessage:message];
    [msgBox setActivityindicatorHidden:YES];
    [self.view addSubview:msgBox];
    [msgBox start];
    [self performSelector:@selector(closeAlertForLogout:) withObject:msgBox afterDelay:2.5f];
    
}
- (void)closeAlertForLogout:(SoftNoticeView *)msgBox
{
    [msgBox stop];
    [msgBox removeFromSuperview];
    [msgBox release];
}


#pragma mark -
#pragma mark - UIScrollViewDelegate stuff
- (void)scrollViewDidScroll:(UIScrollView *)_scrollView
{
    if (pageControlIsChangingPage) {
        return;
    }
    
	/*
	 *	We switch page at 50% across
	 */
    CGFloat pageWidth = _scrollView.frame.size.width;
    int page = floor((_scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    mPageControl.currentPage = page;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)_scrollView 
{
    pageControlIsChangingPage = NO;
}

#pragma mark -
#pragma mark PageControl stuff

- (IBAction)changePage:(id)sender 
{
	/*
	 *	Change the scroll view
	 */
    CGRect frame = mScrollView.frame;
    frame.origin.x = frame.size.width * mPageControl.currentPage;
    frame.origin.y = 0;
	
    [mScrollView scrollRectToVisible:frame animated:YES];
    
	/*
	 *	When the animated scrolling finishings, scrollViewDidEndDecelerating will turn this off
	 */
    pageControlIsChangingPage = YES;
}
@end
