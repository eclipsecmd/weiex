//
//  StatusRePostController.m
//  WeiTansuo
//
//  Created by Sai Li on 8/23/11.
//  Copyright 2011 Invidel. All rights reserved.
//

#import "StatusRePostController.h"
#import "DataController.h"
#import "UIViewControllerCategory.h"

@implementation StatusRePostController

@synthesize status = mStatus;
@synthesize oAuthEngine = mOAuthEngine;
@synthesize finishAction;
@synthesize finishTarget;

#pragma mark -
#pragma mark - 构造与析构
- (id)init
{
    self = [super init];
    if (self) {
        mRepostText = [[NSMutableString alloc] init];
        mRepostEnd = [[NSMutableString alloc] init];
    }
    return self;
}

- (void)dealloc
{
    [mSoftNoticeViewLoad release];
    [mStatus release];
    [mOAuthEngine release];
    [mRepostContent release];
    [mCheckboxToUser release];
    [mCheckboxOriginalAuthor release];
    [mBackView release];
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
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
//    //标题
//    UILabel * titleLable = [[UILabel alloc] init];
//    titleLable.textAlignment = UITextAlignmentCenter;
//    titleLable.backgroundColor = [UIColor clearColor];
//    titleLable.text = @"转发";
//    titleLable.textColor = [UIColor whiteColor];
//    [titleLable sizeToFit];
//    self.navigationItem.titleView = titleLable;
//    [titleLable release];   
//    //背景
//    [self.view setBackgroundColor:[UIColor darkGrayColor]];
//    //导航栏
//    [self setBackBarItem:@selector(back)];
    mBackView = [[UIView alloc]initWithFrame:CGRectMake(10, 37+10+100+10, 300, 40)];
    [mBackView setBackgroundColor:[UIColor clearColor]];

    //返回按钮    
    UIButton * backButton = [[UIButton alloc] initWithFrame:CGRectMake(9,7, 40, 30)];
    [backButton setImage:[UIImage imageNamed:@"title_icon_5_nor.png"] forState:UIControlStateNormal];
    [backButton setImage:[UIImage imageNamed:@"title_icon_5_press.png"] forState:UIControlStateHighlighted];
    [backButton addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:backButton];
    [backButton release];
    //头部中间标题
    UILabel * detailLabel = [[UILabel alloc] initWithFrame:CGRectMake(85, 7, 150, 30)];
    detailLabel.textAlignment = UITextAlignmentCenter;
    detailLabel.backgroundColor = [UIColor clearColor];
    detailLabel.text = @"转发";
    detailLabel.font = [UIFont fontWithName:@"TrebuchetMS-Bold" size:20];
    detailLabel.textColor = [UIColor whiteColor];
    [self.view addSubview:detailLabel];
    [detailLabel release];       
    //转发按钮
    UIButton * functionButton = [[UIButton alloc] initWithFrame:CGRectMake(270, 7, 40, 30)];
    [functionButton setImage:[UIImage imageNamed:@"send2.png"] forState:UIControlStateNormal];
    [functionButton setImage:[UIImage imageNamed:@"send2.png"] forState:UIControlStateHighlighted];
    [functionButton addTarget:self action:@selector(rePost) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:functionButton];
    [functionButton release];    
    
//    //导航右侧按钮
//    UIBarButtonItem * rightButtionItem = [[UIBarButtonItem alloc] 
//                                          initWithImage:[UIImage imageNamed:@"send2.png"]
//                                          style:UIBarButtonItemStyleDone
//                                          target:self
//                                          action:@selector(rePost)];
//    self.navigationItem.rightBarButtonItem = rightButtionItem;
//    [rightButtionItem release];
    
    //欲转发内容 
    if (!mRepostContent) {
        mRepostContent = [[UITextView alloc] initWithFrame:CGRectMake(10.f, 37.f + 10.f, 300.f, 140.f)];
        mRepostContent.font = [UIFont fontWithName:@"Arial" size:16];
        //录入框加圆角边框
        [mRepostContent.layer setBackgroundColor:[[UIColor whiteColor] CGColor]];
        [mRepostContent.layer setBorderColor:[[UIColor grayColor] CGColor]];
        [mRepostContent.layer setBorderWidth:1.0];
        [mRepostContent.layer setCornerRadius:8.0];
        [mRepostContent.layer setMasksToBounds:YES];
        mRepostContent.clipsToBounds = YES;
        
        if ([[DataController getMinLocationDescription] length] > 0) {
            mRepostPre = [NSString stringWithFormat:@" 我在#%@#", [DataController getMinLocationDescription]];
        }        
        [mRepostEnd appendFormat:@" 来自#Weiex# @%@ " ,mStatus.user.name];
        NSMutableString * tempString = [[NSMutableString alloc]initWithString:mRepostPre];
        mRepostText = tempString;
        
        [mRepostText appendFormat:mRepostEnd];
        mRepostContent.text = mRepostText;
        [tempString release];
        NSRange range;                                  //光标位置
        range.location = 0;
        range.length  = 0;
        mRepostContent.selectedRange = range;
        [self.view addSubview:mRepostContent];
        [mRepostContent becomeFirstResponder];
    }
       
    
    //评论给作者选项复选框
    //145 is the Origin y
    if (!mCheckboxToUser) {
        mCheckboxToUser = [[myCheckBox alloc] initWithFrame:CGRectMake(15, 150+40, 290, 17) rightTitle:[NSString stringWithFormat:@"评论给 %@", mStatus.user.name]];
    
        [self.view addSubview:mCheckboxToUser];
    }
    //评论给原作者选项复选框
    if (!mCheckboxOriginalAuthor && mStatus.retweetedStatus != nil) {
        mCheckboxOriginalAuthor = [[myCheckBox alloc] initWithFrame:CGRectMake(10+10, 160+40, 290, 15) rightTitle:[NSString stringWithFormat:@"评论给 %@", mStatus.retweetedStatus.user.name]];

        [self.view addSubview:mCheckboxOriginalAuthor];
        
        [mCheckboxToUser setFrame:CGRectMake(15, 145+40, 290, 15)];
        [self.view addSubview:mCheckboxToUser];
    }

    mOriginalLable = [[UILabel alloc] initWithFrame:CGRectMake(10+10, 180+40, 280, 15)];//为了放choosePlace，由300改为280
    NSString * oriiginalText = mStatus.retweetedStatus == nil ? mStatus.text : mStatus.retweetedStatus.text;
    oriiginalText = [oriiginalText length] > 20 ? [oriiginalText substringToIndex:20]: oriiginalText;
    [mOriginalLable setText:[NSString stringWithFormat:@"原微博 %@", oriiginalText]];
    [mOriginalLable setBackgroundColor:[UIColor clearColor]];
    [mOriginalLable setFont:[UIFont fontWithName:@"Arial" size:12]];
    [mOriginalLable setTextColor:[UIColor blackColor]];
    [self.view addSubview:mOriginalLable];
    
    mChoosePlace = [UIButton buttonWithType:UIButtonTypeCustom];
    mChoosePlace.frame = CGRectMake(260, 150+40, 40, 20);
    [mChoosePlace setBackgroundColor: [UIColor blackColor]];
    [mChoosePlace setTitle:@"c" forState:normal];
    [mChoosePlace addTarget:self action:(@selector(choosePlace)) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:mChoosePlace];
    
    //加载框
    if (!mSoftNoticeViewLoad) {
        mSoftNoticeViewLoad = [[SoftNoticeView alloc] initWithFrame:CGRectMake(90, 40+40, 140, 140)];
        [mSoftNoticeViewLoad setMessage:@"转发中..."];
        [mSoftNoticeViewLoad setActivityindicatorHidden:NO];
        [mSoftNoticeViewLoad setHidden:YES];
        [self.view addSubview:mSoftNoticeViewLoad];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
//    [self.view addSubview:mBackView];   
}

- (void) viewDidUnload
{
    [super viewDidUnload];
    mCheckboxOriginalAuthor = nil;
    [mCheckboxOriginalAuthor release];
    mCheckboxToUser = nil;
    [mCheckboxToUser release];
    mSoftNoticeViewLoad = nil;
    [mSoftNoticeViewLoad release];
    mRepostContent = nil;
    [mRepostContent release];
    [mChoosePlace release];
    mBackView = nil;
    [mBackView release];
    [[NSNotificationCenter defaultCenter] removeObserver:self]; 
    
}

#pragma mark -
#pragma mark - 事件处理
/****/
//-(void)ischeck:(id)sender
//{
//    mCheckBoxSelected = !mCheckBoxSelected;
//    [mCheckboxToUser setSelected:mCheckBoxSelected];
//}
//add
//设置选择按钮的位置
- (void) setChoosePlaceButtonCGRect
{
//    32
  
    float buttonWidth = (mRepostPre.length-4) * 16;
      NSLog(@"set %f",buttonWidth);
    mChoosePlace.frame = CGRectMake(15, 9, buttonWidth, 20);
}
/**重新选择地点**/
- (void) choosePlace
{
    PlacesViewController * placeViewController = [[PlacesViewController alloc]init];
    placeViewController.finishTarget = self;
    placeViewController.finishAction = @selector(setPlace:);
    [self presentViewController:placeViewController animated:true completion:nil];
}
/**设定新地点**/
- (void) setPlace:(NSString *)newPlace
{
    mRepostPre =  [NSString stringWithFormat:@" 我在#%@#", newPlace];
    NSMutableString * tempString = [[NSMutableString alloc]initWithString:mRepostPre];
    mRepostText = tempString;
    
    [mRepostText appendFormat:mRepostEnd];
    [UIView beginAnimations:nil context:NULL]; 
    mRepostContent.text = mRepostText;
    [tempString release];
    [UIView commitAnimations];
}

/**键盘对应事件**/
- (void) keyboardWillShow:(NSNotification *)notification {
    NSDictionary * info = [notification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size; 

    if (kbSize.height == 216) {
        
        NSDictionary *userInfo = [notification userInfo];
        NSValue * animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
        NSTimeInterval animationDuration;
        [animationDurationValue getValue:&animationDuration];
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:animationDuration];
        
        mRepostContent.frame = CGRectMake(10.f, 37.f + 10.f, 300.f, 140.f);
        mCheckboxToUser.frame = CGRectMake(15, 150+40, 290, 17);
        
        if (!mCheckboxOriginalAuthor && mStatus.retweetedStatus != nil) {
            mCheckboxOriginalAuthor.frame =  CGRectMake(10+10, 160+40, 290, 15);
            [mCheckboxToUser setFrame:CGRectMake(15, 145+40, 290, 15)];
        
        }
        mOriginalLable.frame = CGRectMake(10+10, 180+40, 280, 15);
         mChoosePlace.frame = CGRectMake(260, 150+40, 40, 20);
        [UIView commitAnimations];
    }
    else if (kbSize.height == 252)
    {
        NSDictionary *userInfo = [notification userInfo];
        NSValue * animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
        NSTimeInterval animationDuration;
        [animationDurationValue getValue:&animationDuration];
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:animationDuration];
        
        mRepostContent.frame = CGRectMake(10.f, 37.f + 10.f, 300.f, 104.f);
        mCheckboxToUser.frame = CGRectMake(15, 114+40, 290, 17);
        
        if (!mCheckboxOriginalAuthor && mStatus.retweetedStatus != nil) {
            mCheckboxOriginalAuthor.frame =  CGRectMake(10+10, 124+40, 290, 15);
            [mCheckboxToUser setFrame:CGRectMake(15, 109+40, 290, 15)];
        }
        mOriginalLable.frame = CGRectMake(10+10, 144+40, 280, 15);
        mChoosePlace.frame = CGRectMake(260, 114+40, 40, 20);
        [UIView commitAnimations];

    }
}

