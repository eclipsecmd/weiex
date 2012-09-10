//
//  DetailViewController.m
//  WeiTansuo
//
//  Created by chishaq on 11-8-15.
//  Copyright 2011年 Invidel. All rights reserved.
//




//
//  DetailViewController.m
//  WeiTansuo
//
//  Created by chishaq on 11-8-15.
//  Copyright 2011年 Invidel. All rights reserved.
//

#import "StatusImageDetailViewController.h"
#import "StatusRePostController.h"
#import "ProfileViewController.h"
#import "UIViewControllerCategory.h"
#import "StatusCommentViewController.h"


#define MAX_LONG_LONG_INT 9999999999999999
#define MAX_MIDDLEPIC_WIDTH  310
#define MAX_MIDDLEPIC_HEIGHT  3000
#define STATUSDATA_MAX_PAGE 8
#define STATUSDATA_PAGE_SIZE 25

#define KEY_USER_SCREEN_NAME    @"keyScreenName" //the User's Screen name of the Object of User
#define KEY_USER_NAME           @"keyUserName"  //the UserName of the Object of User
#define KEY_USER_IMG            @"keyUserImg"   //the small User Avatar of the Object of the User

@implementation StatusImageDetailViewController

@synthesize status = mStatus;
@synthesize oAuthEngine = mOAuthEngine;
@synthesize region = mRegion;
@synthesize goAnywhereButtonIsShow = mGoAnywhereButtonIsShow;
@synthesize finishAction,finishTarget;
@synthesize updateWeiboIndex = mUpdateWeiboIndex;

#pragma mark - 
#pragma mark - 构造与析构

- (id)init
{
    self = [super init];
    if (self) {
        mComments = [[NSMutableArray alloc] init];
        mQueryCondition = [[QueryCondition alloc] init];        
    }
    return self;
}


- (void)dealloc
{    
    [mCreateAtIcon release];
    [mCreateAtLabel release];
    [mRelationLocationIcon release];
    [mRelationLocationLabel release];
    [mVerifyinfo release];    
    [mUserNameLabel release];
    //[mSoftNoticeViewLoad release];
    [mLoadMoreAIView release];
    [mRefreshAIView release];
    [mCommentsTableView release];
    [mMapImageView release];
    [mMiddlePicView release];  
    [mDetailContent release];
    [mUserPicView release];
    [mQueryCondition release];
    [mComments release];
    [mOAuthEngine release];
    [mStatus release]; 
//    [mStarImageView release];
    [mStarView release];    
    [mGoAnywhereButton release];
    [mGoProfileView release];
    [mMapViewForStatusGeo release];
    [mMapViewCover release];
    [mLineImageView release];
    [mMiddlePicShadowView release];
    [mCommentCountLable release];
    [mCommentCountImage release];
    [mMapBackView release];
    [mStarTipImageView release];
    [mStarTipLabel release];
    [super dealloc];
}

#pragma mark - 
#pragma mark - 自定义初始化函数

/**初始化微博数据查询条件**/
- (void)initMQueryCondition
{
    mQueryCondition.startpage = 1;
    mQueryCondition.count = STATUSDATA_PAGE_SIZE;
}
/**初始化评论数据**/
- (void)initMCommentsData
{
    [mComments removeAllObjects];
    mCommentsCurrentStatueId = MAX_LONG_LONG_INT;
}
#pragma mark - 
#pragma mark - 视图

- (void) loadView
{
    [super loadView];
}

/**(此阶段隐藏工具条)**/
- (void)viewWillAppear:(BOOL)animated  
{  
    [super viewWillAppear:animated];  
    //设置导航条显示
    [mRefreshAIView removeFromSuperview]; 
    mUserNameLabel.textColor = [UIColor blackColor];
}

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
    detailLabel.text = @"查看详细";
    detailLabel.font = [UIFont fontWithName:@"TrebuchetMS-Bold" size:20];
    detailLabel.textColor = [UIColor whiteColor];
    [self.view addSubview:detailLabel];
    [detailLabel release];       
    //转发按钮
    UIButton * functionButton = [[UIButton alloc] initWithFrame:CGRectMake(270, 7, 40, 30)];
    [functionButton setImage:[UIImage imageNamed:@"title_icon_6_nor.png"] forState:UIControlStateNormal];
    [functionButton setImage:[UIImage imageNamed:@"title_icon_6_press.png"] forState:UIControlStateHighlighted];
    [functionButton addTarget:self action:@selector(toFunctionActionSheet) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:functionButton];
    [functionButton release];
    
    if (!mFunctionAction) {
        mFunctionAction = [[UIActionSheet alloc] initWithTitle:@"" 
                                                      delegate:self 
                                             cancelButtonTitle:@"关闭" 
                                        destructiveButtonTitle:nil 
                                             otherButtonTitles:@"刷新",@"评论", @"转发", nil];
    }
    
    if (!mMiddlePicView) {
        mMiddlePicView = [[UrlImageView alloc] init];
        if([mStatus.bmiddlePic length] > 5) {
//            mMiddlePicView.frame = CGRectMake(5, 5, 310, 200);
            mMiddlePicView.frame = CGRectMake(5, 10, 300, 200);
            mMiddlePicView.layer.masksToBounds = YES;
            mMiddlePicView.layer.cornerRadius = 5.0;
            mMiddlePicView.backgroundColor = [UIColor clearColor];
            mMiddlePicView.imageUrl = mStatus.bmiddlePic;
            mMiddlePicView.finishTarget = self;
            mMiddlePicView.finishAction = @selector(finishLoadImage);
            mIsLoadingImage = YES;              
            [mMiddlePicView getImageByUrl:3];
        }
        else {
            mMiddlePicView.frame = CGRectMake(0, mDetailContent.frame.origin.y + mDetailContent.frame.size.height + 5, 0, 0);
        }
    }
    //用户相对位置
    if (!mRelationLocationLabel) {
        mRelationLocationLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 15, 80, 30)];
        [mRelationLocationLabel setText:mStatus.relativeLocation];		
        [mRelationLocationLabel setBackgroundColor:[UIColor clearColor]];
        [mRelationLocationLabel setFont:[UIFont fontWithName:@"Arial" size:15]];
        [mRelationLocationLabel setTextColor:[UIColor whiteColor]];
        [mRelationLocationLabel sizeToFit]; 
    }  
    //用户相对位置图标
