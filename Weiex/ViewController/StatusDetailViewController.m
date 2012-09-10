//
//  DetailViewController.m
//  WeiTansuo
//
//  Created by chishaq on 11-8-15.
//  Copyright 2011年 Invidel. All rights reserved.
//

#import "StatusDetailViewController.h"
#import "StatusRePostController.h"
#import "ProfileViewController.h"
#import "UIViewControllerCategory.h"
#import "StatusCommentViewController.h"

#define MAX_LONG_LONG_INT 9999999999999999
#define MAX_MIDDLEPIC_WIDTH  310
#define MAX_MIDDLEPIC_HEIGHT  3000
#define STATUSDATA_MAX_PAGE 8
#define STATUSDATA_PAGE_SIZE 25

@implementation StatusDetailViewController

@synthesize status = mStatus;
@synthesize oAuthEngine = mOAuthEngine;
@synthesize region = mRegion;

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
    [mUserNameLabel release];
    //[mSoftNoticeViewLoad release];
    [mLoadMoreAIView release];
    [mRefreshAIView release];
    [mCommentsTableView release];
    [mMapImageView release];
    [mMiddlePicView release];  
    [mDetailContent release];
    [mTimeLocationView release];
    [mUserPicView release];
    [mQueryCondition release];
    [mComments release];
    [mOAuthEngine release];
    [mStatus release]; 
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
    [self.view setBackgroundColor:[UIColor colorWithRed:245/255.f green:245/255.f blue:247/255.f alpha:1]];
    //导航栏
    [self setBackBarItem:@selector(back)];
    
    //功能区按钮
    UIButton * functionButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 38, 30)];
    [functionButton setImage:[UIImage imageNamed:@"export.png"] forState:UIControlStateNormal];
    [functionButton setImage:[UIImage imageNamed:@"exportPressed.png"] forState:UIControlStateHighlighted];
    [functionButton addTarget:self action:@selector(toFunctionActionSheet) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem * functionButtonItem = [[UIBarButtonItem alloc] initWithCustomView:functionButton];
    self.navigationItem.rightBarButtonItem = functionButtonItem;
    [functionButtonItem release];
     
    if (!mFunctionAction) {
        mFunctionAction = [[UIActionSheet alloc] initWithTitle:@"" 
                                                      delegate:self 
                                             cancelButtonTitle:@"关闭" 
                                        destructiveButtonTitle:nil 
                                             otherButtonTitles:@"刷新",@"评论", @"转发", nil];
    }
    
    //头部背景
    UIView * headbg = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 83)];
    [headbg setBackgroundColor:[UIColor colorWithRed:220/255.f green:220/255.f blue:220/255.f alpha:0.9f]];
    [self.view addSubview:headbg];
    [headbg release];
     
    //用户头像
    //个人详细页点击事件
    UIButton * transtClickAreaButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [transtClickAreaButton setFrame:CGRectMake(0, 0, 190, 83)];
    [transtClickAreaButton addTarget:self action:(@selector(toUserProfile:)) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:transtClickAreaButton];
    
    if (!mUserPicView) {
        mUserPicView = [[UrlImageView alloc] initWithFrame:CGRectMake(10.f, 10.f, 60.f, 60.f)];           
        if([mStatus.user.profileImageUrl length] > 5) {
            mUserPicView.imageUrl = mStatus.user.profileImageUrl;
            [mUserPicView getImageByUrl:1];
        }
        else {
            UIImage * userPic = [[UIImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"viewfile" ofType:@"png"]];
            mUserPicView.image = userPic;
            [userPic release];
        }     
        [self.view addSubview:mUserPicView];
    }
     
    //用户名
    if (!mUserNameLabel) {
        mUserNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(80.0f, 20.f, 220.0f, 20.0f)];
        mUserNameLabel.text = mStatus.user.name;
        mUserNameLabel.backgroundColor = [UIColor clearColor];
        mUserNameLabel.font = [UIFont fontWithName:@"TrebuchetMS-Bold" size:16];
        [mUserNameLabel sizeToFit];
        [self.view addSubview:mUserNameLabel];
    }
                
    //用户认证
    UIImageView *verifyinfo = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"v.png"]];
    [verifyinfo setFrame:CGRectMake(mUserNameLabel.frame.origin.x + mUserNameLabel.frame.size.width + 3, mUserNameLabel.frame.origin.y + 3, 15, 13)];
    if (mStatus.user.verified) {       
        [self.view addSubview:verifyinfo];
    }
    [verifyinfo release];
    
    //转发按钮
    CGFloat alignRepost = 320 - mUserNameLabel.frame.size.width - mUserNameLabel.frame.origin.x - 33 < 300 ? 300 : 320 - mUserNameLabel.frame.size.width - mUserNameLabel.frame.origin.x - 33;
    UIButton * repostButton = [[UIButton alloc] initWithFrame:CGRectMake(alignRepost - 30.f, 50.f, 35.f, 18.f)];
    [repostButton setImage:[UIImage imageNamed:@"planthightlight.png"] forState:UIControlStateNormal];
    [repostButton setImage:[UIImage imageNamed:@"plant.png"] forState:UIControlStateHighlighted];
    [repostButton setShowsTouchWhenHighlighted:YES];
    [repostButton addTarget:self action:(@selector(toRePost:)) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:repostButton];
    [repostButton release];
    
    //评论按钮
    UIButton * mCommentButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [mCommentButton setFrame:CGRectMake(215, 52, 35, 18)];
    [mCommentButton setImage:[UIImage imageNamed:@"commentButton2.png"] forState:UIControlStateNormal];
    [mCommentButton setImage:[UIImage imageNamed:@"commentButton.png"] forState:UIControlStateHighlighted];
    [mCommentButton setShowsTouchWhenHighlighted:YES];
    [mCommentButton addTarget:self action:(@selector(toComment:)) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:mCommentButton];
    
    //详细内容
    if (!mDetailContent) {
        mDetailContent = [[UILabel alloc] initWithFrame:CGRectMake(10.f, 17.f, 300.f, 0.f)];
        mDetailContent.text = mStatus.text;
        mDetailContent.numberOfLines = 0;
        mDetailContent.lineBreakMode = UILineBreakModeWordWrap;
        UIFont * contentFont = [UIFont fontWithName:@"Arial" size:16];
        mDetailContent.font = contentFont;
        CGSize contentSize = [mDetailContent.text sizeWithFont:contentFont 
                                             constrainedToSize:CGSizeMake(300,600)  
                                                 lineBreakMode:UILineBreakModeWordWrap];
        CGRect contentFrame = mDetailContent.frame;
        [mDetailContent setFrame:CGRectMake(contentFrame.origin.x, contentFrame.origin.y, 
                                            contentSize.width, contentSize.height)];
    }
    
    //大图
    if (!mMiddlePicView) {
        mMiddlePicView = [[UrlImageView alloc] init];
        if([mStatus.bmiddlePic length] > 5) {
            mMiddlePicView.frame = CGRectMake(10.f, mDetailContent.frame.origin.y + mDetailContent.frame.size.height + 5.f, 300.f, 100.f);
            mMiddlePicView.imageUrl = mStatus.bmiddlePic;
            mMiddlePicView.finishTarget = self;
            mMiddlePicView.finishAction = @selector(finishLoadImage);
            mIsLoadingImage = YES;              
            [mMiddlePicView getImageByUrl:3];
        }
        else {
            mMiddlePicView.frame = CGRectMake(0, mDetailContent.frame.origin.y+mDetailContent.frame.size.height + 5.f, 0, 0);
        }
    }
    //相对位置地图展示区
      
    if (!mMapImageView) {
        if (mStatus.latitude > 0 && mStatus.longitude > 0) {
            mMapImageView = [[UIWebView alloc] initWithFrame:CGRectMake(10.f, mMiddlePicView.frame.origin.y+mMiddlePicView.frame.size.height + 10.f, 300.f, 100.f)];
            
            CLLocationCoordinate2D neightbor;
            neightbor.latitude = mStatus.latitude;
            neightbor.longitude = mStatus.longitude;
            GoogleClient * googleClient = [[GoogleClient alloc] init];
            NSString * mapImageUrl_Str = [googleClient allocGetMapImageUrlByRegion:neightbor
                                                                            neighbor:neightbor 
                                                                          imageWidth:300
                                                                         imageHeight:100];
            [googleClient release];
            NSURL * mapImageUrl = [NSURL URLWithString:mapImageUrl_Str];
            NSURLRequest * mapImageRequest = [NSURLRequest requestWithURL:mapImageUrl];
            [mMapImageView loadRequest:mapImageRequest];
            [mapImageUrl_Str release];
            
            UIButton * mapImageViewBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            mapImageViewBtn.frame = CGRectMake(0, 5, mMapImageView.frame.size.width, mMapImageView.frame.size.height);
            [mapImageViewBtn addTarget:self action:@selector(toStatusLocationView) forControlEvents:UIControlEventTouchDown];
            [mMapImageView addSubview:mapImageViewBtn];
            
            UIView * mapLayout = [[UIView alloc] init];
            mapLayout.frame = CGRectMake(0, mMapImageView.frame.size.height - 10, 300, 10);
            mapLayout.backgroundColor = [UIColor whiteColor];
            [mMapImageView addSubview:mapLayout];
            [mapLayout release];

        }   
        else {            
            mMapImageView = [[UIWebView alloc] initWithFrame:CGRectMake(10.f, mMiddlePicView.frame.origin.y + mMiddlePicView.frame.size.height, 0, 5.f)];          
        }
    }
    
    
    
    //距离与时间
    
    if (!mTimeLocationView) {
        mTimeLocationView = [[UIView alloc] init];
        
        UIImageView *relationLocationIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"position15px.png"]];
        [relationLocationIcon setFrame:CGRectMake(0, 2, 12, 12)];
        if (mStatus.longitude > 0 && mStatus.latitude > 0) {
            [mTimeLocationView addSubview:relationLocationIcon];
        }        
        [relationLocationIcon release];    
        
        UILabel *relationLocation = [[UILabel alloc] initWithFrame:CGRectMake(13, 2, 0, 0)];
        [relationLocation setText:mStatus.relativeLocation];		
        [relationLocation setBackgroundColor:[UIColor clearColor]];
        [relationLocation setFont:[UIFont fontWithName:@"Arial" size:12]];
        [relationLocation sizeToFit];
        [mTimeLocationView addSubview:relationLocation];
        [relationLocation release];    
        
        UIImageView * createAtIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"clock15px.png"]];
        [createAtIcon setFrame:CGRectMake(relationLocation.frame.size.width + relationLocationIcon.frame.size.width + 2 + 2, 3, 12, 12)];
        [mTimeLocationView addSubview:createAtIcon];
        [createAtIcon release];
        
        UILabel *createAt = [[UILabel alloc] initWithFrame:CGRectMake(relationLocation.frame.size.width + relationLocationIcon.frame.size.width + createAtIcon.frame.size.width + 2 + 2 + 2, 2, 0, 0)];
        [createAt setText:mStatus.timestamp];
        [createAt setBackgroundColor:[UIColor clearColor]];
        [createAt setFont:[UIFont fontWithName:@"Arial" size:12]];
        [createAt sizeToFit];
        [mTimeLocationView addSubview:createAt];
        [createAt release];
        CGFloat alignLeftWidth = 300 - 24 - relationLocation.frame.size.width - createAt.frame.size.width;
        [mTimeLocationView setFrame:CGRectMake(alignLeftWidth , mMapImageView.frame.size.height - 10 + mMapImageView.frame.origin.y + 5.f, 210.f, 12.f)];
    }        
    

    //评论列表
    if (!mCommentsTableView) {
        CGRect tableframe = self.view.frame;
        tableframe.size.height -= 81.f+44.f;
        tableframe.origin.y = 81.f;
        mCommentsTableView = [[UITableView alloc] initWithFrame:tableframe
                                                          style:UITableViewStylePlain];
        mCommentsTableView.delegate = self;
        mCommentsTableView.dataSource = self;
        [self.view addSubview:mCommentsTableView];
        [self.view sendSubviewToBack:mCommentsTableView];
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
    
    
    //加载框
    /*
    if (!mSoftNoticeViewLoad) {
        mSoftNoticeViewLoad = [[SoftNoticeView alloc] initWithFrame:CGRectMake(90, 170, 140, 140)];
        [mSoftNoticeViewLoad setMessage:@"数据获取中..."];
        [mSoftNoticeViewLoad setActivityindicatorHidden:NO];
        [mSoftNoticeViewLoad setHidden:YES];
        [self.view addSubview:mSoftNoticeViewLoad];
    }
     */
    
    //--------------------开始获取数据-------------------------//
    [self refreshCommentData]; 
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    
//    [mSoftNoticeViewLoad release];
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
    mTimeLocationView = nil;
    [mTimeLocationView release];
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
        [self alert:@"网络异常"];
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
		[self alert:@"网络异常"];
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
    [self.navigationController.navigationBar addSubview:mRefreshAIView];
    [mRefreshAIView startAnimating];
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
        height = mDetailContent.frame.size.height+mMapImageView.frame.size.height + mTimeLocationView.frame.size.height + 35.f;
        if ([mStatus.bmiddlePic length] > 5) {
            height += mMiddlePicView.frame.size.height + 5 + 16;
        }
    }
    else if(indexPath.row >1 && indexPath.row < [mComments count]+2) {
        StatusItemCell * cell = (StatusItemCell *)[self tableView:tableView cellForRowAtIndexPath:indexPath];
        height = [cell getCellHeight];
        
    }
    else if(indexPath.row == 1){
        height = 40.f;
    }
    else {
        height = 60.f;
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
            return count + 3;
        }
        else {
            return count +2;
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
        [cell addSubview:mDetailContent];
        [cell addSubview:mMapImageView];
        [cell addSubview:mMiddlePicView];
        [cell addSubview:mTimeLocationView];
                
        return cell;
        
    }
    else if(indexPath.row == 1) {       //评论标题
        UITableViewCell * cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"cell_title"];
        if (cell == nil){
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1
                                           reuseIdentifier:@"cell_title"] autorelease];
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        UIImageView * commentImage =[[UIImageView alloc] initWithFrame:CGRectMake(10.f, 10.f, 22.f, 20.f)];
        commentImage.image = [UIImage imageNamed:@"comments.png"];
        [cell addSubview:commentImage];
        [commentImage release];
        
        UILabel *commentCount = [[UILabel alloc] initWithFrame:CGRectMake(35.f, 10.f, 200.f, 18.f)];
        commentCount.font = [UIFont fontWithName:@"Arial" size:16];
        commentCount.text = [[[NSString alloc] initWithFormat:@"(%d)",mCommentsCount] autorelease]; 
        [cell addSubview:commentCount];
        [commentCount release];
        return cell;
    }
    else if (indexPath.row > 1 && indexPath.row < [mComments count]+2) {                             //评论
        StatusItemCell *cell = (StatusItemCell *)[tableView dequeueReusableCellWithIdentifier:@"cell_comments"];
        if (cell == nil) {
            cell = [[[StatusItemCell alloc] initWithStyle:UITableViewCellStyleDefault
                                          reuseIdentifier:@"cell_comments"] autorelease];
        }
        cell.userInteractionEnabled = NO;
        Status * comment = [mComments objectAtIndex:indexPath.row-2];    
        cell.userName.text= comment.user.screenName;                               //用户名
        cell.cellContentView.text = comment.text;                            //内容
        cell.timeLabel.text = comment.timestamp;                             //发表时间 
        cell.userPicView.imageUrl = comment.user.profileImageUrl;            //用户头像
        [cell.userPicView getImageByUrl:1]; 
        [cell sizeToFit];
        
        return cell;
    }
    else if (indexPath.row == [mComments count]+2) {
        UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"cell_comments_more"];
        if (cell == nil) {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                          reuseIdentifier:@"cell_comments_more"] autorelease];
        }
        cell.userInteractionEnabled = NO;

        cell.textLabel.textAlignment =UITextAlignmentCenter;
        cell.textLabel.font = [UIFont fontWithName:@"Arial" size:16];
        cell.textLabel.textColor = [UIColor grayColor];
        cell.textLabel.text = @"加载中...";
        [cell addSubview:mLoadMoreAIView];
        [self loadMoreCommentData];

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

