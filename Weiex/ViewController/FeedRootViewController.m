//
//  FeedRootViewController.m
//  WeiTansuo
//
//  Created by hyq on 11/25/11.
//  Copyright (c) 2011 Invidel. All rights reserved.
//

#import "FeedRootViewController.h"


@implementation FeedRootViewController

#define STATUSDATA_MAX_PAGE 15

- (id)init
{

    self = [super init];
    if (self) {
        //设置tabBar标题，背景图
        self.title = @"赞列表";
        self.tabBarItem = [[[UITabBarItem alloc] initWithTitle:@"赞列表" 
                                                         image:[UIImage imageNamed:@"tab_icon_3_nor.png"]
                                                           tag:3] autorelease];
        mFeeds = [[NSMutableArray alloc] init];
        mQueryCondition = [[QueryCondition alloc] init]; //add by max      
        mWeiexClient= [[WeiexClient alloc] initWithDele:self];
        
    }
    return self;
}

- (void)dealloc
{
    [mQueryCondition release] ;
    [mWeiexClient release];
    [mFeeds release];
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UILabel * mytitle = [[UILabel alloc] initWithFrame:CGRectMake(130, 5, 60, 30)];
    [mytitle setText:@"赞列表"];
    mytitle.font = [UIFont fontWithName:@"TrebuchetMS-Bold" size:18];
    [mytitle setTextColor:[UIColor whiteColor]];
    [mytitle setBackgroundColor:[UIColor clearColor]];
    [mytitle setTextAlignment:UITextAlignmentCenter];
    [self.view addSubview:mytitle];
    [mytitle release];
    
    
    
    if (!mTableView) {
        CGRect tableframe = self.view.frame;
        tableframe.size.height -= 48.f + 44.f + 2.f;
        tableframe.size.width = 308.f;
        tableframe.origin.x = 6.f;
        tableframe.origin.y = 48.f + 2.f;
        mTableView = [[UITableView alloc] initWithFrame:tableframe
                                                  style:UITableViewStylePlain];
        mTableView.delegate = self;
        mTableView.dataSource = self; 
        [self.view addSubview:mTableView];
    }
    
    //设置头部下拉刷新
    if (!mRefreshHeaderView) { 
        mRefreshHeaderView = [[EGORefreshTableHeaderView alloc] 
                              initWithFrame:CGRectMake(0.0f, -94.0f - mTableView.bounds.size.height, mTableView.frame.size.width, self.view.bounds.size.height)]; 
        mRefreshHeaderView.delegate = self; 
        [mTableView addSubview:mRefreshHeaderView]; 
        [mRefreshHeaderView refreshLastUpdatedDate];
    } 
    
    if (!mLoadMoreAIView) {
        mLoadMoreAIView = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(100, 12, 19, 19)];
        mLoadMoreAIView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray; 
        [self.view addSubview:mLoadMoreAIView];
    }
    
    //加载框
    if (!mSoftNoticeViewLoad) {
        mSoftNoticeViewLoad = [[SoftNoticeView alloc] initWithFrame:CGRectMake(90, 130, 140, 140)];
        [mSoftNoticeViewLoad setMessage:@"新的喜欢..."];
        [mSoftNoticeViewLoad setActivityindicatorHidden:NO];
        [mSoftNoticeViewLoad setHidden:YES];
        [self.view addSubview:mSoftNoticeViewLoad];
    }
    
    /**-----------------开始加载数据--------------------**/
    mLoadingDataType = 1;
    [self addData];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    [mTableView release];
}

#pragma mark -
#pragma mark - 微博数据处理
/**刷新数据**/
- (void)addData
{
    [self initMQueryCondition];
    [self loadFeedsBegin];
} 

