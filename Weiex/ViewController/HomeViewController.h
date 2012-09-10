//
//  HomeViewController.h
//  Weiex
//
//  Created by Man Tung Chan on 9/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WBEngine.h"
#import "WBSendView.h"
#import "WBLogInAlertView.h"
#import "WBSDKTimelineViewController.h"
#import "MTStatusBarOverlay.h"


@interface HomeViewController : UIViewController <WBEngineDelegate, UIAlertViewDelegate, WBLogInAlertViewDelegate, MTStatusBarOverlayDelegate>
{
    WBSDKTimelineViewController *timeLineViewController;
    UIActivityIndicatorView *indicatorView;
    
    UIButton *logInBtnOAuth;
//    UIButton *logInBtnXAuth;
}

@property (nonatomic, retain) WBEngine *weiBoEngine;
@property (nonatomic, retain) WBSDKTimelineViewController *timeLineViewController;

@end