/**图片下载成功后的回调**/
-(void) finishLoadImage
{
    //重新调整图片的缩放比例
    CGRect frame = mMiddlePicView.frame;
    CGFloat frameWidth = 300.f;
    CGFloat realWidth = mMiddlePicView.image.size.width;
    CGFloat realHeight = mMiddlePicView.image.size.height;
    CGFloat frameHeight= frameWidth * realHeight/realWidth;
    if (frameHeight > MAX_MIDDLEPIC_HEIGHT) {
        frameHeight = MAX_MIDDLEPIC_HEIGHT;
    }
    [mMiddlePicView setFrame:CGRectMake(10.f, frame.origin.y, frameWidth, frameHeight)];
    //重新调整地图位置
    [mMapImageView setFrame:CGRectMake(mMapImageView.frame.origin.x, 
                                       frame.origin.y+frameHeight + 10.f, 
                                       mMapImageView.frame.size.width, 
                                       mMapImageView.frame.size.height)];
    
    [mTimeLocationView setFrame:CGRectMake(mTimeLocationView.frame.origin.x, 
                                           mMapImageView.frame.origin.y + mMapImageView.frame.size.height + 5.f, 
                                           mTimeLocationView.frame.size.width,
                                           mTimeLocationView.frame.size.height)];
    //重新调整相应cell
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
        
    [self.navigationController popViewControllerAnimated:YES];
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

/**微博加星操作**/
-(void)addStarToWeibo:(Status *)status
{
    //保存微博加星事件 add by max
    [self  likeWeiboClick:status 
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
    mWeiexClient= [[WeiexClient alloc] initWithDele:self];
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
    mWeiexClient= [[WeiexClient alloc] initWithDele:self];
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
    mWeiexClient= [[WeiexClient alloc] initWithTarget:self action:@selector(loadHotPlaceFinished:json:)]; 
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

@end
