//
//  ShenbianRootViewController.m
//  WeiTansuo
//
//  Created by chishaq on 11-8-19.
//  Copyright 2011年 Invidel. All rights reserved.
//

#import "ShenbianRootViewController.h"
#import "SBJsonParser.h"

#define MAX_LONG_LONG_INT 9999999999999999
#define MAX_CELL_IMAGE_HEIGHT 80.f
#define CELL_CONTENT_WIDTH 320.0f
#define CELL_CONTENT_MARGIN 5.0f
#define STATUSDATA_MAX_PAGE 15
#define STATUSDATA_PAGE_SIZE 50
#define MAX_LOCATE_TIME 4


@implementation ShenbianRootViewController

@synthesize oAuthEngine = mOAuthEngine;
@synthesize region = mRegion;
@synthesize queryCondition = mQueryCondition;
@synthesize statuses = mStatuses;


#pragma mark - 构造与析构

- (id)init
{
    self = [super init];
    if (self) {
        mOAuthEngine = [DataController getOAuthEngine];
        mQueryCondition = [[QueryCondition alloc] init];
        mQueryCondition.time = 0;                                           //无时间限制
        mQueryCondition.sorttype = 0;                                       //按时间排序
        mStatuses = [[NSMutableArray alloc] init];
        mCurrentLocation = [[WLocation alloc] init];
        mStatusIds = [[NSMutableString alloc ] initWithString:@""];   
        mIsFirstLoadData = YES;   
        mStyle = 2;
        hotPlaceExitFlag = 0;
        
        //设置tabBar标题，背景图
        self.title = @"身边";
        self.tabBarItem = [[[UITabBarItem alloc] initWithTitle:@"身边" 
                                                        image:[UIImage imageNamed:@"tab_icon_1_nor.png"]
                                                          tag:1] autorelease];
    }
    return self;
}

- (void)dealloc
{
    [mSoftNoticeViewLoad release];
    [mRefreshHeaderView release];
    [mLoadMoreImageView release];
    [mLocationInfoView release];
    [mTableView release];
    [mQueryAction release];
    [mCurrentLocation release];
    [mStatuses release];
    [mQueryCondition release];
    [mOAuthEngine release];
    [mLoadMoreAIView release];  
    [mStatusImgUrls release]; 
    [mStatusIds release];
    [super dealloc];
}

#pragma mark -
#pragma mark - 视图


- (void)loadView
{
    [super loadView];
}

