//
//  StatusPostController.m
//  WeiTansuo
//
//  Created by Liu Quan on 11/2/11.
//  Copyright 2011 Invidel. All rights reserved.
//

#import "StatusPostController.h"
#import "DataController.h"
#import "UIViewControllerCategory.h"

@implementation StatusPostController

@synthesize status = mStatus;
@synthesize oAuthEngine = mOAuthEngine;
@synthesize finishAction;
@synthesize finishTarget;



- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)dealloc
{
    [mSoftNoticeViewLoad release];
    [mStatus release];
    [mOAuthEngine release];
    [mPostContent release];
    
    [super dealloc];
}

#pragma mark - View lifecycle


// Implement loadView to create a view hierarchy programmatically, without using a nib.
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
//    titleLable.text = @"发微博";
//    titleLable.textColor = [UIColor whiteColor];
//    [titleLable sizeToFit];
//    self.navigationItem.titleView = titleLable;
//    [titleLable release];
//    
//    //背景
//    [self.view setBackgroundColor:[UIColor darkGrayColor]];    
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
    detailLabel.text = @"发微博";
    detailLabel.font = [UIFont fontWithName:@"TrebuchetMS-Bold" size:20];
    detailLabel.textColor = [UIColor whiteColor];
    [self.view addSubview:detailLabel];
    [detailLabel release];       
    //转发按钮
    UIButton * functionButton = [[UIButton alloc] initWithFrame:CGRectMake(270, 7, 40, 30)];
    [functionButton setImage:[UIImage imageNamed:@"send2.png"] forState:UIControlStateNormal];
    [functionButton setImage:[UIImage imageNamed:@"send2.png"] forState:UIControlStateHighlighted];
    [functionButton addTarget:self action:@selector(postNewStatus) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:functionButton];
    [functionButton release]; 
    
//    //导航右侧按钮
//    UIBarButtonItem * rightButtionItem = [[UIBarButtonItem alloc] 
//                                          initWithImage:[UIImage imageNamed:@"send2.png"]
//                                          style:UIBarButtonItemStyleDone
//                                          target:self
//                                          action:@selector(postNewStatus)];
//    self.navigationItem.rightBarButtonItem = rightButtionItem;
//    [rightButtionItem release];
    
    //照相按钮
    cameraButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    
    
    [cameraButton setFrame:CGRectMake(20, 170, 100, 25)];
    [cameraButton setTitle:@"照相" forState:UIControlStateNormal];
    //    [nextButton setImage:[UIImage imageNamed:@"placeBG.png"] forState:UIControlStateNormal];
    //    [nextButton setImage:[UIImage imageNamed:@"placeBGPr.png"] forState:UIControlStateHighlighted];
    [cameraButton addTarget:self action:(@selector(toCamera)) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:cameraButton];    
    
    
    //欲转发内容 
    if (!mPostContent) {
        mPostContent = [[UITextView alloc] initWithFrame:CGRectMake(10.f, 37.f + 10.f, 300.f, 104.f)];
        mPostContent.font = [UIFont fontWithName:@"Arial" size:16];
        //录入框加圆角边框
        [mPostContent.layer setBackgroundColor:[[UIColor whiteColor] CGColor]];
        [mPostContent.layer setBorderColor:[[UIColor grayColor] CGColor]];
        [mPostContent.layer setBorderWidth:1.0];
        [mPostContent.layer setCornerRadius:8.0];
        [mPostContent.layer setMasksToBounds:YES];
        mPostContent.clipsToBounds = YES;
        NSMutableString * postText = [[NSMutableString alloc] init];
        if ([[DataController getMinLocationDescription] length] > 0) {
            [postText appendFormat:@" 我在#%@#", [DataController getMinLocationDescription]];
        }         
        mPostContent.text = postText;
        [postText release];
        NSRange range;                                  //光标位置
        range.location = 0;
        range.length  = 0;
        mPostContent.selectedRange = range;
        [self.view addSubview:mPostContent];
        [mPostContent becomeFirstResponder];
    }
    
    
    
    
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
//add

