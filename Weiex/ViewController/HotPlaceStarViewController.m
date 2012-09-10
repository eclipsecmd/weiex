//
//  HotPlaceStarViewController.m
//  WeiTansuo
//
//  Created by Yuqing Huang on 11/30/11.
//  Copyright (c) 2011 Invidel. All rights reserved.
//

#import "HotPlaceStarViewController.h"

@implementation HotPlaceStarViewController

@synthesize contentText=mContentText;
@synthesize nowRegion=mNowRegion;
@synthesize regionLat=mRegionLat;
@synthesize regionLng=mRegionLng;
@synthesize regionProvince=mRegionProvince;
@synthesize regionType=mRegionType;

- (id)init
{
    self = [super init];
    if(self) {
        self.title = @"我喜欢这里...";
    }
    return self;
}

- (void)dealloc
{
    [super dealloc];

    [mContentText dealloc];
    [mNowRegion dealloc];
    [mRegionProvince dealloc];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - 视图

- (void)viewDidLoad
{
    [super viewDidLoad];
    
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
    detailLabel.text = @"热点添加";
    detailLabel.font = [UIFont fontWithName:@"TrebuchetMS-Bold" size:20];
    detailLabel.textColor = [UIColor whiteColor];
    [self.view addSubview:detailLabel];
    [detailLabel release];       

    
    UILabel * titleText = [[[UILabel alloc] initWithFrame:self.view.frame] autorelease];
    titleText.frame = CGRectMake(50, 75, 200, 30);
    titleText.textColor = [UIColor blackColor];
    [titleText setBackgroundColor:[UIColor clearColor]];
    titleText.font = [UIFont fontWithName:@"Arial" size:20]; 
    titleText.textAlignment = UITextAlignmentCenter;
    titleText.text = mNowRegion;
    [self.view addSubview:titleText];    
    

    mContentText = [[[UITextView alloc] initWithFrame:self.view.frame] autorelease];
    mContentText.frame = CGRectMake(30, 140, 260, 150);
    mContentText.delegate=self;
    mContentText.textColor = [UIColor grayColor];
    mContentText.font = [UIFont fontWithName:@"Arial" size:15]; 
    mContentText.editable = YES;
    mContentText.returnKeyType = UIReturnKeyDefault;
    mContentText.keyboardType  = UIKeyboardTypeDefault;
    mContentText.scrollEnabled = YES;
    mContentText.text = @"";
    //录入框加圆角边框
    [mContentText.layer setBackgroundColor:[[UIColor whiteColor] CGColor]];
    [mContentText.layer setBorderColor:[[UIColor grayColor] CGColor]];
    [mContentText.layer setBorderWidth:1.0];
    [mContentText.layer setCornerRadius:8.0];
    [mContentText.layer setMasksToBounds:YES];
    mContentText.clipsToBounds = YES;
    //键盘关闭层
    UIToolbar * topView = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, 320, 40)];  
    [topView setBarStyle:UIBarStyleBlackTranslucent];   
    UIBarButtonItem * btnSpace = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];  
    UIBarButtonItem * doneButton = [[UIBarButtonItem alloc]initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(closeKeyBoard)];  
    NSArray * buttonsArray = [NSArray arrayWithObjects:btnSpace,doneButton,nil];  
    [doneButton release];  
    [btnSpace release];   
    [topView setItems:buttonsArray];  
    [mContentText setInputAccessoryView:topView];  
    
    [self.view addSubview:mContentText];   
    
    
    UIButton * loveButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [loveButton setFrame:CGRectMake(120, 310, 80, 30)];
    [loveButton setTitle:@"我喜欢" forState:UIControlStateNormal];
    [loveButton.titleLabel setBackgroundColor:[UIColor clearColor]];
    loveButton.titleLabel.textColor = [UIColor whiteColor];
    
//    [loveButton setBackgroundColor:[UIColor blueColor]];
    [loveButton addTarget:self action:@selector(toHotPlacesView) forControlEvents:UIControlEventTouchDown];
    [self.view addSubview:loveButton];
    
}

- (void)viewDidUnload
{
    [super viewDidUnload]; 
}


#pragma mark -
#pragma mark - 页面跳转
-(void)toHotPlacesView
{
    SortRootViewController * sortRootViewController = [[SortRootViewController alloc] init];
    //参数传递
    sortRootViewController.optFlag    = 3;
    sortRootViewController.hotplaceDescription = mContentText.text;
    sortRootViewController.nowRegion = mNowRegion;
    sortRootViewController.regionLat = mRegionLat;
    sortRootViewController.regionLng = mRegionLng;
    sortRootViewController.regionProvince = mRegionProvince;
    sortRootViewController.isPushOrShow = 1;

    [self.navigationController pushViewController:sortRootViewController animated:YES];
    [sortRootViewController release];
}


#pragma mark -
#pragma mark - 辅助事件
/**通过输入导航条的DONE按钮关闭键盘**/
//- (void)textViewDidBeginEditing:(UITextView *)textView {   
//    self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc]
//                                               initWithTitle:@"Done" 
//                                               style:UIBarButtonItemStyleDone
//                                               target:self
//                                               action:@selector(leaveEditMode:)]
//                                              autorelease];     
//}   
//
//- (void)textViewDidEndEditing:(UITextView *)textView {   
//    self.navigationItem.rightBarButtonItem = nil;   
//}   
//
//- (void)leaveEditMode:(id) sender{   
//    [mContentText resignFirstResponder];  
//} 
/**关闭键盘方法**/
-(IBAction)closeKeyBoard  
{  
    [mContentText resignFirstResponder];  
}  

/**回退**/
-(void) back
{
    //后退到微博列表页显示
    [self.navigationController popViewControllerAnimated:YES];
}

@end