//    if (!mRelationLocationIcon) {
//        mRelationLocationIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"position15px.png"]];
//        [mRelationLocationIcon setFrame:CGRectMake(15, 15, 12, 12)];
//    }
    
    //评论列表
    if (!mCommentsTableView) {
        CGRect tableframe = self.view.frame;
        tableframe.size.height = 410.f;
        tableframe.size.width = 310.f;
        tableframe.origin.x = 5.f;
        tableframe.origin.y = 47.f;
        mCommentsTableView = [[UITableView alloc] initWithFrame:tableframe
                                                          style:UITableViewStylePlain];
        mCommentsTableView.delegate = self;
        mCommentsTableView.dataSource = self;
        [mCommentsTableView setBackgroundColor:[UIColor clearColor]];
        [mCommentsTableView setSeparatorColor:[UIColor clearColor]];
        [mCommentsTableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];


        [self.view addSubview:mCommentsTableView];
        //[self.view sendSubviewToBack:mCommentsTableView];
    }
    
    //刷新转子
    if (!mRefreshAIView) {
        mRefreshAIView = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(290, 13, 19, 19)];
        mRefreshAIView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhite;
    }
    //加载更多转子
    if (!mLoadMoreAIView) {
        mLoadMoreAIView = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(100, 10, 19, 19)];
        mLoadMoreAIView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray; 
    }
    //别针图标
    UIImageView * clipimage = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"Clip_img.png"]];
    clipimage.frame = CGRectMake(275, 37, 36, 36);
    [self.view addSubview:clipimage];    
    
    //加载框
    /*
     if (!mSoftNoticeViewLoad) {
     mSoftNoticeViewLoad = [[SoftNoticeView alloc] initWithFrame:CGRectMake(90, 170, 140, 140)];
     [mSoftNoticeViewLoad setMessage:@"数据获取中..."];
     [mSofNoticeViewLoad setActivityindicatorHidden:NO];
     [mSoftNoticeViewLoad setHidden:YES];
     [self.view addSubview:mSoftNoticeViewLoad];
     }
     */
    //[self drawLayout];
    //[self drawFrame];
    //--------------------开始获取数据-------------------------//
    [self refreshCommentData];
    
    
}

//this method must use after drawLayout used.
- (void) drawFrame
{
//    [mUserPicView setFrame:CGRectMake(3 + 2, mMiddlePicView.frame.size.height + mMiddlePicView.frame.origin.y + 15, 40.f, 40.f)];
//    [mGoProfileView setFrame:CGRectMake(5, mMiddlePicView.frame.size.height + mMiddlePicView.frame.origin.y + 15, 190, 83)];//***********
    //[mUserNameLabel setFrame:CGRectMake(5 + 40 + 6, mMiddlePicView.frame.size.height + mMiddlePicView.frame.origin.y + 3 + 3, 220.0f, 18.0f)];
//    [mVerifyinfo setFrame:CGRectMake(mUserNameLabel.frame.origin.x + mUserNameLabel.frame.size.width + 3, mUserNameLabel.frame.origin.y + 3, 15, 13)];
    //[mDetailContent setFrame:CGRectMake(5 + 40 + 6, mUserNameLabel.frame.size.height + mUserNameLabel.frame.origin.y + 3, 250, 0.f)];
    //+++++++++
//    [mCreateAtIcon setFrame:CGRectMake(310 - mCreateAtLabel.frame.size.width - 3 - 12, mDetailContent.frame.size.height + mDetailContent.frame.origin.y + 3, 12, 12)];
//    CGRect createAtLabelReLayoutRect = mCreateAtLabel.frame;
//    createAtLabelReLayoutRect.origin.x = 310 - createAtLabelReLayoutRect.size.width;
//    [mCreateAtLabel setFrame:createAtLabelReLayoutRect];
//    [mRelationLocationLabel setFrame:CGRectMake(10 + 12 + 3, mDetailContent.frame.size.height + mDetailContent.frame.origin.y + 3, 0, 0)];
//    [mRelationLocationIcon setFrame:CGRectMake(10, mDetailContent.frame.size.height + mDetailContent.frame.origin.y + 3, 12, 12)];
//    //++++++++++
//    [mMapViewForStatusGeo setFrame:CGRectMake(5, mCreateAtIcon.frame.origin.y + mCreateAtIcon.frame.size.height + 7, 310, 90)];
//    
//    [mGoAnywhereButton setFrame:CGRectMake(5, mMapViewForStatusGeo.frame.origin.y + mMapViewForStatusGeo.frame.size.height + 5, 310, 20)];    
    
    [mStarImageButton setFrame: CGRectMake(15.f, mMiddlePicView.frame.size.height + mMiddlePicView.frame.origin.y -40.f, 57.f, 30.f)];
    [mStarView setFrame:CGRectMake(40.0f, mMiddlePicView.frame.size.height + mMiddlePicView.frame.origin.y -37.f, 30,15)];
    [mMiddlePicShadowView setFrame:CGRectMake(8, mMiddlePicView.frame.size.height + mMiddlePicView.frame.origin.y - 12, 295, 20)]; 
    [mUserPicView setFrame:CGRectMake(3 + 2, mMiddlePicView.frame.size.height + mMiddlePicView.frame.origin.y + 15+5, 40.f, 40.f)];
    [mGoProfileView setFrame:CGRectMake(5, mMiddlePicView.frame.size.height + mMiddlePicView.frame.origin.y + 15+5, 190, 83)];    
    [mUserNameLabel setFrame:CGRectMake(5 + 40 + 6, mMiddlePicView.frame.size.height + mMiddlePicView.frame.origin.y + 13 + 10+5, 100, 20)];    
    [mVerifyinfo setFrame:CGRectMake(mUserNameLabel.frame.origin.x + mUserNameLabel.frame.size.width + 3, mUserNameLabel.frame.origin.y + 3+5, 15, 13)];  
    [mCreateAtLabel setFrame:CGRectMake(310 -10 -50-10, mMiddlePicView.frame.size.height + mMiddlePicView.frame.origin.y + 13 + 10+5, 60, 14)];    
    [mCommentCountLable setFrame:CGRectMake(310 -10 -50-10-20-5,  mMiddlePicView.frame.size.height + mMiddlePicView.frame.origin.y + 13 + 10+3, 20.f, 18.f)];
    [mCommentCountImage setFrame:CGRectMake(310 -10 -60-10-20-10-10,  mMiddlePicView.frame.size.height + mMiddlePicView.frame.origin.y + 13 + 8+3, 22.f, 22.f)];
    
    [mLineImageView setFrame:CGRectMake(5, mUserPicView.frame.size.height + mUserPicView.frame.origin.y + 10+10, 300, 1)];
    [mMapBackView setFrame:CGRectMake(3 + 2, mUserPicView.frame.origin.y + mUserPicView.frame.size.height + 20+10, 106.f, 106.f)];    
    [mMapViewForStatusGeo setFrame:CGRectMake(8, mUserPicView.frame.origin.y + mUserPicView.frame.size.height + 20+3+10, 100, 100)];
    [mGoAnywhereButton setFrame:CGRectMake(8, mUserPicView.frame.origin.y + mUserPicView.frame.size.height + 3+10, 100, 100)];
    [mDetailContent setFrame:CGRectMake(5 + 106 + 6, mUserPicView.frame.size.height + mUserPicView.frame.origin.y +20+10, 190, 0.f)];
    mDetailContent.text = mStatus.text;
    CGSize contentSize = [mDetailContent.text sizeWithFont:[UIFont fontWithName:@"Arial" size:14] 
                                         constrainedToSize:CGSizeMake(180, 500)  
                                             lineBreakMode:UILineBreakModeWordWrap];
    CGRect contentFrame = mDetailContent.frame;
    [mDetailContent setFrame:CGRectMake(contentFrame.origin.x, contentFrame.origin.y, 
                                        contentSize.width, contentSize.height)];


}


