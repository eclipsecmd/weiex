//
//  ProfileViewController.m
//  WeiTansuo
//
//  Created by Sai Li on 9/3/11.
//  Copyright 2011 Invidel. All rights reserved.
//

#import "ProfileViewController.h"
#import "UrlImageView.h"
#import "ClickImageView.h"
#import "UIViewControllerCategory.h"

#define MAX_LONG_LONG_INT 9999999999999999
#define MAX_CELL_IMAGE_HEIGHT 80.f
#define CELL_CONTENT_WIDTH 320.0f
#define CELL_CONTENT_MARGIN 5.0f
#define STATUSDATA_MAX_PAGE 15
#define STATUSDATA_PAGE_SIZE 20
#define MAX_LOCATE_TIME 4

@implementation ProfileViewController

@synthesize user = mUser;
@synthesize oauth = mOauth;

@synthesize statuses = mStatuses;
@synthesize queryStatus = mQueryStatus;

- (id)init
{
    self = [super init];
    if (self) {
        mStatuses = [[NSMutableArray alloc] init];
        mQueryStatus = [[QueryStatus alloc] init];        
    }
    return self;
}

- (void)dealloc
{
    [mUser release];
    [mOauth release];
    [mTagsLabel release];
    [mTags release];
    [mNamePic release];
    [mProfile release];
    [mSoftNoticeViewLoad release];
    [mRefreshHeaderView release];
    [mLoadMoreImageView release];
    [mTableView release];
    [mStatuses release];
    [mQueryStatus release];
    [mLoadMoreAIView release];
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
    
    //[self.view setBackgroundColor:[UIColor colorWithRed:245/255.f green:245/255.f blue:247/255.f alpha:1]];
    //导航栏
    //[self setBackBarItem:@selector(back)];
    
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
    detailLabel.text = mUser.screenName;
    detailLabel.font = [UIFont fontWithName:@"TrebuchetMS-Bold" size:18];
    detailLabel.textColor = [UIColor whiteColor];
    [self.view addSubview:detailLabel];
    [detailLabel release];       
    
    
    //头部
    mNamePic = [[UIView alloc] init];
    [mNamePic setFrame:CGRectMake(6, 44, 308, 100)];    
    [mNamePic setBackgroundColor:[UIColor clearColor]];
    mNamePic.layer.cornerRadius = 15.f;
    
//    //头部背景
//    UIView * headbg = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 83)];
//    [headbg setBackgroundColor:[UIColor colorWithRed:220/255.f green:220/255.f blue:220/255.f alpha:0.9f]];
//    [self.view addSubview:headbg];
//    [headbg release];
    
    //头像
    UrlImageView * userAvatarView = [[UrlImageView alloc] init];
    [userAvatarView setFrame:CGRectMake(13, 13, 60, 60)];    
    if([mUser.profileImageUrl length] > 0) {
        userAvatarView.imageUrl = mUser.profileImageUrl;
        [userAvatarView getImageByUrl:1];
    }
    else {
        UIImage * userPic = [[[UIImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"viewfile" ofType:@"png"]] autorelease];
        [userAvatarView setImage:userPic];
    }  
    [mNamePic addSubview:userAvatarView];
    [userAvatarView release];
    //性别
    UIImageView * genderIcon = [[UIImageView alloc] init];
    if (mUser.gender == 1) {
        [genderIcon setImage:[UIImage imageNamed:@"male.png"]];
    }
    else {
        [genderIcon setImage:[UIImage imageNamed:@"female.png"]];
    }
    genderIcon.frame = CGRectMake(62, 7, 15, 18);    
    [mNamePic addSubview:genderIcon];
    [genderIcon release];
    
    //姓名
    UILabel * userName = [[UILabel alloc] init];
    [userName setFrame:CGRectMake(80, 20, 180, 20)];    
    [userName setTextColor:[UIColor blackColor]];
    [userName setBackgroundColor:[UIColor clearColor]];
    [userName setText:mUser.screenName];
    [userName setFont:[UIFont fontWithName:@"TrebuchetMS-Bold" size:16]];
    [userName sizeToFit];
    
    //加V
    UIImageView *verifyinfo = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"v.png"]];
    [verifyinfo setFrame:CGRectMake(userName.frame.origin.x + userName.frame.size.width + 3, userName.frame.origin.y + 3, 15, 13)];
    
    if (mUser.verified) {
        [mNamePic addSubview:verifyinfo];
    }
    [verifyinfo release];
    [mNamePic addSubview:userName];
    [userName release];

    //来源
    UIImageView * locationIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"hometown.png"]];
    [locationIcon setFrame:CGRectMake(75, 58, 15, 12)];
    [mNamePic addSubview:locationIcon];
    [locationIcon release];
    
    UILabel * locationLabel = [[UILabel alloc] init];
    [locationLabel setBackgroundColor:[UIColor clearColor]];
    [locationLabel setFont:[UIFont fontWithName:@"Arial" size:13]];
    [locationLabel setFrame:CGRectMake(95, 58, 0, 0)];
    [locationLabel setText:mUser.location];
    [locationLabel sizeToFit];
    [mNamePic addSubview:locationLabel];
    [locationLabel release];
    
    
    
    
    /*
    UIImageView * timeIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"registertime.png"]];
    [timeIcon setFrame:CGRectMake(locationLabel.frame.size.width + locationLabel.frame.origin.x + 15, 58, 15, 12)];
    UILabel * timeLabel = [[UILabel alloc] init];
    [timeLabel setBackgroundColor:[UIColor clearColor]];
    [timeLabel setFont:[UIFont fontWithName:@"Arial" size:13]];
    [timeLabel setFrame:CGRectMake(timeIcon.frame.size.width + timeIcon.frame.origin.x + 15, 57, 0, 0)];
    [timeLabel setText:[mUser getTimestamp]];
    [timeLabel sizeToFit];    
    [mNamePic addSubview:timeIcon];
    [mNamePic addSubview:timeLabel];   
    [timeIcon release];
    [timeLabel release];    
    */
    
    [self.view addSubview:mNamePic];
   
    
    //设置列表视图
    if (!mTableView) {
        CGRect tableframe = self.view.frame;
        tableframe.size.height -= 90.f + 44.f;
        tableframe.size.width = 300.f;
        tableframe.origin.x = 10.f;
        tableframe.origin.y = 44.f + 80;
        mTableView = [[UITableView alloc] initWithFrame:tableframe
                                                  style:UITableViewStylePlain];
        [mTableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
        mTableView.delegate = self;
        mTableView.dataSource = self; 
        mTableView.backgroundColor = [UIColor clearColor]; 
        [self.view addSubview:mTableView];
    }
    
    //设置头部下拉刷新
    if (!mRefreshHeaderView) { 
        mRefreshHeaderView = [[EGORefreshTableHeaderView alloc] 
                              initWithFrame:CGRectMake(0.0f, -135 - mTableView.bounds.size.height, mTableView.frame.size.width, self.view.bounds.size.height)]; 
        mRefreshHeaderView.delegate = self; 
        [mTableView addSubview:mRefreshHeaderView]; 
        [mRefreshHeaderView refreshLastUpdatedDate];
    } 
    
    //加载更多
    if (!mLoadMoreImageView) {
        mLoadMoreImageView = [[UIImageView alloc] initWithFrame:CGRectMake(100, 14, 18, 17)];
        mLoadMoreImageView.image = [UIImage imageNamed:@"loadmore.png"];
        [mLoadMoreImageView setHidden:NO];
    }
    if (!mLoadMoreAIView) {
        mLoadMoreAIView = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(100, 12, 19, 19)];
        mLoadMoreAIView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray; 
    }
    
    //加载框
    if (!mSoftNoticeViewLoad) {
        mSoftNoticeViewLoad = [[SoftNoticeView alloc] initWithFrame:CGRectMake(90, 130, 140, 140)];
        //NSString * tempmsg = [NSString stringWithFormat:, mUser.screenName];//[NSString stringWithFormat:@"%@加载 %@ 的微博",.screenName];
        [mSoftNoticeViewLoad setMessage:@"正在加载"];
        //[tempmsg release];
        [mSoftNoticeViewLoad setActivityindicatorHidden:NO];
        [mSoftNoticeViewLoad setHidden:YES];
        
        [self.view addSubview:mSoftNoticeViewLoad];
    }
    
    //个人简介    
    if (!mProfile) {
        mProfile = [[UILabel alloc] init];
        [mProfile setFrame:CGRectMake(5, 5, 290, 0)];
        [mProfile setNumberOfLines:0];
        [mProfile setBackgroundColor:[UIColor clearColor]];
        //[mProfile setTextColor:[UIColor grayColor]];
        //[mProfile setTextAlignment:UITextAlignmentCenter];
        //[mProfile setLineBreakMode:UILineBreakModeCharacterWrap];
        [mProfile setFont:[UIFont fontWithName:@"Arial" size:15]];
        
        /*
         CGSize contentViewSize = [mProfile.text sizeWithFont:[UIFont fontWithName:@"Arial" size:15] 
         constrainedToSize:CGSizeMake(320,140)  
         lineBreakMode:UILineBreakModeWordWrap];
         CGRect contentViewFrame = mProfile.frame;
         [mProfile setFrame:CGRectMake(contentViewFrame.origin.x, contentViewFrame.origin.y, 
         contentViewSize.width, contentViewSize.height)];
         */
    }

    
    
    
    /**-----------------开始加载数据--------------------**/
    [self refreshData];