/**页面加载完成，准备定位**/
- (void)viewDidLoad
{
    [super viewDidLoad];
    //头部工具条
    UIView * headToolBar = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
    [headToolBar setBackgroundColor:[UIColor clearColor]];
    [self.view addSubview:headToolBar];
    
    //定位工具条
    UIButton * locateButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [locateButton setFrame:CGRectMake(5, 7, 40, 30)];
    [locateButton setImage:[UIImage imageNamed:@"title_icon_1_nor.png"] forState:UIControlStateNormal];
    [locateButton setImage:[UIImage imageNamed:@"title_icon_1_press.png"] forState:UIControlStateHighlighted];
    [locateButton addTarget:self action:@selector(toPlacesSearchView) forControlEvents:UIControlEventTouchUpInside];    
    [headToolBar addSubview:locateButton];
    
    //加星工具条
    UIButton * starButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [starButton setFrame:CGRectMake(45, 7, 40, 30)];
    [starButton setImage:[UIImage imageNamed:@"title_icon_2_nor.png"] forState:UIControlStateNormal];
    [starButton setImage:[UIImage imageNamed:@"title_icon_2_press.png"] forState:UIControlStateHighlighted];
    [starButton addTarget:self action:@selector(hotPlaceAddStar) forControlEvents:UIControlEventTouchUpInside]; 
    [headToolBar addSubview:starButton];
    
    //头部中间标题
    UILabel * titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(85, 7, 150, 30)];
    titleLabel.textAlignment = UITextAlignmentCenter;
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.text = @"我的周边";
    titleLabel.font = [UIFont fontWithName:@"TrebuchetMS-Bold" size:20];
    titleLabel.textColor = [UIColor whiteColor];
    [headToolBar addSubview:titleLabel];
    [titleLabel release]; 
    
    //切换工具条 
    if (!mStyleControl) {
        mStyleControl = [UIButton buttonWithType:UIButtonTypeCustom];
        [mStyleControl setFrame:CGRectMake(275, 7, 40, 30)];
        [mStyleControl setImage:[UIImage imageNamed:@"title_icon_4_nor.png"] forState:UIControlStateNormal];
        [mStyleControl setImage:[UIImage imageNamed:@"title_icon_4_press.png"] forState:UIControlStateHighlighted];
        [mStyleControl addTarget:self action:@selector(changeListStyle:) forControlEvents:UIControlEventTouchUpInside]; 
        [headToolBar addSubview:mStyleControl];
    }
    
    [headToolBar release];
    
    //设置列表视图
    if (!mTableView) {
        CGRect tableframe = self.view.frame;
        tableframe.size.height -= 48.f + 44.f + 29.f;
        tableframe.size.width = 308.f;
        tableframe.origin.x = 6.f;
        tableframe.origin.y = 48.f+29.f;
        mTableView = [[UITableView alloc] initWithFrame:tableframe
                                                  style:UITableViewStylePlain];
        mTableView.delegate = self;
        mTableView.dataSource = self; 
        [mTableView setBackgroundColor:[UIColor clearColor]];
        [self.view addSubview:mTableView];
    }
    //人文地理信息展示条
    if (!mLocationInfoView) {
        UIImageView * bg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Location_bg.png"]];
        [bg setFrame:CGRectMake(4.f, 48.f, 312.f, 29.f)];
        [self.view addSubview:bg];
        [bg release];
        mLocationInfoView = [[UILabel alloc] initWithFrame:CGRectMake(10.f, 55.f, 300.f, 15.f)];
        mLocationInfoView.backgroundColor = [UIColor clearColor];
        mLocationInfoView.font = [UIFont fontWithName:@"Arial" size:12];
        mLocationInfoView.textColor = [UIColor whiteColor];
        mLocationInfoView.textAlignment = UITextAlignmentLeft;
        mLocationInfoView.text = @"";
        [self.view addSubview:mLocationInfoView];
    }
    
    //设置头部下拉刷新
    if (!mRefreshHeaderView) { 
        mRefreshHeaderView = [[EGORefreshTableHeaderView alloc] 
                              initWithFrame:CGRectMake(0, -120.0f - mTableView.bounds.size.height, mTableView.frame.size.width, self.view.bounds.size.height)]; 
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
        mSoftNoticeViewLoad = [[SoftNoticeView alloc] initWithFrame:CGRectMake(90, 100, 140, 140)];
        [mSoftNoticeViewLoad setMessage:@"附近的图片微博"];
        [mSoftNoticeViewLoad setActivityindicatorHidden:NO];
        [mSoftNoticeViewLoad setHidden:YES];
        [self.view addSubview:mSoftNoticeViewLoad];
    }
    //设置弹出框
    if (!mQueryAction) {
        mQueryAction = [[UIActionSheet alloc] initWithTitle:@"" delegate:self cancelButtonTitle:@"关闭" destructiveButtonTitle:nil otherButtonTitles:@"查看最新", @"查看最近", nil];
    }
    
    /**-----------------开始加载数据--------------------**/
    [self defaultLocate:YES];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    mSoftNoticeViewLoad = nil;
    [mSoftNoticeViewLoad release];
    mLoadMoreAIView = nil;
    [mLoadMoreAIView release];
    mLoadMoreImageView = nil;
    [mLoadMoreImageView release];
    mRefreshHeaderView = nil;
    [mRefreshHeaderView release];
    mLocationInfoView = nil;
    [mLocationInfoView release];
    mTableView = nil;
    [mTableView release];
    mQueryAction = nil;
    [mQueryAction release];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    if ([DataController getShenbianVCNeedRefreash]) {
        [DataController setShenbianVCNeedRefreash:NO];
        [self refreshData];
    }
}   

#pragma mark -
#pragma mark - 定位
/**第一次进入本页，默认定位**/
- (BOOL)beforeDefaultLocate
{
    if (mIsLoadingData) {
        return NO;
    }
    mIsLoadingData = YES;
    [mSoftNoticeViewLoad setHidden:NO];
    [mSoftNoticeViewLoad start];
    return YES;
}
- (void)endDefaultLocate
{
    [mSoftNoticeViewLoad stop];
    [mSoftNoticeViewLoad setHidden:YES];
    mIsLoadingData = NO;
    mLocationInfoView.text = [DataController getLocationDescription]; 
    [self refreshData];
}
- (void)defaultLocate:(BOOL)needLocate
{   
    
    if (![self beforeDefaultLocate]) {
        return;
    }
    if (needLocate) {
        CLLocationManager * locationManager = [[CLLocationManager alloc] init];
        locationManager.delegate = self;
        locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        [locationManager startUpdatingLocation];
    }
    else {
        CLLocation * cllocation = [[CLLocation alloc] initWithLatitude:[DataController getDefaultRegion].center.latitude 
                                                             longitude:[DataController getDefaultRegion].center.longitude];
        [self reverseGeocoderBegin:cllocation];
    }
}

/**定位成功**/
- (void)locationManager:(CLLocationManager *)manager
	didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation  
{
    [manager stopUpdatingLocation];
    [manager setDelegate:nil];

    mRegion.center.latitude = newLocation.coordinate.latitude;
    mRegion.center.longitude = newLocation.coordinate.longitude;
    [DataController setDefaultRegion:mRegion];
    [DataController setDefaultLatitude:newLocation.coordinate.latitude];
    [DataController setDefaultLongitude:newLocation.coordinate.longitude];
    //获取当前人文信息
    [self reverseGeocoderBegin:newLocation];
    

}
/**定位失败**/
- (void) locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    [manager stopUpdatingLocation];
    [manager setDelegate:nil];    
    
    [self alert:@"定位失败"];  
    [self endDefaultLocate];
}
/**人文信息**/
-(void)reverseGeocoderBegin:(CLLocation *)newLocation
{
    
    CLGeocoder * geocoder = [[CLGeocoder alloc] init];
    [geocoder reverseGeocodeLocation:newLocation 
                   completionHandler:^(NSArray *placemarks, NSError *error)
        {
            if ([placemarks count]>0) {
                CLPlacemark * placemark = [placemarks objectAtIndex:0];
                mCurrentLocation.title = placemark.locality;
                mCurrentLocation.subtitle = placemark.subLocality;
                mCurrentLocation.streetAddress = placemark.thoroughfare;
                mCurrentLocation.region = placemark.administrativeArea;
                mCurrentLocation.city = placemark.locality;
                mCurrentLocation.country = placemark.country;
                [mCurrentLocation format];
            
                [DataController setMinLocationDescription:[[NSString alloc] initWithFormat:@"%@",mCurrentLocation.streetAddress]];
                [DataController setLocationDescription:[[NSString alloc] initWithFormat:@"我在：%@ %@ %@",mCurrentLocation.title, mCurrentLocation.subtitle,mCurrentLocation.streetAddress]];
            }
            [self endDefaultLocate];
        }];
    [geocoder release];
    
}