- (void)drawLayout
{
    //用户方位
//    if (!mRelationLocationIcon) {
//        mRelationLocationIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"position15px.png"]];
//        [mRelationLocationIcon setFrame:CGRectMake(5, mMapImageView.frame.size.height + mMapImageView.frame.origin.y + 5, 12, 12)];
//    } 
    if (!mRelationLocationLabel) {
        mRelationLocationLabel = [[UILabel alloc] initWithFrame:CGRectMake(mRelationLocationIcon.frame.origin.x + 3, 5, 0, 0)];
        [mRelationLocationLabel setText:mStatus.relativeLocation];		
        [mRelationLocationLabel setBackgroundColor:[UIColor clearColor]];
        [mRelationLocationLabel setFont:[UIFont fontWithName:@"Arial" size:12]];
        [mRelationLocationLabel setTextColor:[UIColor grayColor]];
        [mRelationLocationLabel sizeToFit]; 
    }
    //微博加星
    if(!mStarImageButton){
        
        mStarImageButton = [[UIButton alloc] initWithFrame:CGRectMake(15.f, mMiddlePicView.frame.size.height + mMiddlePicView.frame.origin.y -40.f, 57.f, 30.f)];
        [mStarImageButton setImage:[UIImage imageNamed:@"切图_116.png"] forState:UIControlStateNormal];
        [mStarImageButton setImage:[UIImage imageNamed:@"切图_115.png"] forState:UIControlStateHighlighted];
        mStarImageButton.backgroundColor = [UIColor clearColor];
        [mStarImageButton addTarget:self action:@selector(weiboAddStarOpt:) forControlEvents:UIControlEventTouchUpInside]; 
        [self.view addSubview:mStarImageButton];
    }
    
    if(!mStarView){
        mStarView = [[UILabel alloc] initWithFrame:CGRectMake(40.0f, mMiddlePicView.frame.size.height + mMiddlePicView.frame.origin.y -37.f, 0, 0)];
        mStarView.font = [UIFont fontWithName:@"TrebuchetMS-Bold" size:15];
        mStarView.textColor = [UIColor whiteColor]; 
        mStarView.backgroundColor = [UIColor clearColor];
        mStarAmount = mStatus.starAmount;
        mStarView.text = [[NSString alloc] initWithFormat:@" %lld",mStarAmount];
        [mStarView sizeToFit];
    }    
    //用户图片阴影
    if (!mMiddlePicShadowView) {
        mMiddlePicShadowView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"photo_img_bg.png"]];
        [mMiddlePicShadowView setFrame:CGRectMake(8, mMiddlePicView.frame.size.height + mMiddlePicView.frame.origin.y - 12, 295, 20)];      
    }     
    //用户头像  
    if (!mUserPicView) {
        mUserPicView = [[UrlImageView alloc] initWithFrame:CGRectMake(3 + 2, mMiddlePicView.frame.size.height + mMiddlePicView.frame.origin.y + 15+5, 40.f, 40.f)];    
        if([mStatus.user.profileImageUrl length] > 5) {
            mUserPicView.imageUrl = mStatus.user.profileImageUrl;
            mUserPicView.layer.masksToBounds = YES;
            mUserPicView.layer.cornerRadius = 5.0;
            [mUserPicView getImageByUrl:1];
        }
        else {
            UIImage * userPic = [[UIImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"viewfile" ofType:@"png"]];
            mUserPicView.image = userPic;
            mUserPicView.layer.masksToBounds = YES;
            mUserPicView.layer.cornerRadius = 5.0;
            [userPic release];
        }     
    }   
    
    //UIImageView *testImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"viewfile.png"]];
    
    //个人详细页点击事件
    if (!mGoProfileView) {
        mGoProfileView = [[UIButton alloc] init];
        [mGoProfileView setFrame:CGRectMake(5, mMiddlePicView.frame.size.height + mMiddlePicView.frame.origin.y + 15+5, 190, 83)];
        [mGoProfileView addTarget:self action:(@selector(toUserProfile:)) forControlEvents:UIControlEventTouchUpInside];
    }
    
    //用户名
    if (!mUserNameLabel) {
        mUserNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(5 + 40 + 6, mMiddlePicView.frame.size.height + mMiddlePicView.frame.origin.y + 13 + 10+5, 100, 55)];
        mUserNameLabel.text = mStatus.user.name;
        mUserNameLabel.backgroundColor = [UIColor clearColor];
        mUserNameLabel.font = [UIFont fontWithName:@"TrebuchetMS-Bold" size:16];
        [mUserNameLabel sizeToFit];
    }
    
    //用户认证
    if (!mVerifyinfo) {
        mVerifyinfo = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"v.png"]];
        [mVerifyinfo setFrame:CGRectMake(mUserNameLabel.frame.origin.x + mUserNameLabel.frame.size.width + 3, mUserNameLabel.frame.origin.y + 3+5, 15, 13)];
        //remrember. add this view to the cell of the tableview cell.
    }
    //微博创建日期
    if (!mCreateAtLabel) {
        mCreateAtLabel = [[UILabel alloc] initWithFrame:CGRectMake(310 -10 -50-10, mMiddlePicView.frame.size.height + mMiddlePicView.frame.origin.y + 13 + 10+5, 0, 0)];
        [mCreateAtLabel setText:mStatus.timestamp];
        [mCreateAtLabel setBackgroundColor:[UIColor clearColor]];
        [mCreateAtLabel setFont:[UIFont fontWithName:@"Arial" size:14]];
        [mCreateAtLabel setTextColor:[UIColor grayColor]];
        [mCreateAtLabel sizeToFit];  
    }
    