/**回退**/
-(void) back
{
    
    [self.navigationController popViewControllerAnimated:YES];
    if (mRepostState == 1) {
        if ( [finishTarget retainCount] > 0 && [finishTarget respondsToSelector:finishAction]) {
            [finishTarget performSelector:finishAction  withObject:nil];
        }
    }
}

#pragma mark - 
#pragma mark - 转发
/**发送转发**/
- (void)rePost
{
    mRepostState = 3;
    [mSoftNoticeViewLoad setHidden:NO];
    [mSoftNoticeViewLoad start];
    
	WeiboClient * weiboClient = [[WeiboClient alloc] initWithTarget:self 
													   engine:mOAuthEngine
													   action:@selector(rePostStatusfinished:obj:)];
    [weiboClient repost:mStatus.statusId tweet:mRepostContent.text iscomment:[self getIsComment]];
}
/**转发结束**/
- (void)rePostStatusfinished:(WeiboClient*)sender obj:(NSObject*)obj;
{    
    [mSoftNoticeViewLoad stop];
    [mSoftNoticeViewLoad setHidden:YES];
    
    if (sender.hasError) {
        mRepostState = 2;
        switch (sender.statusCode) {
            case 400:
                [self alertForRePost:@"重复转发"];
                break;    
            default:
                [self alertForRePost:@"网络异常"];
                break;
        }
    }
	else {
        mRepostState = 1;
        [self alertForRePost:@"转发成功"];
    }
}
/**转发结束，开启弹出框**/
- (void)alertForRePost:(NSString *)message
{
    SoftNoticeView * msgBox = [[SoftNoticeView alloc] initWithFrame:CGRectMake(90, 40+40, 140, 140)];
    [msgBox setMessage:message];
    [msgBox setActivityindicatorHidden:YES];
    [self.view addSubview:msgBox];
    [msgBox start];
    [self performSelector:@selector(closeAlertForRePost:) withObject:msgBox afterDelay:2.f];
    
}
/**转发结束，关闭弹出框**/
- (void)closeAlertForRePost:(SoftNoticeView *)msgBox
{
    [msgBox stop];
    [msgBox removeFromSuperview];
    [msgBox release];
    if (mRepostState == 1) {
        [self back];
    } 
    else {
        mRepostState = 0;
    }
}

- (int)getIsComment
{
    if ([mCheckboxToUser checkSelected] == NO && [mCheckboxOriginalAuthor checkSelected] == NO) {
        return 0;
    }
    else if ([mCheckboxToUser checkSelected] == YES && [mCheckboxOriginalAuthor checkSelected] == NO) {
        return 1;
    }
    else if ([mCheckboxToUser checkSelected] == NO && [mCheckboxOriginalAuthor checkSelected] == YES) {
        return 2;
    }
    else if ([mCheckboxToUser checkSelected] == YES && [mCheckboxOriginalAuthor checkSelected] == YES)
    {
        return 3;
    }
    else {
        return 0;
    }
}

@end