#pragma mark -
#pragma mark - 自定义初始化函数
/**初始化toolbar按钮**/
- (void)initToolbarButtion
{

}
/**初始化地图中心**/
- (void)initMRegion
{
    mRegion = [DataController getDefaultRegion];    
    mCurrentLocation.latitude = mRegion.center.latitude;
    mCurrentLocation.longitude = mRegion.center.longitude; 
    mCurrentLocation.title = @"";
    mCurrentLocation.subtitle = @"";
    mCurrentLocation.streetAddress = @"";
    mCurrentLocation.region = @"";
    mCurrentLocation.city = @"";
    mCurrentLocation.country = @"";
}
/**初始化微博数据查询条件**/
- (void)initMQueryCondition
{
    mQueryCondition.range = [DataController getKLocateSelfDistence];
    mQueryCondition.longitude = [DataController getDefaultLongitude];
    mQueryCondition.latitude = [DataController getDefaultLatitude];
    mQueryCondition.startpage = 1;
    mQueryCondition.time = [DataController getTimeline];
    mQueryCondition.count = STATUSDATA_PAGE_SIZE;
    mQueryCondition.baseapp = 0;
    mQueryCondition.isImage = NO;                                       //不按图片筛选
}
/**初始化微博数据**/
- (void)initMStatusData
{
    [mStatuses removeAllObjects];
    mCurrentStatueId = MAX_LONG_LONG_INT;
    mStatusCount = 0;
}