//    //微博创建图标
//    if (!mCreateAtIcon) {
//        mCreateAtIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"clock15px.png"]];
//        [mCreateAtIcon setFrame:CGRectMake(310 -10 - mCreateAtLabel.frame.size.width - 12, mMiddlePicView.frame.size.height + mMiddlePicView.frame.origin.y + 13 + 10, 12, 12)];
//        //reset the location of the Label
//        CGRect createAtLabelReLayoutRect = mCreateAtLabel.frame;
//        createAtLabelReLayoutRect.origin.x = 310 - createAtLabelReLayoutRect.size.width;
//        [mCreateAtLabel setFrame:createAtLabelReLayoutRect];
//        
//    } 
    //评论数 
    if (!mCommentCountLable) {   
        mCommentCountLable = [[UILabel alloc] initWithFrame:CGRectMake(310 -10 -50-10-20-5,  mMiddlePicView.frame.size.height + mMiddlePicView.frame.origin.y + 13 + 10+5, 20.f, 18.f)];
        mCommentCountLable.font = [UIFont fontWithName:@"Arial" size:14];
        [mCommentCountLable setTextColor:[UIColor grayColor]];
        mCommentCountLable.backgroundColor = [UIColor clearColor];
        mCommentCountLable.text = [[[NSString alloc] initWithFormat:@"%d",mCommentsCount] autorelease]; 
    }
    if (!mCommentCountImage) {
        mCommentCountImage =[[UIImageView alloc] initWithFrame:CGRectMake(310 -10 -60-10-20-10-10,  mMiddlePicView.frame.size.height + mMiddlePicView.frame.origin.y + 13 + 8+5, 22.f, 22.f)];
        mCommentCountImage.image = [UIImage imageNamed:@"greyheart.png"];
    }

    //微博分割线图片
    if (!mLineImageView) {
        mLineImageView = [[UIImageView alloc] initWithFrame:CGRectMake(5, mUserPicView.frame.size.height + mUserPicView.frame.origin.y + 10+10, 300, 1)];
        mLineImageView.backgroundColor = [UIColor grayColor];
        mLineImageView.alpha = 0.7;
    }
    if(!mMapBackView){
        mMapBackView = [[UrlImageView alloc] initWithFrame:CGRectMake(3 + 2, mUserPicView.frame.origin.y + mUserPicView.frame.size.height + 20+10, 106.f, 106.f)];    
        mMapBackView.layer.masksToBounds = YES;
        mMapBackView.layer.cornerRadius = 5.0;
        mMapBackView.image = [UIImage imageNamed:@"map_bg.png"];
        mMapBackView.layer.borderColor = [[UIColor blackColor] CGColor];
    }
    
    //地图信息
    if (!mMapViewForStatusGeo) {        
        if (mStatus.latitude > 0 && mStatus.longitude > 0) {
            mMapViewForStatusGeo = [[MKMapView alloc] initWithFrame:CGRectMake(8, mUserPicView.frame.origin.y + mUserPicView.frame.size.height + 20+3+10, 100, 100)];
            mMapViewForStatusGeo.delegate = self;
            mMapViewForStatusGeo.showsUserLocation = YES;
            mMapViewForStatusGeo.zoomEnabled = YES;   
            mMapViewForStatusGeo.layer.masksToBounds = YES;
            mMapViewForStatusGeo.layer.cornerRadius = 5.0;
            
            if (!mMapViewCover) {
                mMapViewCover = [[UIButton alloc] init];
                [mMapViewCover setFrame:mMapViewForStatusGeo.frame];
                [mMapViewCover addTarget:self action:(@selector(toStatusLocationView)) forControlEvents:UIControlEventTouchUpInside];
                [mMapViewCover setBackgroundColor:[UIColor clearColor]];
                //[mMapViewForStatusGeo insertSubview:mMapViewCover atIndex:0];
            }
            
            /*
             MKCoordinateRegion neightbor;
             neightbor.center.latitude = mStatus.latitude;
             neightbor.center.longitude = mStatus.longitude;
             neightbor.span.latitudeDelta = mStatus.relativeDistance/5000;//[DataController getDefaultLatitudeDelta];
             neightbor.span.longitudeDelta = mStatus.relativeDistance/5000;//[DataController getDefaultLongitudeDelta];    
             
             [mMapViewForStatusGeo setRegion:neightbor animated:YES];
             */
            
            CLLocationCoordinate2D centerCoord = {mStatus.latitude, mStatus.longitude};
            
            [mMapViewForStatusGeo setCenterCoordinate:centerCoord zoomLevel:13 animated:YES];
            
            /*
             WildcardGestureRecognizer * tapInterceptor = [[WildcardGestureRecognizer alloc] init];
             tapInterceptor.touchesBeganCallback = ^(NSSet * touches, UIEvent * event) {
             [self performSelector:(@selector(toStatusLocationView))]; 
             };
             [mMapViewForStatusGeo addGestureRecognizer:tapInterceptor];
             */
            
            //take me go there.this is amazing button for you who want to ex the city or something new.
            if (!mGoAnywhereButton) {
                mGoAnywhereButton = [[UIButton alloc] init];
                [mGoAnywhereButton setFrame:CGRectMake(8, mUserPicView.frame.origin.y + mUserPicView.frame.size.height + 3+10, 100, 100)];
                [mGoAnywhereButton setTitle:@"带我去这里" forState:UIControlStateNormal];
                [mGoAnywhereButton setBackgroundColor:[UIColor colorWithRed:220/255.f green:220/255.f blue:220/255.f alpha:1]];
                mGoAnywhereButton.layer.cornerRadius = 3.f;
                [mGoAnywhereButton addTarget:self action:(@selector(takeMeToAnyWhereMethod)) forControlEvents:UIControlEventTouchUpInside];
            }            
        }   
        else {            
            mMapViewForStatusGeo = [[MKMapView alloc] initWithFrame:CGRectMake(10.f, mMiddlePicView.frame.origin.y + mMiddlePicView.frame.size.height, 0, 5.f)];          
        }               
    }   
    //详细内容
    if (!mDetailContent) {
        mDetailContent = [[UILabel alloc] initWithFrame:CGRectMake(5 + 106 + 6, mUserPicView.frame.size.height + mUserPicView.frame.origin.y +20+10, 190, 0.f)];
        mDetailContent.text = mStatus.text;
        mDetailContent.backgroundColor = [UIColor clearColor];
        mDetailContent.numberOfLines = 0;
        mDetailContent.lineBreakMode = UILineBreakModeWordWrap;
        mDetailContent.font = [UIFont fontWithName:@"Arial" size:14];
        CGSize contentSize = [mDetailContent.text sizeWithFont:[UIFont fontWithName:@"Arial" size:14] 
                                             constrainedToSize:CGSizeMake(180, 500)  
                                                 lineBreakMode:UILineBreakModeWordWrap];
        CGRect contentFrame = mDetailContent.frame;
        [mDetailContent setFrame:CGRectMake(contentFrame.origin.x, contentFrame.origin.y, 
                                            contentSize.width, contentSize.height)];
    } 
 
//    if (!mRelationLocationLabel) {
//        mRelationLocationLabel = [[UILabel alloc] initWithFrame:CGRectMake(10 + 12 + 3, mDetailContent.frame.size.height + mDetailContent.frame.origin.y + 3, 0, 0)];
//        [mRelationLocationLabel setText:mStatus.relativeLocation];		
//        [mRelationLocationLabel setBackgroundColor:[UIColor clearColor]];
//        [mRelationLocationLabel setFont:[UIFont fontWithName:@"Arial" size:12]];
//        [mRelationLocationLabel setTextColor:[UIColor grayColor]];
//        [mRelationLocationLabel sizeToFit]; 
//    }    
//    if (!mRelationLocationIcon) {
//        mRelationLocationIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"position15px.png"]];
//        [mRelationLocationIcon setFrame:CGRectMake(10, mDetailContent.frame.size.height + mDetailContent.frame.origin.y + 3, 12, 12)];
//    }
 
        
//    [self resetTableViewHeight];
}

