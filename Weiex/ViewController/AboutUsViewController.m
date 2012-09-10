//
//  AboutUsViewController.m
//  WeiTansuo
//
//  Created by chenyan on 10/15/11.
//  Copyright 2011 Invidel. All rights reserved.
//

#import "AboutUsViewController.h"

@implementation AboutUsViewController


- (id)init
{
    [super init]; 
    if (self) {
        //self.title = @"关于我们";
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
    
    [self.navigationController.navigationBar setHidden:YES];
    
//    [self.view setBackgroundColor:[UIColor groupTableViewBackgroundColor]];
//    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"bg.png"]]];
    //返回按钮    
    UIButton * backButton = [[UIButton alloc] initWithFrame:CGRectMake(9, 7, 40, 30)];
    [backButton setImage:[UIImage imageNamed:@"title_icon_5_nor.png"] forState:UIControlStateNormal];
    [backButton setImage:[UIImage imageNamed:@"title_icon_5_press.png"] forState:UIControlStateHighlighted];
    [backButton addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:backButton];
    [backButton release];
    //头部中间标题
    UILabel * detailLabel = [[UILabel alloc] initWithFrame:CGRectMake(85, 7, 150, 30)];
    detailLabel.textAlignment = UITextAlignmentCenter;
    detailLabel.backgroundColor = [UIColor clearColor];
    detailLabel.text = @"关于我们";
    detailLabel.font = [UIFont fontWithName:@"TrebuchetMS-Bold" size:20];
    detailLabel.textColor = [UIColor whiteColor];
    [self.view addSubview:detailLabel];
    [detailLabel release];       
    
    //[self.view setBackgroundColor:[UIColor whiteColor]];
//    UIImageView * iconImg = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"114e@2x.png"]];
//    iconImg.frame = CGRectMake(100, 35, 114, 114);
//    [self.view addSubview:iconImg];
    
    UITextView * titleText ;
    titleText = [[[UITextView alloc] initWithFrame:self.view.frame] autorelease];
    titleText.frame = CGRectMake(10, 125, 300, 30);
    titleText.textColor = [UIColor blackColor];
    titleText.font = [UIFont fontWithName:@"Arial" size:18]; 
    titleText.editable = NO;
    titleText.scrollEnabled = YES;
    titleText.textAlignment = UITextAlignmentCenter;
    titleText.backgroundColor = [UIColor clearColor];
    titleText.text = @"Weiex = Weibo + Exploration ! ";
    [self.view addSubview:titleText];    
    
    UITextView * contentText ;
    contentText = [[[UITextView alloc] initWithFrame:self.view.frame] autorelease];
    contentText.frame = CGRectMake(10, 155, 300, 100);
    contentText.textColor = [UIColor blackColor];
    contentText.font = [UIFont fontWithName:@"Arial" size:13]; 
    contentText.editable = NO;
    contentText.textAlignment = UITextAlignmentCenter;
    contentText.scrollEnabled = NO;
    contentText.backgroundColor = [UIColor clearColor];
    contentText.text = @"     微探索是一款非常酷的基于地理位置的微博互动应用。简单点击即可获得周边的信息,从来不知道生活原来这么多姿多彩！";
    [self.view addSubview:contentText];    
    
    followBtn = [[UIButton alloc]initWithFrame:CGRectMake(97, 235, 128, 128)];
    [followBtn setBackgroundImage:[UIImage imageNamed:@"follow.png"]  forState:UIControlStateNormal];
    [followBtn addTarget:self action:(@selector(followUs)) 
                forControlEvents:(UIControlEventTouchUpInside)];
    
    [self.view addSubview:followBtn];
  
    UITextView * bottomText ;
    bottomText = [[[UITextView alloc] initWithFrame:self.view.frame] autorelease];
    bottomText.frame = CGRectMake(10, 370, 300, 30);
    bottomText.textAlignment = UITextAlignmentCenter;
    bottomText.textColor = [UIColor blackColor];
    bottomText.font = [UIFont fontWithName:@"Arial" size:10]; 
    bottomText.editable = NO;
    bottomText.scrollEnabled = NO;
    bottomText.backgroundColor = [UIColor clearColor];
    bottomText.text = @"Powered By CiJianNov 此间新创";
    [self.view addSubview:bottomText];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    [followBtn release];
}

-(void) back
{    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)followUs
{
    mOAuthEngine = [DataController getOAuthEngine];
    mWeiboClient = [[WeiboClient alloc] initWithTarget:self 
                                 engine:mOAuthEngine
                                 action:@selector(followUsFinished:obj:)]; 
    long long weiexId = 2307823313;
    [mWeiboClient follow:weiexId];
}

- (void)followUsFinished:(id)obj
{
    SoftNoticeView * msgBox = [[SoftNoticeView alloc] initWithFrame:CGRectMake(90, 130, 140, 140)];
    [msgBox setMessage:@"感谢关注！"];
    [msgBox setActivityindicatorHidden:NO];
    [msgBox setHidden:YES];
    [self.view addSubview:msgBox];

}

@end