#pragma mark -
#pragma mark - 微博数据处理
/**开始获取数据**/
- (void)loadDataBegin
{
    WeiboClient *  weiboClient= [[WeiboClient alloc] initWithTarget:self 
                                                   engine:mOAuthEngine
                                                   action:@selector(loadDataFinished:obj:)];   
    [weiboClient getLocationStatusesRange:mQueryCondition.range
                                longitude:mQueryCondition.longitude
                                 latitude:mQueryCondition.latitude
                                     time:mQueryCondition.time
                                 sortType:mQueryCondition.sorttype
                           startingAtPage:mQueryCondition.startpage
                                    count:mQueryCondition.count
                                  baseApp:mQueryCondition.baseapp];
}
- (void)loadDataFinished:(WeiboClient *)sender
                     obj:(NSObject*)obj
{
    
    if (sender.hasError) {
        [self endLoadData];
        [self alert:@"网络异常"];
    }
    else {
        StatusFilter * statusFilter = [[StatusFilter alloc] init]; 
        //清理数据
        if (mLoadingDataType == 1) {
            [self initMStatusData];
        }
        //存储微博数据
        mStatusCount = [[(NSDictionary *)obj objectForKey:@"total_number"] longValue];
        NSArray * ary = [(NSDictionary *)obj objectForKey:@"statuses"];
        for (NSDictionary * dic in ary) {
            if (![dic isKindOfClass:[NSDictionary class]]) {
                continue;
            }
            Status* sts = [Status statusWithJsonDictionary:dic MyRegion:mRegion];
            if (sts.statusId >= mCurrentStatueId) {
                continue;
            }
            if (![statusFilter shenbianStatusFilter:sts]) {
                continue;
            }
            [mStatuses addObject:sts];
            mCurrentStatueId = sts.statusId;

        }//end for loop

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
    [self backToHead];
    mLocationInfoView.text = @"正在获取附近的微博信息...";
    return YES;
}
-(void)endRefreshData
{
    [mRefreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:mTableView];
    mLocationInfoView.text =[DataController getLocationDescription];
    [mSoftNoticeViewLoad stop];
    [mSoftNoticeViewLoad setHidden:YES];
    [self tableViewBegin];
    mLoadingDataType = 0;
    mIsLoadingData = NO;
}
- (void)refreshData
{
    if (![self beforeRefreshData])  return;
    [self initToolbarButtion];
    [self initMRegion];
    [self initMQueryCondition];
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
    mQueryCondition.startpage++;
    [self loadDataBegin];

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
    //更新微博数据，填充统计数 
    int intTemp = 0;
    mStatusIds = [[NSMutableString alloc]initWithString:@""];
    for (NSDictionary * item in mStatuses) {  
        Status * status = [mStatuses objectAtIndex:intTemp]; 
        if(intTemp == 0){
            [mStatusIds appendString:[NSString stringWithFormat:@"%lld",status.statusId]];
        }else{
            [mStatusIds appendString:@","];
            [mStatusIds appendString:[NSString stringWithFormat:@"%lld",status.statusId]];
        }
        intTemp++;
    }
    [self loadStarViewDataBegin];
}
/**是否可以加载更多**/
- (BOOL)ifCanLoadMore
{
    return (mQueryCondition.startpage <= STATUSDATA_MAX_PAGE && [mStatuses count] > 0 && [mStatuses count] < mStatusCount);
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
    BasicCell * cell;
    float cellheight = 50.f;
    
    int totalCount = [mStatuses count];
    int picCellCount = (totalCount%3==0)?(totalCount/3):(totalCount/3+1);
    
    if(mStyle==3){//微博图片列表展示时   
        if (indexPath.row < picCellCount) {
            cell = (StatusItemCellPic *)[self tableView:tableView cellForRowAtIndexPath:indexPath];
            return [cell getCellHeight];
        }
        else {
            return cellheight;
        }        
    } else {//微博其他列表展示时
        if (indexPath.row < totalCount) {
            switch (mStyle) {
                case 1:
                    cell = (StatusItemLeftCell *)[self tableView:tableView cellForRowAtIndexPath:indexPath];
                    break;
                case 2:
                    cell = (StatusItemLeftCell *)[self tableView:tableView cellForRowAtIndexPath:indexPath];
                    break;
                default:
                    break;
            }
            return [cell getCellHeight];
        }
        else {
            return cellheight;
        }        
    }
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    int total = [mStatuses count];
    int count = 0;
    switch (mStyle) {
        case 1:
            break;
        case 2:
            count = total;
            if ([self ifCanLoadMore]) 
                count ++ ;
            break;
        case 3:
            if(total%3==0){
                count = total/3;
            }else{
                count = total/3+1;
            }
            if ([self ifCanLoadMore]) 
                count ++ ;
            break;
        default:
            break;
    }
    return count;
}
/**生成列表表格**/
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Shenbian_Status_Cell";
    int bigImageType = 1;
    
    int totalCount = [mStatuses count];
    int picCellCount = (totalCount%3==0)?(totalCount/3):(totalCount/3+1);

    if(mStyle==3){//微博图片列表展示时    
        BasicCell * cell ;
        if (indexPath.row < picCellCount) {
            cell = [[[StatusItemCellPic alloc] initWithStyle:UITableViewCellStyleValue1
                                             reuseIdentifier:CellIdentifier] autorelease];
            bigImageType = 6;     //改成类型6，用以缩小图片    
            int intTemp = indexPath.row * 3;
            //cell中第一张图片
            Status * statusOne = [mStatuses objectAtIndex:intTemp];       
            [cell.statusImgOne setImageUrl:statusOne.thumbnailPic];
            [cell.statusImgOne getImageByUrl:4];
            UIButton * imageButtonOne = [[UIButton alloc] initWithFrame:cell.statusImgOne.frame];
            [imageButtonOne setTag:intTemp];
            [imageButtonOne addTarget:self action:(@selector(picToStatusDetailViewByTable:)) forControlEvents:(UIControlEventTouchUpInside)];
            [cell addSubview:imageButtonOne];
            //cell中第二张图片
            if((intTemp+1)<[mStatuses count]){
                Status * statusTwo = [mStatuses objectAtIndex:intTemp+1];         
                [cell.statusImgTwo setImageUrl:statusTwo.thumbnailPic];
                [cell.statusImgTwo getImageByUrl:4];
                UIButton * imageButtonTwo = [[UIButton alloc] initWithFrame:cell.statusImgTwo.frame]; 
                [imageButtonTwo setTag:intTemp+1];
                [imageButtonTwo addTarget:self action:@selector(picToStatusDetailViewByTable:) forControlEvents:(UIControlEventTouchUpInside)];
                [cell addSubview:imageButtonTwo];
            }
            //cell中第三张图片
            if((intTemp+2)<[mStatuses count]){        
                Status * statusThree = [mStatuses objectAtIndex:intTemp+2]; 
                [cell.statusImgThree setImageUrl:statusThree.thumbnailPic];
                [cell.statusImgThree getImageByUrl:4];
                UIButton * imageButtonThree = [[UIButton alloc] initWithFrame:cell.statusImgThree.frame];    
                [imageButtonThree setTag:intTemp+2];
                [imageButtonThree addTarget:self action:@selector(picToStatusDetailViewByTable:) forControlEvents:(UIControlEventTouchUpInside)];
                [cell  addSubview:imageButtonThree];
            }
            [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
            [cell sizeToFit];
            
            return cell; 
        } else if(indexPath.row == picCellCount){               
            UITableViewCell * cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"cell_loadmore_style3"];
            if (cell == nil){
                cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                               reuseIdentifier:@"cell_loadmore_style3"] autorelease];
            }
            [cell addSubview:mLoadMoreImageView];
            [cell addSubview:mLoadMoreAIView];
            
            UILabel * loadMoreLabel = [[UILabel alloc] initWithFrame:CGRectMake(135, 14, 150, 17)];
            [loadMoreLabel setFont:[UIFont fontWithName:@"Arial" size:13]];
            [loadMoreLabel setTextColor:[UIColor grayColor]];
            [loadMoreLabel setBackgroundColor:[UIColor clearColor]];
            [loadMoreLabel setText:@"上拉挖掘更多"];
            [loadMoreLabel setBackgroundColor:[UIColor clearColor]];
            [cell addSubview:loadMoreLabel];
            [loadMoreLabel release];
            
            UIButton * loadMoreButton = [UIButton buttonWithType:UIButtonTypeCustom];
            [loadMoreButton setFrame:CGRectMake(90, 0, 160, 60)];
            [loadMoreButton setBackgroundColor:[UIColor clearColor]];
            [loadMoreButton addTarget:self action:(@selector(loadMoreData)) forControlEvents:UIControlEventTouchUpInside];
            [cell addSubview:loadMoreButton];
            
            return cell;
        } else {
            UITableViewCell * cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"cell_status_other_style3"];
            if (cell == nil){
                cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                               reuseIdentifier:@"cell_status_other_style3"] autorelease];
            }
            return cell;
        }
    } else {//微博其他列表展示时   mStyle 为1 2时
        BasicCell * cell ;
        if (indexPath.row < totalCount) {
            switch (mStyle) {
                case 1:
                    cell = [[[StatusItemCell alloc] initWithStyle:UITableViewCellStyleValue1
                                                  reuseIdentifier:CellIdentifier] autorelease];
                    bigImageType = 2;
                    break;
                case 2:
                    cell = [[[StatusItemLeftCell alloc] initWithStyle:UITableViewCellStyleValue1
                                                      reuseIdentifier:CellIdentifier] autorelease];
                    bigImageType = 5;//左边的图片
                    break;
                default:
                    cell = [[[BasicCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier] autorelease];
                    break;
            } 
            Status * status = [mStatuses objectAtIndex:indexPath.row];
            cell.userName.text = status.user.screenName;                        //用户名
            cell.cellContentView.text = status.text;                            //内容
            cell.timeLabel.text = status.timestamp;                             //发表时间 
            cell.relativeLocation.text = status.relativeLocation;               //距离
            cell.userPicView.imageUrl = status.user.profileImageUrl;            //用户头像
            cell.bmiddlePicUrl = status.bmiddlePic;                             //大图（原图）url
            cell.bigImgTarget = self;                                           //弹出大图对象
            cell.showBigImgAction = @selector(showBigImage:);                   //弹出大图方法
            [cell.userPicView getImageByUrl:1];      
            if (mStyle == 2){
                cell.middlePicView.imageUrl = status.thumbnailPic;
            }
            else{
                cell.middlePicView.imageUrl = status.thumbnailPic;
            }
           
            [cell.middlePicView getImageByUrl:bigImageType];
            
            cell.starAmount.text = [NSString stringWithFormat:@"%lld",status.starAmount];
//            cell.viewAmount.text = [NSString stringWithFormat:@"%lld",status.viewAmount];
            
            [cell sizeToFit];
            return cell; 
        } else if(indexPath.row == totalCount){   
            
            UITableViewCell * cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"cell_loadmore_style2"];
            if (cell == nil){
                cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                               reuseIdentifier:@"cell_loadmore_style2"] autorelease];
            }
            [cell addSubview:mLoadMoreImageView];
            [cell addSubview:mLoadMoreAIView];
            
            UILabel * loadMoreLabel = [[UILabel alloc] initWithFrame:CGRectMake(125, 14, 150, 17)];
            [loadMoreLabel setFont:[UIFont fontWithName:@"Arial" size:13]];
            [loadMoreLabel setTextColor:[UIColor grayColor]];
            [loadMoreLabel setBackgroundColor:[UIColor clearColor]];
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
            UITableViewCell * cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"cell_status_other_style2"];
            if (cell == nil){
                cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                               reuseIdentifier:@"cell_status_other_style2"] autorelease];
            }
            return cell;
        }
    }
}