//reset the tableview hegith
- (void)resetTableViewHeight
{
    CGRect tableframe = self.view.frame;
    tableframe.size.height = 410.f;
    tableframe.size.width = 310.f;
    tableframe.origin.x = 5.f;
    tableframe.origin.y = 47.f;
    mCommentsTableView.frame = tableframe;
}


- (void)viewDidUnload
{
    [super viewDidUnload];   
    mCreateAtIcon = nil;
    [mCreateAtIcon release];
    mCreateAtLabel = nil;
    [mCreateAtLabel release];
    mRelationLocationIcon = nil;
    [mRelationLocationIcon release];
    mRelationLocationLabel = nil;
    [mRelationLocationLabel release];
    mVerifyinfo = nil;
    [mVerifyinfo release];
    mUserPicView = nil;
    [mUserPicView release];
    mDetailContent = nil;
    [mDetailContent release];
    mMiddlePicView = nil;
    [mMiddlePicView release];
    mMapImageView = nil;
    [mMapImageView release];
    mCommentsTableView = nil;
    [mCommentsTableView release];
    mLoadMoreAIView = nil;
    [mLoadMoreAIView release];
    mRefreshAIView = nil;
    [mRefreshAIView release];
    mUserNameLabel = nil;
    [mUserNameLabel release];
//    mStarImageView = nil;
//    [mStarImageView release];
    mStarView = nil;
    [mStarView release];   
    mGoProfileView = nil;
    [mGoProfileView release];
    mGoAnywhereButton = nil;
    [mGoAnywhereButton release];
    mMapViewCover = nil;
    [mMapViewCover release];
    mMapViewForStatusGeo = nil;
    [mMapViewForStatusGeo release];
    mMiddlePicShadowView = nil;
    [mMiddlePicShadowView release];
    mCommentCountLable = nil;
    [mCommentCountLable release];
    mCommentCountImage = nil;
    [mCommentCountImage release];
    mMapBackView = nil;
    [mMapBackView release];
    mStarTipImageView = nil;
    [mStarTipImageView release];
    mStarTipLabel = nil;
    [mStarTipLabel release];
}


#pragma mark -
#pragma mark - 开始获取微博评论数据
/**开始获取评论总数**/
- (void)loadCommentsCountBegin
{
    mWeiboClient = [[WeiboClient alloc] initWithTarget:self 
                                                engine:mOAuthEngine
                                                action:@selector(loadCommentsCountFinished:obj:)]; 
    NSNumber * statusId = [[NSNumber alloc] initWithLongLong: mStatus.statusId];
    NSMutableArray * statusIds = [[NSMutableArray alloc] initWithObjects:statusId, nil];
    [statusId release];
    [mWeiboClient getCommentCounts:statusIds];
    [statusIds release];
}
/**获取评论总数结束**/
- (void)loadCommentsCountFinished:(WeiboClient *)sender
                              obj:(NSObject*)obj
{
    if (sender.hasError) {
        [self endLoadData];
        [self alert:@"评论数获取失败"];
    } 
    else {
        NSArray * ary = (NSArray *)obj;
        if (!ary) {
            mCommentsCount = 0;
        }
        else {
            if ([ary count]==0) {
                mCommentsCount = 0;
            }
            else {
                mCommentsCount = [(NSDictionary *)[ary objectAtIndex:0] getIntValueForKey:@"comments" defaultValue:0];
            }
        }
        if (mCommentsCount > 0) {
            mStatus.commentsCount = mCommentsCount;
            [self loadCommentsBegin];
        } else {
            [self endLoadData];
        } 
    }
}
/**开始获取评论数据**/
- (void)loadCommentsBegin
{
    //微博接口
    mWeiboClient = [[WeiboClient alloc] initWithTarget:self 
                                                engine:mOAuthEngine
                                                action:@selector(loadCommentsFinished:obj:)]; 
    
    [mWeiboClient getComments:mStatus.statusId 
               startingAtPage:mQueryCondition.startpage
                        count:mQueryCondition.count];
}
/**评论数据获取结束，数据存入内存，准备展示数据(代理)**/
- (void)loadCommentsFinished:(WeiboClient *)sender
                         obj:(NSObject*)obj
{
    if (sender.hasError) {
        [self endLoadData];
		[self alert:@"评论获取失败"];
    } else {
        //存储微博数据
        mCommentsCuttrntPageDataCount = 0;
        NSArray * ary = (NSArray *)obj ;
        for (NSDictionary * dic in ary) {
            if (![dic isKindOfClass:[NSDictionary class]]) {
                continue;
            } 
            Status* sts = [Status statusWithJsonDictionary:dic MyRegion:[DataController getDefaultRegion]];
            if (sts.statusId >= mCommentsCurrentStatueId) {
                continue;
            }
            [mComments addObject:sts];
            mCommentsCuttrntPageDataCount ++ ;
            mCommentsCurrentStatueId = sts.statusId; 
        } 
        [self endLoadData];
    }
    
}

