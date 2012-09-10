//
//  StatusCommentViewController.m
//  WeiTansuo
//
//  Created by CMD on 10/9/11.
//  Copyright 2011 Invidel. All rights reserved.
//

#import "StatusCommentViewController.h"

#import "DataController.h"
#import "UIViewControllerCategory.h"

@implementation StatusCommentViewController

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
    [mCommentContent release];
    [mCheckboxToUser release];
    
    [super dealloc];
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
//    titleLable.text = @"评论";
//    titleLable.textColor = [UIColor whiteColor];
//    [titleLable sizeToFit];
//    self.navigationItem.titleView = titleLable;
//    [titleLable release];
//    
//    //背景
//    [self.view setBackgroundColor:[UIColor darkGrayColor]];
//    
//    //导航栏
//    [self setBackBarItem:@selector(back)];
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
    detailLabel.text = @"评论";
    detailLabel.font = [UIFont fontWithName:@"TrebuchetMS-Bold" size:20];
    detailLabel.textColor = [UIColor whiteColor];
    [self.view addSubview:detailLabel];
    [detailLabel release];       
    //转发按钮
    UIButton * functionButton = [[UIButton alloc] initWithFrame:CGRectMake(270, 7, 40, 30)];
    [functionButton setImage:[UIImage imageNamed:@"send2.png"] forState:UIControlStateNormal];
    [functionButton setImage:[UIImage imageNamed:@"send2.png"] forState:UIControlStateHighlighted];
    [functionButton addTarget:self action:@selector(comment) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:functionButton];
    [functionButton release];        
    
//    //导航右侧按钮
//    UIBarButtonItem * rightButtionItem = [[UIBarButtonItem alloc] 
//                                          initWithImage:[UIImage imageNamed:@"send2.png"]
//                                          style:UIBarButtonItemStyleDone
//                                          target:self
//                                          action:@selector(comment)];
//    self.navigationItem.rightBarButtonItem = rightButtionItem;
//    [rightButtionItem release];
    
    //欲评论内容 
    if (!mCommentContent) {
        mCommentContent = [[UITextView alloc] initWithFrame:CGRectMake(10.f, 37.f + 10.f, 300, 140.f)];
        mCommentContent.font = [UIFont fontWithName:@"Arial" size:16]; 
        //录入框加圆角边框
        [mCommentContent.layer setBackgroundColor:[[UIColor whiteColor] CGColor]];
        [mCommentContent.layer setBorderColor:[[UIColor grayColor] CGColor]];
        [mCommentContent.layer setBorderWidth:1.0];
        [mCommentContent.layer setCornerRadius:8.0];
        [mCommentContent.layer setMasksToBounds:YES];
        mCommentContent.clipsToBounds = YES;
        if ([[DataController getMinLocationDescription] length] > 0) {
//            [repostText appendFormat:@" 我在#%@#", [DataController getMinLocationDescription]];
             mRepostPre = [NSString stringWithFormat:@" 我在#%@#", [DataController getMinLocationDescription]];
        }        
        [mRepostEnd appendFormat:@" 来自#Weiex# @%@ " ,mStatus.user.name];
        NSMutableString * tempString = [[NSMutableString alloc]initWithString:mRepostPre];
        mRepostText = tempString;
        
        [mRepostText appendFormat:mRepostEnd];
        mCommentContent.text = mRepostText;
        [tempString release];
        
        NSRange range;                                  //光标位置
        range.location = 0;
        range.length  = 0;
        mCommentContent.selectedRange = range;
        [self.view addSubview:mCommentContent];
        [mCommentContent becomeFirstResponder];
    }
    //复选框
    if (!mCheckboxToUser) {
        mCheckboxToUser = [[myCheckBox alloc] initWithFrame:CGRectMake(15, 150+40, 290, 15) rightTitle:@"同时转发到我的微博"];
        [self.view addSubview:mCheckboxToUser];
    }
    
    //原微博内容
    mOriginalLable= [[UILabel alloc] initWithFrame:CGRectMake(10+10, 180+40, 280, 15)];
    NSString * oriiginalText = mStatus.text;
    oriiginalText = [oriiginalText length] > 20 ? [oriiginalText substringToIndex:20]: oriiginalText;
    [mOriginalLable setText:[NSString stringWithFormat:@"微博：%@", oriiginalText]];
    [mOriginalLable setBackgroundColor:[UIColor clearColor]];
    [mOriginalLable setFont:[UIFont fontWithName:@"Arial" size:13]];
    [mOriginalLable setTextColor:[UIColor blackColor]];
    [self.view addSubview:mOriginalLable];
    [mOriginalLable release];
    
    //    
    mChoosePlace = [UIButton buttonWithType:UIButtonTypeCustom];
    mChoosePlace.frame = CGRectMake(260, 150+40, 40, 20);
    [mChoosePlace setBackgroundColor: [UIColor blackColor]];
    [mChoosePlace setTitle:@"c" forState:normal];
    [mChoosePlace addTarget:self action:(@selector(choosePlace)) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:mChoosePlace];

    //加载框
    if (!mSoftNoticeViewLoad) {
        mSoftNoticeViewLoad = [[SoftNoticeView alloc] initWithFrame:CGRectMake(90, 40+40, 140, 140)];
        [mSoftNoticeViewLoad setMessage:@"发送中..."];
        [mSoftNoticeViewLoad setActivityindicatorHidden:NO];
        [mSoftNoticeViewLoad setHidden:YES];
        [self.view addSubview:mSoftNoticeViewLoad];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    
}

