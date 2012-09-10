//
//  SettingViewController.m
//  WeiTansuo
//
//  Created by Sai Li on 8/29/11.
//  Copyright 2011 Invidel. All rights reserved.
//

#import "SettingRootViewController.h"
#import <QuartzCore/QuartzCore.h>

#define KEY_USER_SCREEN_NAME    @"keyScreenName"
#define KEY_USER_IMG            @"keyUserImg"
#define KEY_USER_NAME           @"keyUserName"
#define KEY_USER_SERVER_JSON_DATA      @"keyUserServerJsonData" //as title

#define kOAuthConsumerKey		@"2375310633"	//Key of my weibo API, you can check from the account of your weibo developer panel
#define kOAuthConsumerSecret	@"2469b03e646c57b7c987b261c638629f"		//KeySecret of my weibo API, you can check from the account of your weibo developer panel

@implementation SettingRootViewController
@synthesize finishTarget,finishAction;
@synthesize oAuthEngine = mOauthEngine;

@synthesize oAuthViewController = mOAuthViewController;


- (id)init
{
    self = [super init];
    if (self) {
        self.tabBarItem = [[[UITabBarItem alloc] initWithTitle:@"更多" 
                                                         image:[UIImage imageNamed:@"tab_icon_4_nor.png"]
                                                           tag:4] autorelease];
        
        mOAuthEngine = [DataController getOAuthEngine];
        
//        self.tabBarItem = [[[UITabBarItem alloc] initWithTabBarSystemItem:UITabBarSystemItemMore
//                                                                     tag:4] autorelease];
//        [self.tabBarItem setTitle:@"更多"];
    }
    return self;
}

- (void)dealloc
{
    [mTableView release];
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark -
#pragma mark - 视图

- (void)loadView
{
    [super loadView];  
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.navigationController.navigationBar setHidden:YES];
    
    //头部中间标题
    UILabel * titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(85, 7, 150, 30)];
    titleLabel.textAlignment = UITextAlignmentCenter;
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.text = @"更多";
    titleLabel.font = [UIFont fontWithName:@"TrebuchetMS-Bold" size:20];
    titleLabel.textColor = [UIColor whiteColor];
    [self.view addSubview:titleLabel];
    [titleLabel release];
    
    if (!mTableView) {        
        mTableView = [[UITableView alloc] initWithFrame:CGRectMake(6, 46, 308, 414) 
                                                  style:UITableViewStyleGrouped];
        mTableView.delegate = self;
        mTableView.dataSource = self;
        [mTableView setBackgroundColor:[UIColor clearColor]];
        [self.view addSubview:mTableView];
    }
   
    //主流程开始
    [self tableViewBegin];
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    [mTableView release];
    mTableView = nil;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
}

#pragma mark -
#pragma mark - 展示数据 之 [列表展示]
/**列表开始展示**/
- (void) tableViewBegin
{
    [mTableView reloadData];
}
/**生成列表表格 Height**/
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{  
    return 40;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return 1;
            break;
        case 1:
            return 3;
            break;
        default:
            return 0;
            break;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    switch (section) {
        case 0: {
            return @"帐号管理";
        } break;
        case 1: {
            return @"关于我们";
        } break;
        default: {
            return @"更多";
        } break;
    }
}

/**生成列表表格**/
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"setting_cell"];
    
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"setting_cell"] autorelease];
    }
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.textLabel.font = [UIFont fontWithName:@"Arial" size:16];
    cell.textLabel.textColor = [UIColor blackColor];
    
    switch (indexPath.section) {
        case 0: {
                switch (indexPath.row) {
                    case 0:  
                        //注销
                        //cell.imageView.image = [UIImage imageNamed:@"hot.png"];
                        cell.textLabel.text = @"账号管理";
                        UILabel * hellolable = [[UILabel alloc] initWithFrame:CGRectMake(80, 10, 120, 20)];
                        [hellolable setFont:[UIFont fontWithName:@"Arial" size:14]];
                        [hellolable setTextColor:[UIColor grayColor]];
                        [hellolable setText:@"（点击注销帐号）"];
                        [hellolable setBackgroundColor:[UIColor clearColor]];
                        [cell addSubview:hellolable];
                        [hellolable release];
                        
                        UIButton * logoutBtn = [[UIButton alloc] initWithFrame:CGRectMake(200, 6, 60, 28)];
                        [logoutBtn setTitle:@"已登陆" forState:UIControlStateNormal];
                        [logoutBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                        [logoutBtn setBackgroundColor:[UIColor colorWithHue:135/255.f saturation:206/255.f brightness:250/255.f alpha:1]];
                        [logoutBtn.titleLabel setFont:[UIFont fontWithName:@"Arial" size:14]];
//                        [logoutBtn setBackgroundImage:[UIImage imageNamed:@"login_bg.png"] forState:UIControlStateNormal];
                        logoutBtn.layer.cornerRadius = 4.f;
                        [cell addSubview:logoutBtn];
                        [logoutBtn release];
                        break;
                    default:
                        break;
                }
            }

            break;
            
        case 1: 
            switch (indexPath.row) {
                    case 0: 
                        //反馈
                        //cell.imageView.image = [UIImage imageNamed:@"hot.png"];
                        cell.textLabel.text = @"用户反馈";
                        break;
                    case 1:
                        //使用说明
                        //cell.imageView.image = [UIImage imageNamed:@"hot.png"];
                        cell.textLabel.text = @"使用说明";
                        break;
                    case 2: 
                        //关于我们
                        //cell.imageView.image = [UIImage imageNamed:@"hot.png"];
                        cell.textLabel.text = @"关于我们";
                        break;
//                    case 3: 
//                        //发微博
//                        //cell.imageView.image = [UIImage imageNamed:@"hot.png"];
//                        cell.textLabel.text = @"发微博";
//                        break;
                    default:
                        break;
            }
            break;
        case 2:
            switch (indexPath.row) {
                case 0:
                    //我的微博
                    //cell.imageView.image = [UIImage imageNamed:@"hot.png"];
                    cell.textLabel.text = @"我的微博";
                    break;
                    
                default:
                    break;
            }
            break;
        default:
            break;
    }
    return cell;
    
}
/**表格点击事件处理,查微博的详细信息**/
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [mTableView deselectRowAtIndexPath:indexPath animated:YES];
    switch (indexPath.section) {
        case 0:
            switch (indexPath.row) {
                case 0:
                    [self confrimlogout];
                    break;   
                default:
                    break;
            }
            break;
        case 1:
            switch (indexPath.row) {
                case 0:
                    [self toFeedback];
                    break;
                case 1:
                    [self toUserManual];
                    break; 
                case 2:
                    [self toAboutUs];
                    break;
//                case 3:
//                    [self toMyBlog];
//                    break;
                default:
                    break;
            }
            break;
        case 2:
            switch (indexPath.row) {
                case 0:
                    [self toMyProfile];
                    break;
                default:
                    break;
            }
        default:
            
            break;
    }
}