/**刷新评论**/
- (BOOL)beforeRefreshCommentData       //返回是否可以刷新
{
    if (mIsLoadingComment) {
        return NO;
    }
    mIsLoadingComment = YES;
    mLoadingCommentDataType = 1;
    //[mSoftNoticeViewLoad setHidden:NO];
    //[mSoftNoticeViewLoad start];
    //[mCommentRefreshImageView removeFromSuperview];
    //[self.navigationController.navigationBar addSubview:mRefreshAIView];
    //[mRefreshAIView startAnimating];
    return YES;
}
-(void)endRefreshCommentData
{
    [mRefreshAIView stopAnimating];
    [mRefreshAIView removeFromSuperview];
    //[mSoftNoticeViewLoad start];
    //    [mSoftNoticeViewLoad setHidden:YES];
    //UIBarButtonItem * refreshButtonItem = [[UIBarButtonItem alloc] initWithCustomView:mCommentRefreshImageView];
    //self.navigationItem.rightBarButtonItem = refreshButtonItem;
    //[refreshButtonItem release];
    [self tableViewBegin];
    [self resetTableViewHeight];
    mLoadingCommentDataType = 0;
    mIsLoadingComment = NO;
}
-(void)refreshCommentData
{
    if (![self beforeRefreshCommentData])  return;
    [self initMQueryCondition];
    [self initMCommentsData];
    [self loadCommentsCountBegin]; 
}
/**加载更多评论**/
- (BOOL)beforeLoadMoreCommentData
{
    if (mIsLoadingComment) {
        return NO;
    }
    mIsLoadingComment = YES;
    mLoadingCommentDataType = 2;
    [mLoadMoreAIView startAnimating];
    return YES;
}
- (void)endLoadMoreCommentData
{
    [mLoadMoreAIView stopAnimating];
    [self tableViewBegin];
    mIsLoadingComment = NO;
    mLoadingCommentDataType = 0;
}
- (void)loadMoreCommentData
{
    if (![self beforeLoadMoreCommentData])  return;
    mQueryCondition.startpage++;
    [self loadCommentsCountBegin];
}
/**辅助**/
- (void)endLoadData
{
    if (mCommentsCount == 0) {
        [mCommentsTableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    }
    else {
        [mCommentsTableView setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
    }
    if (mLoadingCommentDataType == 1) {
        [self endRefreshCommentData];
    } else if(mLoadingCommentDataType == 2) {
        [self endLoadMoreCommentData];
    }
    [self resetTableViewHeight];
}
#pragma mark -
#pragma mark - 展示数据 之 [列表展示]
/**列表开始展示**/
- (void) tableViewBegin
{
    [mCommentsTableView reloadData];
}
/**生成列表表格 Height**/
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{  
    CGFloat height = 0.f;
    if (indexPath.row == 0) {
        height += mMiddlePicView.frame.origin.y;        
        height += mMiddlePicView.frame.size.height;
        height += mUserPicView.frame.size.height;
//        height += mUserNameLabel.frame.size.height;
        height += mDetailContent.frame.size.height;
//        height += mCreateAtLabel.frame.size.height;
        height += mMapViewForStatusGeo.frame.size.height;
//        height += mRelationLocationLabel.frame.size.height;
//        height += mGoAnywhereButton.frame.size.height;
        height += 25;
        if ([mComments count] == 0) {
            height += 20;
        }
        
    }
    // this is for comment cell
    else if(indexPath.row >= 1 && indexPath.row < [mComments count] + 1) {
        StatusItemCell * cell = (StatusItemCell *)[self tableView:tableView cellForRowAtIndexPath:indexPath];
        height = [cell getCellHeight];        
    }
    // this is for Icon of comment and (Numbers).
//    else if(indexPath.row == 1){
//        height = 40.f;
//    }
    //any condition.
    else {
        height = 40.f;
    }
    return height;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    int count = [mComments count];
    if (count == 0) {
        return 1;
    }
    else if (count<=mCommentsCount)
    {
        if (mCommentsCount > count && mQueryCondition.startpage <= STATUSDATA_MAX_PAGE && mCommentsCuttrntPageDataCount > 0) {
            return count + 2;
        }
        else {
            return count + 1;
        } 
    }
    else
    {
        return 1;
    }
}

/**生成列表表格**/
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (indexPath.row == 0) {           //当前微博内容
        UITableViewCell * cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"cell_status"];
        if (cell == nil){
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                           reuseIdentifier:@"cell_status"] autorelease];
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        [self drawLayout];
        [cell addSubview:mMiddlePicShadowView];
        [cell addSubview:mMiddlePicView];
//        [cell addSubview:mRelationLocationIcon];
        [cell addSubview:mRelationLocationLabel];
//        [cell addSubview:mStarImageView]; 
        [cell addSubview:mStarImageButton];
        [cell addSubview:mStarView];  
        [cell addSubview:mUserPicView];
        [cell addSubview:mGoProfileView];
        [cell addSubview:mUserNameLabel];
//        [cell addSubview:mCreateAtIcon];
        [cell addSubview:mCreateAtLabel];  
        [cell addSubview:mCommentCountLable];
        [cell addSubview:mCommentCountImage]; 
        [cell addSubview:mLineImageView];
        [cell addSubview:mMapBackView];
        [cell addSubview:mMapImageView];
        [cell addSubview:mMapViewForStatusGeo];
        [cell addSubview:mMapViewCover];
        [cell addSubview:mDetailContent];
        //[cell insertSubview:mMapViewCover atIndex:1];
        //layout the element
        mCommentCountLable.text = [[[NSString alloc] initWithFormat:@"%d",mCommentsCount] autorelease]; 
        //[self drawFrame];
        //this if just get the resource of Feed or Normal Page.
        if (mGoAnywhereButtonIsShow) {
            [cell addSubview:mGoAnywhereButton];
        }        
        if (mStatus.user.verified) {
            [cell addSubview:mVerifyinfo];
        }
        if (mStatus.longitude > 0 && mStatus.latitude > 0) {
            if ([DataController getDefaultLongitude] > 0 && [DataController getDefaultLatitude] > 0) {
                [cell addSubview:mRelationLocationIcon];
                [cell addSubview:mRelationLocationLabel];
            }            
            
        }
        [cell sizeToFit];      
        return cell;
        
    }
//    else if(indexPath.row == 1) {       //评论标题
//        UITableViewCell * cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"cell_title"];
//        if (cell == nil){
//            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1
//                                           reuseIdentifier:@"cell_title"] autorelease];
//        }
//        cell.selectionStyle = UITableViewCellSelectionStyleNone;
//        
//        UIImageView * commentImage =[[UIImageView alloc] initWithFrame:CGRectMake(10.f, 10.f, 22.f, 20.f)];
//        commentImage.image = [UIImage imageNamed:@"comments.png"];
//        [cell addSubview:commentImage];
//        [commentImage release];
//        
//        UILabel *commentCount = [[UILabel alloc] initWithFrame:CGRectMake(35.f, 10.f, 200.f, 18.f)];
//        commentCount.font = [UIFont fontWithName:@"Arial" size:16];
//        commentCount.text = [[[NSString alloc] initWithFormat:@"(%d)",mCommentsCount] autorelease]; 
//        [cell addSubview:commentCount];
//        [commentCount release];
//        return cell;
//    }
    else if (indexPath.row >= 1 && indexPath.row < [mComments count]+1) {                             //评论
        StatusItemCell *cell = (StatusItemCell *)[tableView dequeueReusableCellWithIdentifier:@"cell_comments"];
        if (cell == nil) {
            cell = [[[StatusItemCell alloc] initWithStyle:UITableViewCellStyleDefault
                                          reuseIdentifier:@"cell_comments"] autorelease];
        }
        cell.userInteractionEnabled = NO;
        Status * comment = [mComments objectAtIndex:indexPath.row-1];    
        cell.userName.text= comment.user.screenName;                         //用户名
        cell.cellContentView.text = comment.text;                            //内容
        cell.timeLabel.text = comment.timestamp;                             //发表时间 
        cell.userPicView.imageUrl = comment.user.profileImageUrl;            //用户头像
        [cell.userPicView getImageByUrl:1]; 
        [cell sizeToFit];
        return cell;
    }
    else if (indexPath.row == [mComments count]+1) {
        UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"cell_comments_more"];
        if (cell == nil) {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                           reuseIdentifier:@"cell_comments_more"] autorelease];
        }
        cell.userInteractionEnabled = NO;
        
        cell.textLabel.textAlignment =UITextAlignmentCenter;
        cell.textLabel.font = [UIFont fontWithName:@"Arial" size:16];
        cell.textLabel.textColor = [UIColor grayColor];
        cell.textLabel.text = @"加载中";
        [cell addSubview:mLoadMoreAIView];
        //[self loadMoreCommentData];
        
        return cell;
    }
    else {
        UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"cell_comments_other"];
        if (cell == nil) {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                           reuseIdentifier:@"cell_comments_other"] autorelease];
        }
        cell.userInteractionEnabled = NO;
        return cell;
    }
    
}