//------------------------//
//      [mTableView reloadData];   
//      [self loadTagsCountBegin];
    
      [self friendshipsShow];

}


- (void)viewDidUnload
{
    mProfile = nil;
    [mProfile release];
    mTags = nil;
    [mTags release];
    mTagsLabel = nil;
    [mTagsLabel release];
    mNamePic = nil;
    [mNamePic release];
    mTableView = nil;
    [mTableView release];
    mRefreshHeaderView = nil;
    [mRefreshHeaderView release];
    mLoadMoreImageView = nil;
    [mLoadMoreImageView release];
    mLoadMoreAIView = nil;
    [mLoadMoreAIView release];
    mSoftNoticeViewLoad = nil;
    [mSoftNoticeViewLoad release];
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}


#pragma mark -
#pragma mark - 数据初始化

- (void)initMStatusData
{
    [mStatuses removeAllObjects];
    mCurrentStatueId = MAX_LONG_LONG_INT;
}

- (void) initQueryStatus
{
    //微博总数
    mStatusCount = mUser.statusesCount;
    mQueryStatus.page = 1;
    mQueryStatus.count = STATUSDATA_PAGE_SIZE;
}

#pragma mark -
#pragma mark - 微博数据处理 之 获取微博
/**开始获取数据**/
- (void)loadDataBegin
{
    mWeiboClient = [[WeiboClient alloc] initWithTarget:self 
                                                             engine:mOauth
                                                             action:@selector(loadDataFinished:obj:)];   
    [mWeiboClient getUserTimelineSinceID:mQueryStatus.sinceId 
                                 UserID:mUser.userId 
                                  maxID:mQueryStatus.maxId 
                                  Count:mQueryStatus.count 
                                   Page:mQueryStatus.page 
                                baseAPP:mQueryStatus.baseApp 
                                Feature:mQueryStatus.feature];
    
}
- (void)loadDataFinished:(WeiboClient *)sender
                     obj:(NSObject*)obj
{
    
    if (sender.hasError) {
        [self endLoadData];
        [self alert:@"网络异常"];
    }
    else{
        //清理数据
        if (mLoadingDataType == 1) {
            [self initMStatusData];
        }
        //存储微博数据
        NSArray * ary = (NSArray *)obj;
        for (NSDictionary * dic in ary) {
            if (![dic isKindOfClass:[NSDictionary class]]) {
                continue;
            }
            Status* sts = [Status statusWithJsonDictionary:dic MyRegion:[DataController getDefaultRegion]];
            if (sts.statusId >= mCurrentStatueId) {
                continue;
            }
            [mStatuses addObject:sts];
            mCurrentStatueId = sts.statusId;
        }
        [self endLoadData];
    } 
}
/**刷新微博数据**/
- (BOOL)beforeRefreshData       //返回是否可以刷新
{
    if (mIsLoadingData) {
        return NO;
    }
    mIsLoadingData = YES;
    mLoadingDataType = 1;
    [mSoftNoticeViewLoad setHidden:NO];
    [mSoftNoticeViewLoad start];
    [self tableviewScrollToTop:YES];
    return YES;
}