#pragma mark -
#pragma mark - 事件
- (void)cancel
{
//    mOAuthViewController.opCommond = 1;//注销命令
//    [self removeCachedOAuthDataForUsername:mCurrentUser.screenName];
//    [mOAuthViewController setHidesBottomBarWhenPushed:YES];
//    [self.view removeFromSuperview];
//    [self.navigationController pushViewController:mOAuthViewController animated:NO];
//    NSLog(@"username is %@", [mOAuthEngine username]);
    [self removeCachedOAuthDataForUsername:(NSString *)[mOAuthEngine username]];
    [mOAuthEngine signOut];
    [self.tabBarController setSelectedIndex:0];
    
    UIViewController * controller = [OAuthController controllerToEnterCredentialsWithEngine:mOAuthEngine
                                                                                   delegate:self];
	if (controller) {
		[self presentModalViewController:controller animated:NO];
    }    
}


- (void)removeCachedOAuthDataForUsername:(NSString *) username
{
	NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    [defaults removeObjectForKey:KEY_USER_SCREEN_NAME];
    [defaults removeObjectForKey:KEY_USER_IMG];
    [defaults removeObjectForKey:KEY_USER_SERVER_JSON_DATA];
    [defaults synchronize];
}


- (void)toLogin
{
    mOAuthViewController.opCommond = 0;//登陆命令
    mOAuthViewController.finishTarget = self;
    mOAuthViewController.finishAction = @selector(goCover);
    [mOAuthViewController setHidesBottomBarWhenPushed:YES];
    [self.navigationController pushViewController:mOAuthViewController animated:NO];
}

- (void)goCover
{
    [self.tabBarController setSelectedIndex:0];
}

- (void)confrimlogout
{
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"确认登出" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确认", nil];
    [alert show];
    //[alert release];
}

- (void)modalView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
        case 0:
            //NSLog(@"nothing happen");
            break;
        case 1:
            [self cancel];
            break;
    }    [alertView release];
}

- (void)toLogout
{
    mOAuthViewController.opCommond = 1;//注销命令
    [mOAuthViewController setHidesBottomBarWhenPushed:YES];
    [self.navigationController pushViewController:mOAuthViewController animated:NO];
}
- (void)toUserManual
{
    WhatsnewsViewController * whatsnewvc = [[WhatsnewsViewController alloc] init];
    //[self setHidesBottomBarWhenPushed:YES];
    self.navigationController.navigationBarHidden = NO;
    [self.navigationController pushViewController:whatsnewvc animated:YES];
    [whatsnewvc release];
}
- (void)toFeedback
{
    FeedbackViewController * feedbackViewController = [[FeedbackViewController alloc] init];
    //[feedbackViewController setHidesBottomBarWhenPushed:YES];
    [self.navigationController pushViewController:feedbackViewController animated:NO];
    [feedbackViewController release];
}
- (void)toUserAccount
{
    UserAccountViewController * userAccountViewController = [[UserAccountViewController alloc] init];
    //[userAccountViewController setHidesBottomBarWhenPushed:YES];
    [self.navigationController pushViewController:userAccountViewController animated:YES];
    [userAccountViewController release];
}
- (void)toAboutUs
{
    AboutUsViewController * aboutUsViewController = [[AboutUsViewController alloc] init];
    [aboutUsViewController setHidesBottomBarWhenPushed:YES];
    [self.navigationController pushViewController:aboutUsViewController animated:YES];
    [aboutUsViewController release];

}
- (void)toMyBlog
{
    StatusPostController * statusPostController = [[StatusPostController alloc] init];
    statusPostController.oAuthEngine = [DataController getOAuthEngine];
    //[statusPostController setHidesBottomBarWhenPushed:YES];
    [self.navigationController pushViewController:statusPostController animated:YES];
    [statusPostController release];
    
}
- (void)toMyProfile
{
    ProfileViewController * profile = [[ProfileViewController alloc] init];
    [profile setHidesBottomBarWhenPushed:YES];
    profile.oauth = [DataController getOAuthEngine];
    [self.navigationController pushViewController:profile animated:YES];
    [profile release];
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

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    //[self.tabBarController.tabBar setHidden:NO];
}


@end