#pragma mark - 
#pragma mark - 事件处理(大图下载、回调回退、跳转)

//this method function as title,this button on the bottom of the MapView.just Take me to the country road...Ono Lisa....
- (void) takeMeToAnyWhereMethod
{
    MKCoordinateRegion reg = MKCoordinateRegionMake(CLLocationCoordinate2DMake(mStatus.latitude, mStatus.longitude), 
                                                        MKCoordinateSpanMake(                                                                                                                                    [DataController getDefaultLatitudeDelta], [DataController getDefaultLongitudeDelta])
                                                        );
    
    [DataController setDefaultRegion:reg];
    [DataController setDefaultLatitude:mStatus.latitude];
    [DataController setDefaultLongitude:mStatus.longitude];
    //[DataController setMinLocationDescription:[[NSString alloc] initWithFormat:@"%@",hotPlace.title]];
    //[DataController setLocationDescription:[[NSString alloc] initWithFormat:@"这里是：%@",hotPlace.title]];
    [DataController setShenbianVCNeedRefreash:YES];
    [self back];
    //[self.tabBarController setSelectedIndex:0];
}


/**图片下载成功后的回调**/
-(void) finishLoadImage
{
    //重新调整图片的缩放比例
    //CGRect frame = mMiddlePicView.frame;
    CGFloat frameWidth = 300.f; 
    CGFloat realWidth = mMiddlePicView.image.size.width;
    CGFloat realHeight = mMiddlePicView.image.size.height;
    CGFloat frameHeight= frameWidth * realHeight/realWidth;
    if (frameHeight > MAX_MIDDLEPIC_HEIGHT) {
        frameHeight = MAX_MIDDLEPIC_HEIGHT;
    }
    [mMiddlePicView setFrame:CGRectMake(5, 5, frameWidth, frameHeight)];
    //relayout once more.-    
    [self drawFrame];
    [self tableViewBegin];
    
    mIsLoadingImage = NO;
}
/**查看地图详细**/
-(void)toStatusLocationView
{
    StatusLocationViewController * statusLocationViewController = [[StatusLocationViewController alloc] init];
    MKCoordinateRegion neightbor;
    neightbor.center.latitude = mStatus.latitude;
    neightbor.center.longitude = mStatus.longitude;
    neightbor.span.latitudeDelta = [DataController getDefaultLatitudeDelta];
    neightbor.span.longitudeDelta = [DataController getDefaultLongitudeDelta];
    statusLocationViewController.region = neightbor;
    [self.navigationController pushViewController:statusLocationViewController animated:YES];
    [statusLocationViewController release];
}
/**回退**/
-(void) back
{
    NSString * flagstr = @"no";
    if (mIsAlert) {
        return;
    }
    if (mIsLoadingComment) {
        [mWeiboClient cancel];
        [self endLoadData];
    }
    if (mIsLoadingImage) {
        [mMiddlePicView cancelCurrentImageLoad];
    }
    if (mIsUpdateStatusAfterStar) {
        mIsUpdateStatusAfterStar = NO;
        flagstr = @"yes";
    }

    //后退到微博列表页显示
    [self.navigationController popViewControllerAnimated:YES];
    NSArray * passArray = [[NSArray alloc] initWithObjects:flagstr ,[NSString stringWithFormat:@"%d",mUpdateWeiboIndex], nil];
    if ([finishTarget retainCount] > 0 && [finishTarget respondsToSelector:finishAction]) {
        [finishTarget performSelector:finishAction  withObject:passArray];
    }
}


/**跳转到转发**/
-(void) toRePost:(id)sender
{
    StatusRePostController * controller = [[StatusRePostController alloc] init];
    controller.status = mStatus;
    controller.oAuthEngine = mOAuthEngine;
    controller.finishTarget = self;
    controller.finishAction = @selector(refreshCommentData);
    [self.navigationController pushViewController:controller animated:YES];
    [controller release];
}
/**跳转到评论**/
-(void) toComment:(id)sender
{
    StatusCommentViewController * controller = [[StatusCommentViewController alloc] init];
    controller.status = mStatus;
    controller.oAuthEngine = mOAuthEngine;
    controller.finishTarget = self;
    controller.finishAction = @selector(refreshCommentData);
    [self.navigationController pushViewController:controller animated:YES];
    [controller release];
}
/**跳转到用户主页**/
-(void)toUserProfile:(id)sender
{
    mUserNameLabel.textColor = [UIColor blueColor];
    ProfileViewController * mProfile = [[ProfileViewController alloc] init];
    mProfile.user = mStatus.user;
    mProfile.oauth = mOAuthEngine;
    [self.navigationController pushViewController:mProfile animated:YES];
    [mProfile release];
    
    //保存点击事件 add by max
    [self saveWbUserClick:mStatus.user.userId
             onlineuserid:(long)mOAuthEngine.username
           onlineusername:[DataController getUserScreenName]
          onlineuserimage:((User *)[DataController getUser]).profileImageUrl        
              nowlatitude:[DataController getDefaultLatitude]
              nowlongtude:[DataController getDefaultLongitude]
               nowaddress:[[NSString alloc] initWithFormat:@"%@",[DataController getMinLocationDescription]]];
}

#pragma mark - 
#pragma mark - 辅助功能函数

/**提示框**/
- (void)alert:(NSString *)message
{
    mIsAlert = YES;
    SoftNoticeView * msgBox = [[SoftNoticeView alloc] initWithFrame:CGRectMake(90, 170, 140, 140)];
    [msgBox setMessage:message];
    [msgBox setActivityindicatorHidden:YES];
    [self.view addSubview:msgBox];
    [msgBox start];
    [self performSelector:@selector(closeAlert:) withObject:msgBox afterDelay:2.5f];
}

- (void)closeAlert:(SoftNoticeView *)msgBox
{
    [msgBox stop];
    [msgBox removeFromSuperview];
    [msgBox release];
    mIsAlert = NO;
}

#pragma mark - 
#pragma mark - 功能快捷键
- (void) toFunctionActionSheet
{
    mFunctionAction.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
    mFunctionAction.alpha =0.8;
    [mFunctionAction showInView:self.view];
}


