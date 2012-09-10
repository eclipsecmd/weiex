//
//  OAuthViewController.h
//  WeiTansuo
//
//  Created by chishaq on 11-8-17.
//  Copyright 2011年 Invidel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OAuthEngine.h"
#import "OAuthController.h"
#import "DataController.h"
#import "SoftNoticeView.h"
#import "WeiboClient.h"
#import "DataController.h"
#import "User.h"

@interface OAuthViewController : UIViewController<OAuthControllerDelegate, UIScrollViewDelegate> {
    OAuthEngine * mOAuthEngine;
    int mOpCommond;                   //操作命令 0：默认（登陆） 1：注销
    UIScrollView* mScrollView;        //横向滚动区
	UIPageControl* mPageControl;      //横向翻页控制
    BOOL pageControlIsChangingPage;
    NSArray *contentList;
    UIButton * loginButton;
    
}


@property (nonatomic,assign) id finishTarget;
@property (nonatomic,assign) SEL finishAction;
@property (nonatomic,retain) OAuthEngine * oAuthEngine;
@property (nonatomic,assign) int opCommond;
@property (nonatomic, retain) UIView *scrollView;
@property (nonatomic, retain) UIPageControl* pageControl;
@property (nonatomic, retain) NSArray *contentList;

- (void)showView;
// init the pages from the pages
- (void)initDataWithPlist;

- (void) removeCachedOAuthDataForUsername:(NSString *) username;
- (void) openAuthenticateView;
- (void) logout;

- (void)getUserInfo: (NSString *)UserID;
- (void)getUserInfoFinished:(WeiboClient *)sender
                        obj:(NSObject*)obj ;


/* for pageControl */
- (IBAction)changePage:(id)sender;

@end
