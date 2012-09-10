//
//  ProfileStatusViewController.m
//  WeiTansuo
//
//  Created by CMD on 9/20/11.
//  Copyright 2011 Invidel. All rights reserved.
//

#import "ProfileStatusViewController.h"

#define MAX_LONG_LONG_INT 9999999999999999
#define MAX_CELL_IMAGE_HEIGHT 80.f
#define CELL_CONTENT_WIDTH 320.0f
#define CELL_CONTENT_MARGIN 5.0f
#define STATUSDATA_MAX_PAGE 15
#define STATUSDATA_PAGE_SIZE 20
#define MAX_LOCATE_TIME 4

@implementation ProfileStatusViewController

@synthesize oAuthEngine = mOAuthEngine;
@synthesize statuses = mStatuses;
@synthesize user = mUser;
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

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)dealloc
{
    [mSoftNoticeViewLoad release];
    [mRefreshHeaderView release];
    [mLoadMoreImageView release];
    [mTableView release];
    [mUser release];
    [mStatuses release];
    [mQueryStatus release];
    [mOAuthEngine release];
    [mLoadMoreAIView release];
    [super dealloc];
}

#pragma mark - View lifecycle

// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
    [super loadView];
    
}



// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //背景色
    [self.view setBackgroundColor:[UIColor whiteColor]];
    //[self setBackBarItem:@selector(back)];
    //导航条
    UIButton * backToHeadButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [backToHeadButton setFrame:CGRectMake(35, 11, 250, 20)];
    [backToHeadButton setTitle:mUser.screenName forState:UIControlStateNormal];
    [backToHeadButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [backToHeadButton setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
    [backToHeadButton addTarget:self action:@selector(backToHead) forControlEvents:UIControlEventTouchDown];
    [self.navigationItem setTitleView:backToHeadButton]; 
    
    
    //设置列表视图
    if (!mTableView) {
        CGRect tableframe = self.view.frame;
        tableframe.size.height -= 44.f;
        tableframe.origin.y = 0.f;
        mTableView = [[UITableView alloc] initWithFrame:tableframe
                                                  style:UITableViewStylePlain];
        mTableView.delegate = self;
        mTableView.dataSource = self; 
        [self.view addSubview:mTableView];
    }
    
    //设置头部下拉刷新
    if (!mRefreshHeaderView) { 
        mRefreshHeaderView = [[EGORefreshTableHeaderView alloc] 
                              initWithFrame:CGRectMake(0.0f, -64.0f-mTableView.bounds.size.height, mTableView.frame.size.width, self.view.bounds.size.height)]; 
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
    
    /**-----------------开始加载数据--------------------**/
    [self refreshData];


}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

#pragma mark -
#pragma mark - 自定义初始化函数

- (void) initQueryStatus
{
    //微博总数
    mStatusCount = mUser.statusesCount;
    mQueryStatus.page = 1;
    mQueryStatus.count = STATUSDATA_PAGE_SIZE;
}

#pragma mark -
#pragma mark - 微博数据处理
/**开始获取数据**/
- (void)loadDataBegin
{
    WeiboClient *  weiboClient= [[WeiboClient alloc] initWithTarget:self 
                                                             engine:mOAuthEngine
                                                             action:@selector(loadDataFinished:obj:)];   
    
    [weiboClient getUserTimelineSinceID:mQueryStatus.sinceId 
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
        
        //克隆 用于显示的微博数据
        //[mDisplayStatuses removeAllObjects];
        //mDisplayStatuses = [mStatuses mutableCopy];
    }
    [self endLoadData];
    
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

- (void)initMStatusData
{
    [mStatuses removeAllObjects];
    //[mDisplayStatuses removeAllObjects];
    mCurrentStatueId = MAX_LONG_LONG_INT;
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
    //    [self mapViewBegin];
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
    if (mLoadingDataType == 1) {
        [self endRefreshData];
    } 
    else if(mLoadingDataType == 2) {
        [self endLoadMoreData];
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
    if (indexPath.row < [mStatuses count]) {
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
    if (mQueryStatus.page <= STATUSDATA_MAX_PAGE && count > 0 && count < mStatusCount) {
       count ++ ; 
    }
    return count;
}
/**生成列表表格**/
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"pro_cell";
    
    if (indexPath.row < [mStatuses count]) {
        StatusItemCellPro *cell = (StatusItemCellPro *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[[StatusItemCellPro alloc] initWithStyle:UITableViewCellStyleDefault
                                          reuseIdentifier:CellIdentifier] autorelease];
        }
        
        Status * status = [mStatuses objectAtIndex:indexPath.row];                                 //用户名
        cell.cellContentView.text = status.text;                            //内容
        cell.timeLabel.text = status.timestamp;                             //发表时间 
        cell.relativeLocation.text = status.relativeLocation;               //距离  
        cell.middlePicView.imageUrl = status.thumbnailPic;                  //大图
        [cell.middlePicView getImageByUrl:2];
        [cell sizeToFit];
        
        return cell;
    }
    else if(indexPath.row == [mStatuses count]){   
        
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
    if (indexPath.row < [mStatuses count]) {
        Status * status = [mStatuses objectAtIndex:indexPath.row];
        //查看详细
        [self toStatusDetailViewByTable:status];
    }
}

#pragma mark – 
#pragma mark - 列表下拉刷新Delegate, 下拉加载更多

/** UIScrollViewDelegate Methods **/
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{     
    if (!mIsLoadingData) {
        [mRefreshHeaderView egoRefreshScrollViewDidScroll:scrollView]; 
        //下拉加载更多
        if (scrollView.isDragging) {
            if(scrollView.contentOffset.y >=  scrollView.contentSize.height - scrollView.frame.size.height + 60) {        
                if (scrollView.contentOffset.y >= scrollView.contentSize.height - scrollView.frame.size.height) {
                    [self loadMoreData]; 
                }        
            }
        }
        
    }
    if(scrollView.contentOffset.y >=  scrollView.contentSize.height - scrollView.frame.size.height) {        
        if (scrollView.contentOffset.y >= scrollView.contentSize.height - scrollView.frame.size.height) {
            [self loadMoreData]; 
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
#pragma mark - 事件处理 之 [微博事件（查看详细,视图切换,视图刷新,筛选）]
/**回到头部**/
- (void)backToHead 
{
    [self tableviewScrollToTop:YES];
}
/**通过列表，查看微博的详细信息）**/
- (void)toStatusDetailViewByTable:(Status *)status
{
    StatusDetailViewController * statusDetailViewController = [[StatusDetailViewController alloc] init];
    statusDetailViewController.status = status;
    statusDetailViewController.oAuthEngine = mOAuthEngine;
    //statusDetailViewController.region = mRegion;
    [statusDetailViewController setHidesBottomBarWhenPushed:YES];
    [self.navigationController pushViewController:statusDetailViewController animated:NO];
    [statusDetailViewController release];
}


/**提示框**/
- (void)alert:(NSString *)message
{
    mIsLoadingData = YES;
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
    mIsLoadingData = NO;
}

/** refresh header method **/

- (void)egoRefreshScrollViewDataSourceDidFinishedLoading:(UIScrollView *)scrollView;
{
    
}


/**回退**/
-(void) back
{
    [self.navigationController popViewControllerAnimated:YES];
}

@end