- (void)actionSheet:(UIActionSheet *)modalView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex)
    {
        case 0:
            [self performSelector:@selector(refreshCommentData)];
            break;
        case 1:
            [self performSelector:@selector(toComment:)];
            break;
        case 2:
            [self performSelector:@selector(toRePost:)];
            break;
        default:
            break;
    }
    
}
//微博加星操作
- (void)weiboAddStarOpt:(id)sender 
{
    mStarAmount++;
    mStarView.text = [NSString stringWithFormat:@"%lld",mStarAmount];
    UIImage * starPic =  [UIImage imageNamed:@"切图_116.png"];
    mStarImageView.image = starPic;
    [starPic release];

    mStarTipImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Like_bg.png"]];
    [mStarTipImageView setFrame:CGRectMake(108.f, 120.f, 104.f,104.f)]; 
    mStarTipImageView.backgroundColor = [UIColor clearColor];
    mStarTipImageView.alpha = 0.9;
    [self.view addSubview:mStarTipImageView];

    mStarTipLabel = [[UILabel alloc] initWithFrame:CGRectMake(108, 100+104 -30, 100, 20)];
    [mStarTipLabel setBackgroundColor:[UIColor clearColor]];
    [mStarTipLabel setTextAlignment:UITextAlignmentCenter];
    mStarTipLabel.text = @"设为喜欢";
    [mStarTipLabel setFont:[UIFont fontWithName:@"TrebuchetMS-Bold" size:16]];
    [mStarTipLabel setTextColor:[UIColor whiteColor]];
    [self.view addSubview:mStarTipLabel];
    
    [self performSelector:(@selector(dispearAlert)) withObject:nil afterDelay:2.f];
    
    mStarView.textColor =  [UIColor grayColor]; 
    mStarImageButton.enabled = NO;
    
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    //微博加星记录
    //NSLog(@"oauth username:%@ and username %@", mOAuthEngine.username, (NSString *)[defaults objectForKey:KEY_USER_NAME]);
    [self likeWeiboClick:mStatus
            onlineuserid:(long)mOAuthEngine.username
          onlineusername:(NSString *)[defaults objectForKey:KEY_USER_SCREEN_NAME]
         onlineuserimage:(NSString *)[defaults objectForKey:KEY_USER_IMG]      
             nowlatitude:[DataController getDefaultLatitude] 
             nowlongtude:[DataController getDefaultLongitude]
              nowaddress:[DataController getLocationDescription]];
    //NSLog(@"location:%@", [DataController getLocationDescription]);
    //同步更新微博列表中对应的微博加星数
    
    mIsUpdateStatusAfterStar = YES;
}

- (void)dispearAlert
{
    [mStarTipImageView removeFromSuperview];
    [mStarTipLabel removeFromSuperview];
}


#pragma mark - 
#pragma mark - Weiex 接口处理方法 

/**记录微博加星事件**/
- (void)likeWeiboClick:(Status *) status 
          onlineuserid:(long)userid
        onlineusername:(NSString *)username
       onlineuserimage:(NSString *)userimage
           nowlatitude:(double)geolat 
           nowlongtude:(double)geolng 
            nowaddress:(NSString *)address
{
    WeiexClient * mWeiexClient= [[WeiexClient alloc] initWithDele:self];
    [mWeiexClient saveClickNum:2 
                   weibostatus:status 
                   weibouserid:status.user.userId 
                    hotplaceid:-1
                  onlineuserid:userid 
                onlineusername:username
               onlineuserimage:userimage
                   nowlatitude:geolat 
                   nowlongtude:geolng 
                    nowaddress:address];
}


/**记录用户点击事件**/
//add by max
- (void)saveWbUserClick:(long long) wbuserid 
           onlineuserid:(long)userid          
         onlineusername:(NSString *)username
        onlineuserimage:(NSString *)userimage
            nowlatitude:(double)geolat 
            nowlongtude:(double)geolng 
             nowaddress:(NSString *)address
{
    WeiexClient * mWeiexClient= [[WeiexClient alloc] initWithDele:self];
    [mWeiexClient saveClickNum:3 
                   weibostatus:nil 
                   weibouserid:wbuserid 
                    hotplaceid:-1
                  onlineuserid:userid 
                onlineusername:username
               onlineuserimage:userimage
                   nowlatitude:geolat 
                   nowlongtude:geolng 
                    nowaddress:address];
}

/**根据参数获取微博加星数**/
- (void)loadWeiboStarBegin:(Status *)status
{
    WeiexClient * mWeiexClient= [[WeiexClient alloc] initWithTarget:self action:@selector(loadHotPlaceFinished:json:)]; 
    [mWeiexClient getClickNum:2
                      clickid:status.statusId];
}

- (void)loadWeiboStarFinished:(WeiexClient *)sender
                         json:(NSDictionary*)json
{
    if (json == nil) {
        NSLog(@"+++++++数据获取失败，或无数据！+++++++");
    }
    else{      
        NSArray * items = (NSArray *)json;
        for (NSDictionary * item in items) {
            NSLog(@"id:%@ num:%@",[item objectForKey:@"id"],[item objectForKey:@"num"]);
        }
    }
}


#pragma mark - 
#pragma mark - mapabout 


/**地图位置变换后，重新加载数据(代理)**/
- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(mapViewAnnotationLoad) object:nil];
    [self performSelector:@selector(mapViewAnnotationLoad) withObject:nil];
    
}

/**用微博返回的数据生成地图标识**/
- (void)mapViewAnnotationLoad
{
    [mMapViewForStatusGeo removeAnnotations:[mMapViewForStatusGeo annotations]];
    LocationAnnotation * annotaion = [[LocationAnnotation alloc] init];
    WLocation * wLocation = [[WLocation alloc] init];
    wLocation.latitude = mStatus.latitude;
    wLocation.longitude = mStatus.longitude;
    annotaion.wLocation = wLocation;
    annotaion.indexTag = 0;
    [mMapViewForStatusGeo addAnnotation:annotaion];
    [annotaion release];    
    [mMapViewForStatusGeo setSelectedAnnotations:[mMapViewForStatusGeo annotations]];
}
/**地图注释生成(代理)**/
- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation;
{  
    
    if([annotation isKindOfClass:[LocationAnnotation class]]){
        static NSString * LocationAnnotationIdentifier = @"LocationAnnotationIdentifier";
        
        MKPinAnnotationView * pinView = (MKPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:LocationAnnotationIdentifier];
        if (!pinView) {
            pinView = [[[MKPinAnnotationView alloc]
                        initWithAnnotation:annotation 
                        reuseIdentifier:LocationAnnotationIdentifier] autorelease];   
        }
        else {
            pinView.annotation = annotation;
        }
        //pinView.canShowCallout = YES;
        return pinView;
    }
    else {
        return nil;
    }
}



@end
