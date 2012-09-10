//
//  AboutUsViewController.h
//  WeiTansuo
//
//  Created by chenyan on 10/15/11.
//  Copyright 2011 Invidel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WeiboClient.h"
#import "DataController.h"
#import "SoftNoticeView.h"

@interface AboutUsViewController : UIViewController
{
    WeiboClient * mWeiboClient;
    OAuthEngine * mOAuthEngine;
    UIButton * followBtn;
}

- (void) back;
- (void)followUs;
- (void)followUsFinished:(id)obj;


@end
