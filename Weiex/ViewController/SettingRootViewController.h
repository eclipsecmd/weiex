//
//  SettingViewController.h
//  WeiTansuo
//
//  Created by Sai Li on 8/29/11.
//  Copyright 2011 Invidel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OAuthViewController.h"
#import "FeedbackViewController.h"
#import "UserAccountViewController.h"
#import "AboutUsViewController.h"
#import "ProfileViewController.h"
#import "StatusPostController.h"
#import "WhatsnewsViewController.h"

@interface SettingRootViewController : UIViewController<UITableViewDelegate, UITableViewDataSource, UIAlertViewDelegate, OAuthControllerDelegate> {
    OAuthViewController * mOAuthViewController;
    OAuthEngine * mOAuthEngine;
    User * mCurrentUser;
    UITableView * mTableView;
}

@property (nonatomic, assign) OAuthViewController * oAuthViewController;
@property (nonatomic, retain) OAuthEngine * oAuthEngine;
@property (nonatomic,assign) id finishTarget;
@property (nonatomic,assign) SEL finishAction;

//about the oauth infos
- (void) removeCachedOAuthDataForUsername:(NSString *) username;
- (void) cancel;
- (void)confrimlogout;
//more info
- (void)tableViewBegin;
- (void)toLogin;
- (void)toLogout;
- (void)goCover;
- (void)toUserManual;
- (void)toFeedback;
- (void)toUserAccount;
- (void)toAboutUs;
- (void)toMyProfile;
- (void)toMyBlog;

@end