/**回到头部**/
- (void)backToHead 
{
    [self tableviewScrollToTop:YES];
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
    [self backToHead];
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
    [self initMQueryCondition];
    [self loadFeedsBegin]; 
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
    mQueryCondition.startpage++;
    [self loadFeedsBegin];
    
}
/**结束数据处理**/
- (void)endLoadData
{
    if (mLoadingDataType == 1) {
        [self endRefreshData];
    } 
    else if(mLoadingDataType == 2) {
        [self endLoadMoreData];
    }
    //更新微博数据，填充统计数 20111111
    //    int intTemp = 0;
    //    for (NSDictionary * item in mFeeds) {  
    //        Status * status = [mFeeds objectAtIndex:intTemp];  
    //        if(intTemp == 0){
    //            [mStatusIds stringByAppendingString:status.statusId];
    //        }else{
    //            [mStatusIds stringByAppendingString:@","];
    //            [mStatusIds stringByAppendingString:status.statusId];
    //        }
    //        intTemp++;
    //    }
//    [self loadStarViewDataBegin];
}
///**是否可以加载更多**/
- (BOOL)ifCanLoadMore
{
    return (mQueryCondition.startpage <= STATUSDATA_MAX_PAGE && [mFeeds count] > 0 && [mFeeds count] < mFeedCount); 
    
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
    float cellheight = 50.f;
    FeedCell * cell = [[FeedCell alloc]init];
    int totalCount = [mFeeds count];
    if (indexPath.row < totalCount) {
        cellheight = [cell getCellHeight];
    }else{
        cellheight = 50.f;
    }
    [cell release];
    return cellheight;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    int total = [mFeeds count];
    int count = 0;
    count = total;
    if ([self ifCanLoadMore]) 
        count ++ ;
    return count;
}
/**生成列表表格**/
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Feed_Status_Cell";
    
    int totalCount = [mFeeds count];    
    FeedCell * cell ;
    if (indexPath.row < totalCount) {
        cell = [[[FeedCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier] autorelease];
        FeedStruct * feed = [mFeeds objectAtIndex:indexPath.row];
        cell.userName.text = feed.userName;                        //用户名－－－无内容－－－告知max
        cell.userPicView.imageUrl = feed.userHeadUrl;
        [cell.userPicView getImageByUrl:1];                        //用户头像－－－无内容－－－告知max
        cell.middlePicView.imageUrl = feed.imgUrl;                 //大图
        [cell.middlePicView getImageByUrl:5];
        
        //text
        CGFloat constrainedSize = 265.0f; //其他大小也行
        UIFont * labelFont = [UIFont fontWithName:@"Arial" size:11]; // UILabel使用的字体
        CGSize textSize = [feed.location sizeWithFont: labelFont
                                    constrainedToSize:CGSizeMake(constrainedSize, CGFLOAT_MAX)
                                        lineBreakMode:UILineBreakModeWordWrap];
        UILabel * locationLabel = [[UILabel alloc] initWithFrame:CGRectMake (13, 7, textSize.width, textSize.height)];
        [locationLabel setFont:labelFont];
        locationLabel.textColor = [UIColor whiteColor];
        [locationLabel setBackgroundColor:[UIColor clearColor]];
        [locationLabel setText:feed.location];
        UIImageView * locationBg = [[UIImageView alloc]initWithFrame:CGRectMake(-3, 93,textSize.width + 3 +10, 27)];
        [locationBg setImage:[UIImage imageNamed:@"Location_bg2.png"]]; 
        [locationBg addSubview:locationLabel];
        UIImageView * locationBgArrow = [[UIImageView alloc]initWithFrame:CGRectMake(textSize.width + 9 , 93, 17, 27)];
        [locationBgArrow setImage:[UIImage imageNamed:@"Location_bg3.png"]]; 
        [cell addSubview:locationBg];
        [cell addSubview:locationBgArrow];        
        [locationLabel release];
        [locationBg release];
        [cell sizeToFit];
        return cell; 
    }else if(indexPath.row == totalCount){   
        
        UITableViewCell * cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"cell_loadmore"];
        if (cell == nil){
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                           reuseIdentifier:@"cell_loadmore"] autorelease];
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
        [loadMoreButton setFrame:CGRectMake(80.f, 0.f, 160.f, 25.f)];
        [loadMoreButton setBackgroundColor:[UIColor clearColor]];
        [loadMoreButton addTarget:self action:(@selector(loadMoreData)) forControlEvents:UIControlEventTouchUpInside];
        [cell addSubview:loadMoreButton];
        [cell sizeToFit];
        return cell;
    }
    else {
        UITableViewCell * cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"cell_status_other"];
        if (cell == nil){
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                           reuseIdentifier:@"cell_status_other"] autorelease];
        }
        return cell;
    }
} 
/**表格点击事件处理,查微博的详细信息**/
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{  
    [tableView deselectRowAtIndexPath:indexPath animated:NO];           
    if (indexPath.row < [mFeeds count]) {
        FeedStruct * feed = [mFeeds objectAtIndex:indexPath.row];
        //查看详细
        [self getStatusByFeed:feed.weiboId];
    }
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

//#pragma mark - 
//#pragma mark - 辅助功能函数
//
///**提示框**/
- (void)alert:(NSString *)message
{
    mIsLoadingData = YES;
    SoftNoticeView * msgBox = [[SoftNoticeView alloc] initWithFrame:CGRectMake(90, 130, 140, 140)];
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
    mIsLoadingData = NO;
}

/**隐藏大图片**/
-(void)removeBigImage
{
    [self dismissModalViewControllerAnimated:YES];
}

/**跳转到用户主页**/
-(void)toUserProfile:(id)sender
{
    FeedCell * fc = sender;
    NSString * userScreenName = fc.userName.text; 
    ProfileViewController * mProfile = [[ProfileViewController alloc] init];
    WeiboClient * wc = [[WeiboClient alloc]initWithTarget:self engine:[DataController getOAuthEngine] action:@selector(getCurUserFinished:json:)];
    [wc getUserByScreenName:userScreenName];
    mProfile.user = curUser;
    mProfile.oauth = [DataController getOAuthEngine];
    [self.navigationController pushViewController:mProfile animated:YES];
    [mProfile release];
}

- (void)getCurUserFinished:(WeiboClient *)sender
                    json:(NSDictionary*)json
{
    if (json != nil)
    {
         NSArray * items = (NSArray *)[(NSDictionary *)json objectForKey:@"resultvalue"];
    }
}
#pragma mark - 
#pragma mark - Weiex 接口处理方法 

/**初始化查询条件**/
- (void)initMQueryCondition
{
    mQueryCondition.startpage = 1;
    mQueryCondition.count = 30;
}


/**获取微博加星及点击查看数**/
- (void)loadFeedsBegin
{
    mWeiexClient= [[WeiexClient alloc] initWithTarget:self action:@selector(loadFeedFinished:json:)]; 
    
    [mWeiexClient getStarWeiboList:1 
                           pagenum:mQueryCondition.startpage 
                          pagesize:mQueryCondition.count];
}

- (void)loadFeedFinished:(WeiexClient *)sender
                    json:(NSDictionary*)json
{
    if (json != nil)
    {
        NSString * returnflag = [json valueForKey:@"resultflag"];
        if([returnflag isEqualToString:@"200"]){
            NSArray * items = (NSArray *)[(NSDictionary *)json objectForKey:@"resultvalue"];
            mFeedCount = [[(NSDictionary *)json objectForKey:@"resultnum"] longValue];//加星列表里面微薄数量
            NSMutableArray * feedTemp = [[NSMutableArray alloc]init];  
            int intTemp = 0;
            for (NSDictionary * item in items) { 
                FeedStruct * feedStruct = [[FeedStruct alloc] init];
                NSString * strWeiboId = [item objectForKey:@"clickWbid"];
                feedStruct.weiboId = [strWeiboId longLongValue];
                feedStruct.userName = [item objectForKey:@"clickOlusername"]; 
                feedStruct.userHeadUrl = [item objectForKey:@"clickOluserimage"]; 
                feedStruct.imgUrl =  [item objectForKey:@"clickWbthumbnailpic"]; //clickWbthumbnailpic clickBmiddlepic
                feedStruct.location = [item objectForKey:@"clickAddress"];  
                //因为返回的json中clickAddress都是空的，所以给一个默认值：paradise
                if (feedStruct.location.length == 0) {
                    feedStruct.location = @"Paradise";
                }
                [feedTemp addObject:feedStruct]; 
                [feedStruct release];
                intTemp++;
            }
            mFeeds = feedTemp;
            [DataController setFeeds:feedTemp];
        }else{
            mFeeds = [DataController getFeeds];        }
    }else{
        NSLog(@"API接口异常");       
    }
    [self endLoadData];
}
- (void)toStatusDetailViewByTable:(Status *)status
{
    OAuthEngine * mOAuthEngine = [DataController getOAuthEngine];
    MKCoordinateRegion mRegion = [DataController getDefaultRegion];
    StatusImageDetailViewController * statusDetailViewController = [[StatusImageDetailViewController alloc] init];
    statusDetailViewController.status = status;
    statusDetailViewController.oAuthEngine = mOAuthEngine;
    statusDetailViewController.region = mRegion;
    [statusDetailViewController setHidesBottomBarWhenPushed:YES];
    [self.navigationController pushViewController:statusDetailViewController animated:YES];
    [statusDetailViewController release];
}

- (void)getStatusByFeed:(long long)weiboId
{
    OAuthEngine * mOAuthEngine = [DataController getOAuthEngine];
    WeiboClient * mWeiboClient = [[WeiboClient alloc]initWithTarget:self engine:mOAuthEngine action:(@selector(getStatusfinished:obj:))];
    [mWeiboClient getStatus:weiboId];    
}

- (void)getStatusfinished:(WeiboClient*)sender obj:(NSObject*)obj {
    if (sender.hasError) {
        switch (sender.statusCode) {
            case 400:
                NSLog(@"fail in server");
                break;    
            default:
                NSLog(@"network fail");
                break;
        }
    }
    else {
        NSDictionary * dic = (NSDictionary *)obj;
        Status * sta = [Status statusWithJsonDictionary:dic];
        [self toStatusDetailViewByTable:sta];
    }
}

@end