/**表格点击事件处理,查微博的详细信息**/
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{  
    [tableView deselectRowAtIndexPath:indexPath animated:NO]; 
    if (indexPath.row < [mStatuses count]) {
        Status * status = [mStatuses objectAtIndex:indexPath.row];
        //查看详细
        [self toStatusDetailViewByTable:status updateIndex:indexPath.row optflag:1];
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

#pragma mark - 
#pragma mark - 事件处理 之 [微博事件（查看详细,视图切换,视图刷新,筛选,搜索）]

/**地点搜素页**/
- (void)toPlacesSearchView
{
    PlacesSearchViewController * placesSearchViewController = [[PlacesSearchViewController alloc] init];
    placesSearchViewController.finishTarget = self;
    placesSearchViewController.finishAction = @selector(backFromPlacesSearchView:);
    [placesSearchViewController setHidesBottomBarWhenPushed:YES];
    [self.navigationController pushViewController:placesSearchViewController animated:YES];     
    [placesSearchViewController release];
}
- (void)backFromPlacesSearchView:(NSString *)setType
{
    if (setType == @"near") {//最近
        [mQueryCondition setSorttype:0];
        [self refreshData];
    }
    else if (setType == @"last") {//最新
        [mQueryCondition setSorttype:1];
        [self refreshData];
    }
    else if (setType == @"location") {//定位
        //[self defaultLocate:YES];
        [self refreshData];
    }
    else if (setType == @"range") {//范围
        [mQueryCondition setRange:[DataController getKLocateSelfDistence]];
        [self refreshData];
    }
}
/**回到头部**/
- (void)backToHead 
{
    [self tableviewScrollToTop:YES];
}
/**通过列表，查看微博的详细信息）**/
- (void)picToStatusDetailViewByTable:(id)sender 
{
    UIButton * picButton = (UIButton *)sender;
    int btnTag = picButton.tag;
    Status * status = [mStatuses objectAtIndex:btnTag];
    [self toStatusDetailViewByTable:status updateIndex:btnTag optflag:2];
}

- (void)toStatusDetailViewByTable:(Status *)status updateIndex:(NSInteger)index optflag:(int)flag
{
    StatusImageDetailViewController * statusDetailViewController = [[StatusImageDetailViewController alloc] init];
    statusDetailViewController.status = status;
    statusDetailViewController.oAuthEngine = mOAuthEngine;
    statusDetailViewController.region = mRegion;
    statusDetailViewController.goAnywhereButtonIsShow = NO;
    statusDetailViewController.updateWeiboIndex = index;
    statusDetailViewController.finishTarget = self;
    switch (flag) {
        case 1:
            statusDetailViewController.finishAction = @selector(ToStatusImageDetailViewDidStaredFromOne:);
            break;
        case 2:
            statusDetailViewController.finishAction = @selector(ToStatusImageDetailViewDidStaredFromTwo:);
            break;
    }
    [statusDetailViewController setHidesBottomBarWhenPushed:YES];
    [self.navigationController pushViewController:statusDetailViewController animated:YES];
    [statusDetailViewController release];
    //保存点击事件 add by max
//    [self saveWeiboClick:status
//            onlineuserid:(long)mOAuthEngine.username
//          onlineusername:[DataController getUserScreenName]
//         onlineuserimage:((User *)[DataController getUser]).profileImageUrl   
//             nowlatitude:[DataController getDefaultLatitude] 
//             nowlongtude:[DataController getDefaultLongitude]
//              nowaddress:[[NSString alloc] initWithFormat:@"%@",[DataController getMinLocationDescription]]];
}

/**微博详细页回调操作微博列表**/
- (void)ToStatusImageDetailViewDidStaredFromOne:(NSArray * )paramArray
{
    NSArray * indexArray = paramArray;
    NSString  * updateFlag  = [indexArray objectAtIndex:0];
    NSString  * updateIndex = [indexArray objectAtIndex:1];
    Status   * status = [mStatuses objectAtIndex:updateIndex.intValue]; 

    [mTableView beginUpdates];    
    NSIndexPath * indexPath = [NSIndexPath indexPathForRow:updateIndex.intValue inSection:0];
    StatusItemLeftCell * wantedCell = (StatusItemLeftCell *)[mTableView cellForRowAtIndexPath:indexPath];
    if (updateFlag == @"yes") {
        long long staramountTemp = wantedCell.starAmount.text.longLongValue;
        staramountTemp = staramountTemp + 1;
        wantedCell.starAmount.text = [NSString stringWithFormat:@"%lld",staramountTemp];
        status.starAmount = staramountTemp;
    }
//    long long viewamountTemp = wantedCell.viewAmount.text.longLongValue;
//    viewamountTemp = viewamountTemp + 1;
//    wantedCell.viewAmount.text = [NSString stringWithFormat:@"%lld",viewamountTemp];
//    status.viewAmount = viewamountTemp;    
//    
    [mStatuses replaceObjectAtIndex:updateIndex.intValue withObject:status];
    [mTableView endUpdates];
}

- (void)ToStatusImageDetailViewDidStaredFromTwo:(NSArray * )paramArray
{
    NSArray * indexArray = paramArray;
    NSString  * updateFlag  = [indexArray objectAtIndex:0];
    NSString  * updateIndex = [indexArray objectAtIndex:1];
    Status    * status = [mStatuses objectAtIndex:updateIndex.intValue]; 

    if (updateFlag == @"yes") {
        long long staramountTemp = status.starAmount;
        staramountTemp = staramountTemp + 1;
        status.starAmount = staramountTemp;
    }
    long long viewamountTemp = status.viewAmount;
    viewamountTemp = viewamountTemp + 1;
    status.viewAmount = viewamountTemp;        
    [mStatuses replaceObjectAtIndex:updateIndex.intValue withObject:status];
}

/**通过地图，查看微博的详细信息**/
- (void)toStatusDetailViewByMap:(id)sender 
{    
    UIButton * detailButton = sender;
    int index = detailButton.tag;
    StatusDetailViewController * statusDetailViewController = [[StatusDetailViewController alloc] init];
    statusDetailViewController.status = [mStatuses objectAtIndex:index];
    statusDetailViewController.oAuthEngine = mOAuthEngine;
    statusDetailViewController.region = mRegion;
    [statusDetailViewController setHidesBottomBarWhenPushed:YES];
    [self.navigationController pushViewController:statusDetailViewController animated:YES];
    [statusDetailViewController release];
    
}

/**筛选数据为[所有]**/
- (void)filterDataToAll
{
    mQueryCondition.isImage = NO;
    [mTableView addSubview:mRefreshHeaderView]; 
    [self tableViewBegin];
}
/**筛选数据为［图片］**/
- (void)filterDataToImage
{
    mQueryCondition.isImage = YES;
    [mRefreshHeaderView removeFromSuperview];
    for (Status * sts in mStatuses){
        if ([sts.thumbnailPic length]<=5) {
            continue;
        }
    }
    [self tableViewBegin];
}

/**修改列表展示形式**/
- (void) changeListStyle: (id)sender{
    switch (mStyle) {
        case 2:
            mStyle = 3;
            [mStyleControl setImage:[UIImage imageNamed:@"title_icon_3_nor.png"] forState:UIControlStateNormal];
            [mStyleControl setImage:[UIImage imageNamed:@"title_icon_3_press.png"] forState:UIControlStateHighlighted];
            [self tableViewBegin];
            break;
            
        case 3:
            mStyle = 2;
            [mStyleControl setImage:[UIImage imageNamed:@"title_icon_4_nor.png"] forState:UIControlStateNormal];
            [mStyleControl setImage:[UIImage imageNamed:@"title_icon_4_press.png"] forState:UIControlStateHighlighted];
            [self tableViewBegin];
            break;
        default:
            break;
    }
}
/**热点加星页**/ //add by max 20111130
-(void)hotPlaceAddStar
{
    [self loadFirstStarFlagBegin];
}
//跳转到热点地区列表页
-(void)toHotPlacesView
{
//    hotPlaceExitFlag=0;
//    SortRootViewController * sortRootViewController = [[SortRootViewController alloc] init];
//    //执行热点地区普通加星操作
//    sortRootViewController.optFlag    = 2;
//    sortRootViewController.starHotplaceid = hotPlaceId;
//    sortRootViewController.isPushOrShow = 1;
//    [self.navigationController pushViewController:sortRootViewController animated:YES];
//    [sortRootViewController release];
    [self saveHotplaceClick:hotPlaceId
               onlineuserid:(long)([DataController getOAuthEngine].username)
             onlineusername:[DataController getUserScreenName]
            onlineuserimage:((User *)[DataController getUser]).profileImageUrl            
                nowlatitude:[DataController getDefaultLatitude] 
                nowlongtude:[DataController getDefaultLongitude]
                 nowaddress:[[NSString alloc] initWithFormat:@"%@",[DataController getMinLocationDescription]]];
    [self alert:@"热点热度加1"];
    
}
//跳转到热点加星页－－－－直接添加
-(void)toAddStarView
{
//    hotPlaceExitFlag=0;
//    HotPlaceStarViewController * hotPlaceStarViewController = [[HotPlaceStarViewController alloc] init];
//    //参数传递
//    hotPlaceStarViewController.nowRegion = [[NSString alloc] initWithFormat:@"%@",[DataController getMinLocationDescription]];
//    hotPlaceStarViewController.regionLat = [DataController getDefaultLatitude];
//    hotPlaceStarViewController.regionLng = [DataController getDefaultLongitude];
//    hotPlaceStarViewController.regionProvince = @"";
//    //执行热点地区特殊加星操作
//    [hotPlaceStarViewController setHidesBottomBarWhenPushed:YES];   
//    [self.navigationController pushViewController:hotPlaceStarViewController animated:YES];
//    [hotPlaceStarViewController release];     


//  存入
    [self  saveStarHotplace:-1
                description:@""
               onlineuserid:(long)([DataController getOAuthEngine].username)
             onlineusername:[DataController getUserScreenName]
            onlineuserimage:((User *)[DataController getUser]).profileImageUrl            
                nowlatitude:[DataController getDefaultLatitude] 
                nowlongtude:[DataController getDefaultLongitude]
                 nowaddress:[[NSString alloc] initWithFormat:@"%@",[DataController getMinLocationDescription]]
                nowprovince:@""]; 
    [self alert:@"热点保存成功"];

}
#pragma mark - 
#pragma mark - 设置部分

- (void) toQuerySheetAction
{
    mQueryAction.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
    mQueryAction.alpha =0.8;
    [mQueryAction showFromTabBar:self.tabBarController.tabBar];
}



- (void)actionSheet:(UIActionSheet *)modalView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex)
    {
        case 0:
            [mQueryCondition setSorttype:0];
            [self refreshData];
            break;
        case 1:
            [mQueryCondition setSorttype:1];
            [self refreshData];
            break;
    }
}