-(void)endRefreshData
{
    [mRefreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:mTableView];
    
    [mSoftNoticeViewLoad stop];
    [mSoftNoticeViewLoad setHidden:YES];
    [self tableViewBegin];
    mLoadingDataType = 0;
    mIsLoadingData = NO;
}
- (void)refreshData
{
    if (![self beforeRefreshData])  return;
    //初始化参数列表
    [self initQueryStatus];
    [self loadDataBegin];    
}

/**加载更多微博数据**/
- (BOOL)beforeLoadMoreData      //返回是否可以加载更多
{
    if (mIsLoadingData) {
        return NO;
    }
    mIsLoadingData = YES;
    mLoadingDataType = 2;
    [mLoadMoreImageView setHidden:YES];
    [mLoadMoreAIView startAnimating];
    return YES;
}
- (void)endLoadMoreData
{
    [mLoadMoreAIView stopAnimating];
    [mLoadMoreImageView setHidden:NO];
    [self tableViewBegin];
    mLoadingDataType = 0;
    mIsLoadingData = NO;
}
- (void)loadMoreData
{
    if (![self beforeLoadMoreData])  return;
    mQueryStatus.page ++;
    [self loadDataBegin];
    
}
/**辅助方法**/
- (void)endLoadData
{
    if ([mStatuses count] == 0) {
        [mTableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    }
    else {
        [mTableView setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
    }
    
    if (mLoadingDataType == 1) {
        [self endRefreshData];
    } 
    else if(mLoadingDataType == 2) {
        [self endLoadMoreData];
    }
}
/**是否可以加载更多**/
- (BOOL)ifCanLoadMore
{
    return (mQueryStatus.page <= STATUSDATA_MAX_PAGE && [mStatuses count] > 0 && [mStatuses count] < mStatusCount);
}


#pragma mark -
#pragma mark - 微博数据处理 之 标签、关注等
- (void)operationTags
{    
    if (mTags) {
        for (NSDictionary * dic in mTags) {
            if (![dic isKindOfClass:[NSDictionary class]]) {
                continue;
            }            
        }
        
        /*
         NSMutableString *ids = [[NSMutableString alloc]init];
         NSEnumerator * myenmerator = [mTags objectEnumerator];
         while (myenmerator.nextObject) {
         [ids appendFormat:@" %@ ", [myenmerator nextObject]];
         }        
         [mTagsLabel setText:ids];
         [mTagsLabel sizeToFit];
         [ids release];
         */
    }
}

-(void)loadTagsCountBegin
{
    if (!mIsLoadingTagCount) {
        mIsLoadingTagCount = YES;
        mWeiboClient = [[WeiboClient alloc] initWithTarget:self engine:mOauth action:@selector(loadTagsCountFinished:obj:)];
        [mWeiboClient getUserTags:mUser.userId];
    }
}

-(void)loadTagsCountFinished:(WeiboClient *)sender obj:(NSObject*)obj
{
    mIsLoadingTagCount = NO;
    if (sender.hasError) {
        [self alert:@"网络异常"];
    }
    else {
        if (obj != nil) {
            //mTags = (NSDictionary *)obj;
            //[self operationTags];
        }        
    }
}

- (void)operationFriendship
{
    mFollowIt = [[UIButton alloc] init];
    mFollowIt.frame = CGRectMake(240, 9, 70, 24);
    mFollowIt.titleLabel.font = [UIFont fontWithName:@"Arial" size:15];
    mFollowIt.layer.cornerRadius = 4.f;
    mFollowIt.backgroundColor = [UIColor darkGrayColor];
    if (isFollowClient == 0) {
        [mFollowIt setTitle:@"关注" forState:UIControlStateNormal];
    } else {
        [mFollowIt setTitle:@"取消关注" forState:UIControlStateNormal];
    }
    [mFollowIt.titleLabel setTextAlignment:UITextAlignmentCenter];
    [mFollowIt addTarget:self action:@selector(followIt) forControlEvents:UIControlEventTouchUpInside];    
//    UIBarButtonItem * locateBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:mFollowIt];
//    self.navigationItem.rightBarButtonItem = locateBarButtonItem;
    [self.view addSubview:mFollowIt];
}

- (void)followIt
{
    switch (isFollowClient) {
        case 0:
            //
            [self followwww];
            break;
        case 1:
            //
            [self unfowwowww];
            break;
        default:
            break;
    }
}

- (void)followwww
{
    mWeiboClient = [[WeiboClient alloc] initWithTarget:self engine:mOauth action:@selector(followFinished:obj:)];
    [mWeiboClient follow:mUser.userId];
}

- (void)unfowwowww
{
    mWeiboClient = [[WeiboClient alloc] initWithTarget:self engine:mOauth action:@selector(unfollowFinished:obj:)];
    [mWeiboClient unfollow:mUser.userId];
}


- (void)followFinished:(WeiboClient *)sender obj:(NSObject *)obj
{
    if (sender.hasError) {
        [sender alert];
    } else {
        [mFollowIt setTitle:@"取消关注" forState:UIControlStateNormal];
        isFollowClient = 1;
        //[mFollowIt addTarget:self action:@selector(unfowwowww) forControlEvents:UIControlStateNormal];
    }
}

- (void)unfollowFinished:(WeiboClient *)sender obj:(NSObject *)obj
{
    if (sender.hasError) {
        [sender alert];
    } else {
        [mFollowIt setTitle:@"关注" forState:UIControlStateNormal];
        isFollowClient = 0;
        //[mFollowIt addTarget:self action:@selector(followwww) forControlEvents:UIControlStateNormal];
    }
}


- (void)friendshipsShow
{
    if (!mIsLoadingFollow) {
        mIsLoadingFollow = YES;
        mWeiboClient = [[WeiboClient alloc] initWithTarget:self engine:mOauth action:@selector(loadFriendshipsShowFinished:obj:)];
        [mWeiboClient getFriendship:mUser.userId];
    }
}

- (void)loadFriendshipsShowFinished: (WeiboClient *)sender obj:(NSObject *)obj
{
    mIsLoadingFollow = NO;
    if (sender.hasError) {
        [sender alert];
    }
    else {
        if (!obj) {
            isFollowClient = 0;            
        }
        NSDictionary * dics = (NSDictionary *)obj;
        //source is myself
        //NSDictionary * sourceDic = [dics objectForKey:@"source"];
        //int isFollowed = [sourceDic getIntValueForKey:@"following" defaultValue:-1];
        
        NSDictionary * targetDic = [dics objectForKey:@"target"];
        int isFollowing = [targetDic getIntValueForKey:@"following" defaultValue:-1];
        isFollowClient = isFollowing;
        /*
        if (isFollowed == 1 && isFollowing == 1) {
            //we followed each other.we are good friend! ON.
            isFollowClient = 3;
        }
        else if (isFollowed == 1 && isFollowing == 0) {
            //I am a Fan of He/She. ON.
            isFollowClient = 2;
        }
        else if (isFollowed == 0 && isFollowing == 1) {
            //He/Her is one of fan belong me. OFF.
            isFollowClient = 1;
        }
        else {
            //there are nothing betweent us. OFF.
            isFollowClient = 0;
        }
        */
        [self operationFriendship];
    }
}


#pragma mark -
#pragma mark - 展示数据 之 [列表展示]
/**列表开始展示**/
- (void) tableViewBegin
{
    [mTableView reloadData];
}
/**到顶部**/
- (void)tableviewScrollToTop:(BOOL)animated 
{
    [mTableView setContentOffset:CGPointMake(0,0) animated:animated];
}
/**生成列表表格 Height**/
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{  
    if (indexPath.row == 0) {
        return mProfile.frame.size.height + 50;
    }
    else if (indexPath.row <= [mStatuses count]) {
        StatusItemCellPro * cell = (StatusItemCellPro *)[self tableView:tableView cellForRowAtIndexPath:indexPath];
        return [cell getCellHeight];
    }
    else {
        return 50.f;
    }
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    int count = [mStatuses count];
    if ([self ifCanLoadMore]) {
        count ++ ; 
    }
    count ++;
    return count;
}
/**生成列表表格**/
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        UITableViewCell * cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"pro_cell_header"];
        if (cell == nil) {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"pro_cell_header"] autorelease];
        }
        [cell setUserInteractionEnabled:NO];
        
        UIView * cellbg = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 300, mProfile.frame.size.height + 40)];
        [cellbg setBackgroundColor:[UIColor groupTableViewBackgroundColor]];
        cellbg.layer.cornerRadius = 5.f;
        [cell addSubview:cellbg];
        [cellbg release];

        [mProfile setText:[mUser.description length] > 0 ? mUser.description : @"什么也没留下"];
        [mProfile sizeToFit];
                
        [cell addSubview:mProfile];
        
        CGFloat labelsHeight = mProfile.frame.origin.y + mProfile.frame.size.height + 10;
        
        UILabel *  fansTitle = [[UILabel alloc] init];
        [fansTitle setFrame:CGRectMake(15, labelsHeight, 35, 15)];
        [fansTitle setText:@"粉丝"];
        [fansTitle setFont:[UIFont fontWithName:@"Arial" size:14]];
        [fansTitle setBackgroundColor:[UIColor clearColor]];
        //[fansTitle sizeToFit];
        [cell addSubview:fansTitle];
        [fansTitle release];
        
        UILabel * friendsTitle = [[UILabel alloc] init];
        [friendsTitle setFrame:CGRectMake(115, labelsHeight, 35, 15)];
        [friendsTitle setText:@"关注"];
        [friendsTitle setFont:[UIFont fontWithName:@"Arial" size:14]];
        [friendsTitle setBackgroundColor:[UIColor clearColor]];
        //[friendsTitle sizeToFit];
        [cell addSubview:friendsTitle];
        [friendsTitle release];
        
        UILabel * statusTitle = [[UILabel alloc] init];
        [statusTitle setFrame:CGRectMake(205, labelsHeight, 35, 15)];
        [statusTitle setText:@"微博"];
        [statusTitle setFont:[UIFont fontWithName:@"Arial" size:14]];
        [statusTitle setBackgroundColor:[UIColor clearColor]];
        //[statusTitle sizeToFit];
        [cell addSubview:statusTitle];
        [statusTitle release];        
        
        UILabel * fansCount = [[UILabel alloc] init];
        [fansCount setText:[NSString stringWithFormat:@"%d", mUser.followersCount]];
        [fansCount setFrame:CGRectMake(fansTitle.frame.origin.x + fansTitle.frame.size.width + 2, labelsHeight, 80, 16)];
        [fansCount setTextColor:[UIColor blueColor]];
        [fansCount setBackgroundColor:[UIColor clearColor]];
        [fansCount setFont:[UIFont fontWithName:@"Arial" size:16]];
        [fansCount setTextAlignment:UITextAlignmentLeft];
        [cell addSubview:fansCount];
        [fansCount release];
        
        
        UILabel * friendsCount = [[UILabel alloc] init];
        [friendsCount setText:[NSString stringWithFormat:@"%d", mUser.friendsCount]];
        [friendsCount setFrame:CGRectMake(friendsTitle.frame.origin.x + friendsTitle.frame.size.width + 2, labelsHeight, 80, 15)];
        [friendsCount setBackgroundColor:[UIColor clearColor]];
        [friendsCount setFont:[UIFont fontWithName:@"Arial" size:16]];
        [friendsCount setTextAlignment:UITextAlignmentLeft];
        [friendsCount setTextColor:[UIColor blueColor]];
        [friendsCount setBackgroundColor:[UIColor clearColor]];
        [cell addSubview:friendsCount];
        [friendsCount release];
        
        
        UILabel * statusCount = [[UILabel alloc] init];
        [statusCount setText:[NSString stringWithFormat:@"%d", mUser.statusesCount]];
        [statusCount setFrame:CGRectMake(statusTitle.frame.origin.x + statusTitle.frame.size.width + 2, labelsHeight, 80, 16)];
        [statusCount setBackgroundColor:[UIColor clearColor]];
        [statusCount setFont:[UIFont fontWithName:@"Arial" size:16]];
        [statusCount setTextAlignment:UITextAlignmentLeft];
        [statusCount setTextColor:[UIColor blueColor]];
        [statusCount setBackgroundColor:[UIColor clearColor]];
        [cell addSubview:statusCount];
        [statusCount release];
        
        