/**键盘对应事件**/
- (void) keyboardWillShow:(NSNotification *)notification {
    NSDictionary * info = [notification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size; 
    
    if (kbSize.height == 216) {
        
        [UIView beginAnimations:nil context:NULL]; 
        mPostContent.frame = CGRectMake(10.f, 37.f + 10.f, 300.f, 104.f);
        cameraButton.frame = CGRectMake(20, 160+40, 100, 25);
        [UIView commitAnimations];    }
    else if (kbSize.height == 252)
    {
        [UIView beginAnimations:nil context:NULL]; 
        mPostContent.frame = CGRectMake(10.f, 37.f + 10.f, 300.f, 104);
        cameraButton.frame = CGRectMake(20, 124+40, 100, 25);           
        [UIView commitAnimations];
        
    }
}

-(void)toCamera
{
    TakePictureViewController * takePictureViewController = [[TakePictureViewController alloc] init];
    [takePictureViewController setHidesBottomBarWhenPushed:YES];
    self.finishTarget = self;
    self.finishAction = @selector(showCameraPic);
    [self.navigationController pushViewController:takePictureViewController animated:YES];
    [takePictureViewController release];
    
}

- (void)showCameraPic
{
    UIImage * cameraPic = (UIImage *)[DataController getCamera];
    //opreation the camera to small
    
    UIImageView * showSmallPic = [[UIImageView alloc] initWithImage:cameraPic];
    [self.view addSubview:showSmallPic];
    [showSmallPic release];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    mPostContent = nil;
    [mPostContent release];
    [[NSNotificationCenter defaultCenter] removeObserver:self]; 
}

-(void) back
{
    
    [self.navigationController popViewControllerAnimated:YES];
    if (mPostState == 1) {
        if ( [finishTarget retainCount] > 0 && [finishTarget respondsToSelector:finishAction]) {
            [finishTarget performSelector:finishAction  withObject:nil];
        }
    }
}



/**发送**/
- (void)postNewStatus
{
	WeiboClient *client = [[WeiboClient alloc] initWithTarget:self 
													   engine:mOAuthEngine
													   action:@selector(postStatusDidSucceed:obj:)];
	client.context = [mPostContent retain];
    [client post:mPostContent.text];
	
}

- (void)postStatusDidSucceed:(WeiboClient*)sender obj:(NSObject*)obj;
{
    UITextView *sentDraft=nil;
	if (sender.context && [sender.context isKindOfClass:[UITextView class]]) {
		sentDraft = (UITextView *)sender.context;
		[sentDraft autorelease];
	}
	
    if (sender.hasError) {
        [sender alert];	
        return;
    }
    
    NSDictionary *dic = nil;
    if (obj && [obj isKindOfClass:[NSDictionary class]]) {
        dic = (NSDictionary*)obj;    
    }
	
    if (dic) {
        Status* sts = [Status statusWithJsonDictionary:dic];
		if (sts) {
			//delete draft!
			if (sentDraft) {
				
			}
		}
    }
    [mSoftNoticeViewLoad stop];
    [mSoftNoticeViewLoad setHidden:YES];
    
    if (sender.hasError) {
        mPostState = 2;
        switch (sender.statusCode) {
            case 400:
                [self alertForRePost:@"重复发送"];
                break;    
            default:
                [self alertForRePost:@"网络异常"];
                break;
        }
    }
	else {
        mPostState = 1;
        [self alertForRePost:@"发送成功"];
    }
	//[self cancel:nil];
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
- (void)closeAlertForRePost:(SoftNoticeView *)msgBox
{
    [msgBox stop];
    [msgBox removeFromSuperview];
    [msgBox release];
    if (mPostState == 1) {
        [self back];
    } 
    else {
        mPostState = 0;
    }
}

@end
