//
//  UserAccountViewController.h
//  WeiTansuo
//
//  Created by chenyan on 10/15/11.
//  Copyright 2011 Invidel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OAuthViewController.h"
#import "UrlImageView.h"
#import "User.h"

@interface UserAccountViewController : UIViewController
{
    OAuthEngine * mOAuthEngine;
    OAuthViewController * mOAuthViewController;
    User * mCurrentUser;
    NSString * mUserName;
    NSString * mUserImg;
    
}

@property (nonatomic, retain) OAuthEngine * oAuthEngine;
@property (nonatomic,assign) id finishTarget;
@property (nonatomic,assign) SEL finishAction;

- (void) removeCachedOAuthDataForUsername:(NSString *) username;
- (void) cancel;

@end
