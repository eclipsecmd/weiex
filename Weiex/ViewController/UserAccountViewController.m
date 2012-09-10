//
//  UserAccountViewController.m
//  WeiTansuo
//
//  Created by chenyan on 10/15/11.
//  Copyright 2011 Invidel. All rights reserved.
//

#import "UserAccountViewController.h"

#define KEY_USER_SCREEN_NAME    @"keyScreenName"
#define KEY_USER_IMG            @"keyUserImg"
#define KEY_USER_NAME           @"keyUserName"
#define KEY_USER_SERVER_JSON_DATA      @"keyUserServerJsonData" //as title

@implementation UserAccountViewController

@synthesize finishTarget,finishAction;
@synthesize oAuthEngine = mOauthEngine;

- (id)init
{
    [super init]; 
    if (self) {
         mOAuthViewController = [[OAuthViewController alloc] init];
        NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
//        NSDictionary * userdic = ((NSDictionary *)[defaults objectForKey:KEY_USER_SERVER_JSON_DATA]);
        mUserName = [defaults objectForKey:KEY_USER_SCREEN_NAME];
        mUserImg = [defaults objectForKey:KEY_USER_IMG];
//        if (userdic) {
//            User * userEntity = [User userWithJsonDictionary:userdic];
//            uuu = userEntity.profileImageUrl;
////            [DataController setUser:userEntity];
////            mCurrentUser = userEntity;
//        }        
    }
    return self;
}
- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
}
*/


- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor groupTableViewBackgroundColor]];
    
    UIButton * cancelButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [cancelButton setFrame:CGRectMake(30, 250, 260, 30)];
    [cancelButton setBackgroundColor:[UIColor redColor]];
    [cancelButton setTitle:@"注销" forState:UIControlStateNormal];
    [cancelButton setBackgroundColor:[UIColor clearColor]];
    [cancelButton addTarget:self action:@selector(cancel) forControlEvents:UIControlEventTouchDown];
    [self.view addSubview:cancelButton];
    
    UrlImageView * userPicView = [[UrlImageView alloc] init];
    [userPicView setFrame:CGRectMake(15, 10, 40, 40)];
    //NSLog(@"nameimageurl:%@", (mCurrentUser.profileImageUrl);
    userPicView.imageUrl = mUserImg;
    [userPicView getImageByUrl:0];
    
    UIImageView * genderImg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:mCurrentUser.gender == 1 ? @"male.png" : @"female.png"]];
    [genderImg setFrame:CGRectMake(40, 6, 15, 18)];
    
    UILabel * userNameLabel = [[UILabel alloc] init];
    [userNameLabel setText:mUserName];
    [userNameLabel setBackgroundColor:[UIColor clearColor]];
    [userNameLabel setTextColor:[UIColor grayColor]];
    [userNameLabel setFrame:CGRectMake(60, 20, 250, 15)];
    
    [self.view addSubview:userPicView];
    [self.view addSubview:userNameLabel];
    [self.view addSubview:genderImg];
    
}

- (void)cancel{
    mOAuthViewController.opCommond = 1;//注销命令
    [self removeCachedOAuthDataForUsername:mCurrentUser.screenName];
    [mOAuthViewController setHidesBottomBarWhenPushed:YES];
    [self.navigationController pushViewController:mOAuthViewController animated:NO];
}


- (void)removeCachedOAuthDataForUsername:(NSString *) username
{
	NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    [defaults removeObjectForKey:KEY_USER_SCREEN_NAME];
    [defaults removeObjectForKey:KEY_USER_IMG];
    [defaults removeObjectForKey:KEY_USER_SERVER_JSON_DATA];
    [defaults synchronize];
}


- (void)viewDidUnload
{
    [super viewDidUnload];
    [mOAuthViewController release];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
@end