- (void) viewDidUnload
{
    [super viewDidUnload];
    mCheckboxToUser = nil;
    [mCheckboxToUser release];
    mSoftNoticeViewLoad = nil;
    [mSoftNoticeViewLoad release];
    mCommentContent = nil;
    [mCommentContent release];
    
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
    mCommentContent.text = mRepostText;
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
        
        mCommentContent.frame = CGRectMake(10.f, 37.f+10.f, 300.f, 140.f);
        mCheckboxToUser.frame = CGRectMake(15, 150+40, 290, 15);
        
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
        
        mCommentContent.frame = CGRectMake(10.f, 37.f+10, 300.f, 104.f);
        mCheckboxToUser.frame = CGRectMake(15, 114+40, 290, 15);
    
        mOriginalLable.frame = CGRectMake(10+10, 144+40, 280, 15);
        mChoosePlace.frame = CGRectMake(260, 114+40, 40, 20);
        [UIView commitAnimations];
        
    }
}

/**回退**/
-(void) back
{
    [self.navigationController popViewControllerAnimated:YES];
    if (mCommentState == 1) {
        if ( [finishTarget retainCount] > 0 && [finishTarget respondsToSelector:finishAction]) {
            [finishTarget performSelector:finishAction  withObject:nil];
        }
        
    }
}

#pragma mark - 
#pragma mark - 评论
/**评论**/
- (void)comment
{
    mCommentState = 3;
    [mSoftNoticeViewLoad setHidden:NO];
    [mSoftNoticeViewLoad start];
    
	WeiboClient * weiboClient = [[WeiboClient alloc] initWithTarget:self 
                                                             engine:mOAuthEngine
                                                             action:@selector(commentStatusfinished:obj:)];
    [weiboClient comment:mStatus.statusId commentId:mStatus.statusId comment:mCommentContent.text withoutmention:0 commentori:[mCheckboxToUser checkSelected]];
}
/**评论结束**/
- (void)commentStatusfinished:(WeiboClient*)sender obj:(NSObject*)obj;
{    
    [mSoftNoticeViewLoad stop];
    [mSoftNoticeViewLoad setHidden:YES];
    
    if (sender.hasError) {
        mCommentState = 2;
        switch (sender.statusCode) {
            case 400:
                [self alertForComment:@"重复评论"];
                break;    
            default:
                [self alertForComment:@"网络异常"];
                break;
        }
    }
	else {
        mCommentState = 1;
        [self alertForComment:@"评论成功"];
    }
}
/**评论结束，开启弹出框**/
- (void)alertForComment:(NSString *)message
{
    SoftNoticeView * msgBox = [[SoftNoticeView alloc] initWithFrame:CGRectMake(90, 40+40, 140, 140)];
    [msgBox setMessage:message];
    [msgBox setActivityindicatorHidden:YES];
    [self.view addSubview:msgBox];
    [msgBox start];
    [self performSelector:@selector(closeAlertForComment:) withObject:msgBox afterDelay:2.f];
    
}
/**评论结束，关闭弹出框**/
- (void)closeAlertForComment:(SoftNoticeView *)msgBox
{
    [msgBox stop];
    [msgBox removeFromSuperview];
    [msgBox release];
    if (mCommentState == 1) {
        [self back];
    } 
    else {
        mCommentState = 0;
    }
}


@end