//        //标签
//        if (!mTagsLabel) {
//            mTagsLabel = [[UILabel alloc] init];                           
//            [mTagsLabel setFrame:CGRectMake(10, 300, 300, 0)];
//            [mTagsLabel setNumberOfLines:0];
//            [mTagsLabel setFont:[UIFont fontWithName:@"Arial" size:15]];
//            //[self.view addSubview:mTagsLabel];        
//        }
        
        return cell;
    }
    else if (indexPath.row <= [mStatuses count]) {
        StatusItemCellPro *cell = (StatusItemCellPro *)[tableView dequeueReusableCellWithIdentifier:@"pro_cell_status"];
        if (cell == nil) {
            cell = [[[StatusItemCellPro alloc] initWithStyle:UITableViewCellStyleDefault
                                             reuseIdentifier:@"pro_cell_status"] autorelease];
        }
      
        Status * status = [mStatuses objectAtIndex:(indexPath.row - 1)];      //用户名
        cell.cellContentView.text = status.text;                            //内容
        //cell.timeLabel.text = status.timestamp;                             //发表时间
        if ([status.relativeLocation length] > 0) {
            cell.relativeLocation.text = [NSString stringWithFormat:@"%@ | %@", status.timestamp, status.relativeLocation];//status.relativeLocation;               //距离   
        } else {
            cell.relativeLocation.text = status.timestamp;
        }
        cell.middlePicView.imageUrl = status.thumbnailPic;                  //大图
        cell.bigImgTarget = self;                                           //弹出大图对象
        cell.showBigImgAction = @selector(showBigImage:);                   //弹出大图方法
        cell.middlePicUrl = status.originalPic;
        
        [cell.middlePicView getImageByUrl:2];
    
        if (status.retweetedStatus) {
            cell.isRetweet = YES;
            cell.origialName.text = status.retweetedStatus.user.screenName;
            cell.origialContent.text = status.retweetedStatus.text;
            cell.origialSmallPic.imageUrl = status.retweetedStatus.thumbnailPic;
            cell.origialPicUrl = status.retweetedStatus.originalPic;
            [cell.origialSmallPic getImageByUrl:2];
        }
        else {
            cell.isRetweet = NO;
        }
        
        [cell sizeToFit];
        
        return cell;
    }
    else if(indexPath.row == [mStatuses count] + 1){   
        
        UITableViewCell * cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"pro_cell_loadmore"];
        if (cell == nil){
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                           reuseIdentifier:@"pro_cell_loadmore"] autorelease];
        }
        [cell addSubview:mLoadMoreImageView];
        [cell addSubview:mLoadMoreAIView];
        
        UILabel * loadMoreLabel = [[UILabel alloc] initWithFrame:CGRectMake(125, 14, 150, 17)];
        [loadMoreLabel setFont:[UIFont fontWithName:@"Arial" size:13]];
        [loadMoreLabel setTextColor:[UIColor grayColor]];
        [loadMoreLabel setText:@"上拉挖掘更多"];
        [loadMoreLabel setBackgroundColor:[UIColor clearColor]];
        [cell addSubview:loadMoreLabel];
        [loadMoreLabel release];
        
        UIButton * loadMoreButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [loadMoreButton setFrame:CGRectMake(80.f, 0.f, 160.f, 60.f)];
        [loadMoreButton setBackgroundColor:[UIColor clearColor]];
        [loadMoreButton addTarget:self action:(@selector(loadMoreData)) forControlEvents:UIControlEventTouchUpInside];
        [cell addSubview:loadMoreButton];
        
        return cell;
    }
    else {
        UITableViewCell * cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"pro_cell_status_other"];
        if (cell == nil){
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                           reuseIdentifier:@"pro_cell_status_other"] autorelease];
        }
        UILabel * emptyLabel = [[UILabel alloc] init];
        [emptyLabel setBackgroundColor:[UIColor clearColor]];
        [emptyLabel setText:@"什么也没有"];
        [cell addSubview:emptyLabel];
        [emptyLabel release];
        
        return cell;
    }
}
/**表格点击事件处理,查微博的详细信息**/
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    /*
    if (indexPath.row <= [mStatuses count] && indexPath.row > 0) {
        Status * status = [mStatuses objectAtIndex:indexPath.row - 1];
        //查看详细
        [self toStatusDetailViewByTable:status];
    }
     */
}