#pragma mark - 
#pragma mark - 辅助功能函数

/**提示框**/
- (void)alert:(NSString *)message
{
    mIsLoadingData = YES;
    SoftNoticeView * msgBox = [[SoftNoticeView alloc] initWithFrame:CGRectMake(90, 100, 140, 140)];
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
/**点击显示大图片**/
-(void)showBigImage:(NSString *)imageUrl
{
    BigImageViewController * bigImageViewController = [[BigImageViewController alloc] initWithImageUrl:imageUrl];
    bigImageViewController.bigImgTarget = self;
    bigImageViewController.removeBigImageAction = @selector(removeBigImage);
    [self presentModalViewController:bigImageViewController animated:YES];
    [bigImageViewController release];
}
/**隐藏大图片**/
-(void)removeBigImage
{
    [self dismissModalViewControllerAnimated:YES];
}

#pragma mark - 
#pragma mark - Weiex 接口处理方法 

/**记录微博点击事件**/
- (void)saveWeiboClick:(Status *) status 
          onlineuserid:(long)userid  
        onlineusername:(NSString *)username
       onlineuserimage:(NSString *)userimage   
           nowlatitude:(double)geolat 
           nowlongtude:(double)geolng 
            nowaddress:(NSString *)address
{
    WeiexClient * mWeiexClient= [[WeiexClient alloc] initWithDele:self];
    [mWeiexClient saveClickNum:1 
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

/**记录热点地区加星事件**/
-(void)saveStarHotplace:(int)placetype
            description:(NSString *)description
           onlineuserid:(long long)oluserid
         onlineusername:(NSString *)username
        onlineuserimage:(NSString *)userimageurl
            nowlatitude:(double)lat
            nowlongtude:(double)lng
             nowaddress:(NSString *)address
            nowprovince:(NSString *)province
{
    WeiexClient * mWeiexClient= [[WeiexClient alloc] initWithDele:self];
    [mWeiexClient starHotplace:5
                  hotplacetype:1
                   description:description 
                  onlineuserid:oluserid
                onlineusername:username
               onlineuserimage:userimageurl
                   nowlatitude:lat 
                   nowlongtude:lng 
                    nowaddress:address 
                   nowprovince:province];  
}

/**记录热点地区点击事件**/
- (void)saveHotplaceClick:(long long) hotplaceid 
             onlineuserid:(long)userid  
           onlineusername:(NSString *)username
          onlineuserimage:(NSString *)userimageurl 
              nowlatitude:(double)geolat 
              nowlongtude:(double)geolng 
               nowaddress:(NSString *)address
{
    WeiexClient * mWeiexClient= [[WeiexClient alloc] initWithDele:self];
    [mWeiexClient saveClickNum:4 
                   weibostatus:nil 
                   weibouserid:-1 
                    hotplaceid:hotplaceid
                  onlineuserid:userid 
                onlineusername:username
               onlineuserimage:userimageurl
                   nowlatitude:geolat 
                   nowlongtude:geolng 
                    nowaddress:address];
}


/**获取微博加星及点击查看数**/
- (void)loadStarViewDataBegin
{
    WeiexClient * mWeiexClient= [[WeiexClient alloc] initWithTarget:self action:@selector(loadStarViewDataFinished:json:)]; 
    [mWeiexClient getStarAndViewAmountList:1 
                               clickStrIds:mStatusIds];

}
- (void)loadStarViewDataFinished:(WeiexClient *)sender
                            json:(NSDictionary*)json{
    if (json != nil)
    {
        NSString * returnflag = [json valueForKey:@"resultflag"];
        if([returnflag isEqualToString:@"200"]){
            NSArray * items = (NSArray *)[(NSDictionary *)json objectForKey:@"resultvalue"];
            NSMutableArray * statusTemp = [[NSMutableArray alloc]init];  
            int intTemp = 0;
            for (NSDictionary * item in items) {  
                Status * status = [mStatuses objectAtIndex:intTemp];                  
                NSString * strStarAmount = [item objectForKey:@"starAmount"];
                status.starAmount = [strStarAmount longLongValue];
                NSString * strViewAmount = [item objectForKey:@"viewAmount"];
                status.viewAmount = [strViewAmount longLongValue];
                [statusTemp addObject:status];
                intTemp++;
            }
            mStatuses = statusTemp;
        }else{
            NSMutableArray * statusTemp = [[NSMutableArray alloc]init];  
            int intTemp = 0;
            for (NSDictionary * item in mStatuses) {  
                Status * status = [mStatuses objectAtIndex:intTemp];                  
                status.starAmount = 0;
                status.viewAmount = 0;
                [statusTemp addObject:status];
                intTemp++;
            }
            mStatuses = statusTemp;            
        }
    } 
}
/**获取是否首次对热点地区进行加星操作标识**/
- (void)loadFirstStarFlagBegin
{
    WeiexClient *mWeiexClient= [[WeiexClient alloc] initWithTarget:self action:@selector(loadFirstStarFlagFinished:json:)]; 
    [mWeiexClient getIfFirstStarFlag:[[NSString alloc] initWithFormat:@"%@",[DataController getMinLocationDescription]]];
    
}
- (void)loadFirstStarFlagFinished:(WeiexClient *)sender
                            json:(NSDictionary*)json
{
    if (json != nil)
    {
        NSString * returnflag = [json valueForKey:@"resultflag"];
        if([returnflag isEqualToString:@"200"]){
            NSArray * items = (NSArray *)[(NSDictionary *)json objectForKey:@"resultvalue"]; 
            for (NSDictionary * item in items) {                
                NSString * strFlag = [item objectForKey:@"ifExistFlag"];
                hotPlaceExitFlag = [strFlag intValue];
                NSString * strHotPlaceId = [item objectForKey:@"hotPlaceId"];
                hotPlaceId       = [strHotPlaceId intValue];
            }
            if(hotPlaceExitFlag==0){//热点地区不存在
                [self toAddStarView];//change by hyq
            }else{//热点地区存在
                [self toHotPlacesView];//change by hyq
            }
        }else{
            [self alert:@"网络异常"];
        }
    } 
}

@end
