//
//  CommentToMeViewController.m
//  WeiTansuo
//
//  Created by CMD on 10/15/11.
//  Copyright 2011 Invidel. All rights reserved.
//

#import "UserMessageRootViewController.h"

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

@implementation UserMessageRootViewController

@synthesize user = mUser;
@synthesize oauth = mOauth;

@synthesize statuses = mStatuses;
@synthesize queryStatus = mQueryStatus;

- (id)init
{
    self = [super init];
    if (self) {
        self.title = @"我的消息";
        self.tabBarItem = [[[UITabBarItem alloc] initWithTitle:@"消息" 
                                                        image:[UIImage imageNamed:@"usermessage.png"]
                                                          tag:3] autorelease];
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
    
    UIButton * btn_tome = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn_tome.titleLabel setText:@"收到"];    
    [btn_tome addTarget:self action:(@selector(aaa)) forControlEvents:UIControlEventTouchUpInside];
    
    
    
    UIButton * btn_byme = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn_byme.titleLabel setText:@"发出"];
    [btn_byme addTarget:self action:(@selector(aaa)) forControlEvents:UIControlEventTouchUpInside];
    
    // segmented control as the custom title view
    /*
     
     NSArray *segmentTextContent = [NSArray arrayWithObjects:btn_tome, btn_byme, nil];
     UISegmentedControl *segmentedControl = [[UISegmentedControl alloc] initWithItems:segmentTextContent];
     segmentedControl.selectedSegmentIndex = 0;
     segmentedControl.autoresizingMask = UIViewAutoresizingFlexibleWidth;
     segmentedControl.segmentedControlStyle = UISegmentedControlStyleBar;
     //segmentedControl.frame = CGRectMake(0, 0, 400, kCustomButtonHeight);
     [segmentedControl addTarget:self action:@selector(segmentAction:) forControlEvents:UIControlEventValueChanged];
     
     //defaultTintColor = [segmentedControl.tintColor retain];	// keep track of this for later
     
     self.navigationItem.titleView = segmentedControl;
     [segmentedControl release];
     
     */
    
    //[self.view setBackgroundColor:[UIColor colorWithRed:245/255.f green:245/255.f blue:247/255.f alpha:1]];
    //导航栏
    
    //[self setBackBarItem:@selector(back)];
    
    //设置列表视图
    if (!mTableView) {
        CGRect tableframe = self.view.frame;
        tableframe.size.height -= 44.f + 44.f;
        tableframe.origin.y = 0;
        mTableView = [[UITableView alloc] initWithFrame:tableframe
                                                  style:UITableViewStylePlain];
        [mTableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
        mTableView.delegate = self;
        mTableView.dataSource = self; 
        [self.view addSubview:mTableView];
    }
    
    //设置头部下拉刷新
    if (!mRefreshHeaderView) { 
        mRefreshHeaderView = [[EGORefreshTableHeaderView alloc] 
                              initWithFrame:CGRectMake(0.0f, -88.f - mTableView.bounds.size.height, mTableView.frame.size.width, self.view.bounds.size.height)]; 
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
    if (!mFunctionSheet) {
        mFunctionSheet = [[UIActionSheet alloc] initWithTitle:@"" 
                                                      delegate:self 
                                             cancelButtonTitle:@"关闭" 
                                        destructiveButtonTitle:nil 
                                             otherButtonTitles:@"原用户",@"原微博", @"回复", nil];
        mFunctionSheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
        mFunctionSheet.alpha =0.8;
    }
    
    
    
    /**-----------------开始加载数据--------------------**/
    [self refreshData];
    //------------------------//
    //[mTableView reloadData];   
    //[self loadTagsCountBegin];
    
    //    [self friendshipsShow];
    
}



- (void)viewDidUnload
{    
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
    /*
     [mWeiboClient getUserTimelineSinceID:mQueryStatus.sinceId 
     UserID:mUser.userId 
     maxID:mQueryStatus.maxId 
     Count:mQueryStatus.count 
     Page:mQueryStatus.page 
     baseAPP:mQueryStatus.baseApp 
     Feature:mQueryStatus.feature];
     
     */
    
    [mWeiboClient commenttomeSinceId:0 Max_ID:0 Count:mQueryStatus.count Page:mQueryStatus.page Filter_by_author:0 Filter_by_source:0];
    
}
- (void)loadDataFinished:(WeiboClient *)sender
                     obj:(NSObject*)obj
{
    
    if (sender.hasError) {
        [self endLoadData];
        [self alert:@"网络异常"];
        //mIsAlert = YES;
    }
    else{
        //清理数据
        if (mLoadingDataType == 1) {
            [self initMStatusData];
        }
        //存储微博数据
        mCurrentPageStatueCount = 0;
        NSArray * ary = (NSArray *)obj;
        for (NSDictionary * dic in ary) {
            if (![dic isKindOfClass:[NSDictionary class]]) {
                continue;
            }
            Comment* sts = [Comment commentWithJsonDictionary:dic];
            if (sts.commentId >= mCurrentStatueId) {
                continue;
            }
            [mStatuses addObject:sts];
            mCurrentStatueId = sts.commentId;
            mCurrentPageStatueCount ++;
        }
        [self endLoadData];
        //mIsAlert = NO;
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
    if (mIsAlert) {
        return NO;
    } 
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
    return (mQueryStatus.page <= STATUSDATA_MAX_PAGE && [mStatuses count] > 0 && mCurrentPageStatueCount>0);
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
        StatusItemCellNotice * cell = (StatusItemCellNotice *)[self tableView:tableView cellForRowAtIndexPath:indexPath];
        return [cell getCellHeight];
    }
    else if (indexPath.row == [mStatuses count]) {
        return 45.f;
    }
    else {
        return 65.f;
    }
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    int count = [mStatuses count];
    if ([self ifCanLoadMore]) count ++;
    return count;
}
/**生成列表表格**/
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row < [mStatuses count]) {
        StatusItemCellNotice *cell = (StatusItemCellNotice *)[tableView dequeueReusableCellWithIdentifier:@"pro_cell_status"];
        if (cell == nil) {
            cell = [[[StatusItemCellNotice alloc] initWithStyle:UITableViewCellStyleDefault
                                             reuseIdentifier:@"pro_cell_status"] autorelease];
        }
        
        Comment * status = [mStatuses objectAtIndex:indexPath.row];      //用户名
        cell.userName.text = status.user.name;
        cell.contentLabel.text = status.text;
        cell.timeLabel.text = status.timestamp;        
        cell.userPicView.imageUrl = status.user.profileImageUrl;
        [cell.userPicView getImageByUrl:1];
        if (status.replyComment) {
            cell.oriContentLabel.text = status.replyComment.text;
            cell.oriContentUserLabel.text = status.replyComment.user.name;
        }
        else if(status.status) {
            cell.oriContentLabel.text = status.status.text;
            cell.oriContentUserLabel.text = status.status.user.name;
        }
        else {
            cell.oriContentLabel.text = @"";
            cell.oriContentUserLabel.text = @"";
        }

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
     if (indexPath.row < [mStatuses count]) {
         Comment * comment = [mStatuses objectAtIndex:indexPath.row];
         [self toFunctionActionSheetWithComment:comment];
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
                if(scrollView.contentOffset.y >=  scrollView.contentSize.height - scrollView.frame.size.height + 40) {        
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


- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
        case 0:
            [self goUserProfile];
            break;
        case 1:
            [self goOriWeibo];
            break;
        case 2:
            [self replyComment];
        default:
            break;
    }
}

/**通过列表，查看微博的详细信息）**/
- (void)toFunctionActionSheetWithComment:(Comment *)comment;
{
    mTempComment = comment;
    [mFunctionSheet showFromTabBar:self.tabBarController.tabBar];
}


- (void)goUserProfile
{
    if (mTempComment) {
        ProfileViewController * goprofile = [[ProfileViewController alloc] init];
        goprofile.user = mTempComment.user;
        goprofile.oauth = mOauth;
        [self.navigationController pushViewController:goprofile animated:YES];
        [goprofile release];
    }
}

- (void)goOriWeibo
{
    StatusDetailViewController * statusDetailViewController = [[StatusDetailViewController alloc] init];
    statusDetailViewController.status = mTempComment.status;
    statusDetailViewController.oAuthEngine = mOauth;
    //statusDetailViewController.region = mRegion;
    [statusDetailViewController setHidesBottomBarWhenPushed:YES];
    [self.navigationController pushViewController:statusDetailViewController animated:YES];
    [statusDetailViewController release];
}
- (void)replyComment
{
    if (mTempComment) {
        StatusCommentViewController * controller = [[StatusCommentViewController alloc] init];
        controller.status = mTempComment.status;
        controller.oAuthEngine = mOauth;
        controller.finishTarget = self;
        controller.finishAction = @selector(refreshCommentData);
        [self.navigationController pushViewController:controller animated:YES];
        [controller release];
        
    }
}


//////notices message
- (void)getUnreadCount
{
    
}

- (void)setCountByType
{
    
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