#pragma mark – 
#pragma mark - 列表下拉刷新Delegate, 下拉加载更多

/** UIScrollViewDelegate Methods **/
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{     
    if (!mIsLoadingData) {
        [mRefreshHeaderView egoRefreshScrollViewDidScroll:scrollView]; 
        //下拉加载更多
        if ([self ifCanLoadMore]) {
            if (scrollView.isDragging) {
                if(scrollView.contentOffset.y >=  scrollView.contentSize.height - scrollView.frame.size.height + 60) {        
                    if (scrollView.contentOffset.y >= scrollView.contentSize.height - scrollView.frame.size.height) {
                        [self loadMoreData]; 
                    }        
                }
            }
        }
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{ 
    if (!mIsLoadingData) {
        [mRefreshHeaderView egoRefreshScrollViewDidEndDragging:scrollView]; 
    }
} 

/** EGORefreshTableHeaderDelegate Methods **/ 
- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView*)view{
    [self refreshData]; 
}

- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView*)view{
    return mIsLoadingData; 
} 
- (NSDate*)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView*)view{
    return [NSDate date];     
} 


#pragma mark - 
#pragma mark - 事件处理 之  [回退，回到顶部，。。。]
/**回到头部**/
- (void)backToHead 
{
    [self tableviewScrollToTop:YES];
}
/**通过列表，查看微博的详细信息）**/
- (void)toStatusDetailViewByTable:(Status *)status
{
    /*
    StatusDetailViewController * statusDetailViewController = [[StatusDetailViewController alloc] init];
    statusDetailViewController.status = status;
    statusDetailViewController.oAuthEngine = mOauth;
    //statusDetailViewController.region = mRegion;
    [statusDetailViewController setHidesBottomBarWhenPushed:YES];
    [self.navigationController pushViewController:statusDetailViewController animated:NO];
    [statusDetailViewController release];
     */
}


-(void)unFollowIt
{
        
}

-(void)isFollow
{   
    if (isFollowClient == 0 || isFollowClient == 1) {
        [self followIt];
    }
    else if(isFollowClient == 3 || isFollowClient == 2) {
        [self unFollowIt];
    }
    else {
        //nothing to do;
    }
    
}

/**回退**/
-(void) back
{
    if (mIsAlert) {
        return;
    }
    if (mIsLoadingData) {
        [mWeiboClient cancel];
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}

/**显示大图片**/
-(void)showBigImage:(NSString *)imageUrl
{
    BigImageViewController * bigImageViewController = [[BigImageViewController alloc] initWithImageUrl:imageUrl];
    bigImageViewController.bigImgTarget = self;
    bigImageViewController.removeBigImageAction = @selector(removeBigImage);
    [self presentModalViewController:bigImageViewController animated:NO];
    [bigImageViewController release];
}
/**隐藏大图片**/
-(void)removeBigImage
{
    [self dismissModalViewControllerAnimated:YES];
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

@end
