//
//  ShenbianRootViewController.m
//  WeiTansuo
//
//  Created by chishaq on 11-8-19.
//  Copyright 2011年 Invidel. All rights reserved.
//

#import "ShenbianPicViewController.h"
#import "SBJsonParser.h"

#define MAX_LONG_LONG_INT 9999999999999999
#define MAX_CELL_IMAGE_HEIGHT 80.f
#define CELL_CONTENT_WIDTH 320.0f
#define CELL_CONTENT_MARGIN 5.0f
#define STATUSDATA_MAX_PAGE 15
#define STATUSDATA_PAGE_SIZE 50
#define MAX_LOCATE_TIME 4


@implementation ShenbianPicViewController

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
        mIsFirstLoadData = YES;    
        
        //设置tabBar标题，背景图
        self.title = @"身边";
        self.tabBarItem = [[[UITabBarItem alloc] initWithTitle:@"身边" 
                                                         image:[UIImage imageNamed:@"aroundme.png"]
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
    [mMapView release];
    [mQueryAction release];
    [mCurrentLocation release];
    [mStatuses release];
    [mQueryCondition release];
    [mOAuthEngine release];
    [mLoadMoreAIView release];
    [mWeiexClient release];   //add by max
    [mStatusImgUrls release]; //add by max
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
    //背景色
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    //导航条
    UIButton * backToHeadButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [backToHeadButton setFrame:CGRectMake(65, 11, 220, 20)];
    [backToHeadButton setTitle:[DataController getUserScreenName] forState:UIControlStateNormal];
    [backToHeadButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [backToHeadButton setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
    [backToHeadButton addTarget:self action:@selector(backToHead) forControlEvents:UIControlEventTouchDown];
    [self.navigationItem setTitleView:backToHeadButton];
    
    //定位工具条
    UIButton * locateButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [locateButton setBounds:CGRectMake(0, 0, 50, 30)];
    [locateButton setImage:[UIImage imageNamed:@"placeBG.png"] forState:UIControlStateNormal];
    [locateButton setImage:[UIImage imageNamed:@"placeBGPr.png"] forState:UIControlStateHighlighted];
    [locateButton addTarget:self action:@selector(toPlacesSearchView) forControlEvents:UIControlEventTouchUpInside];    
    UIBarButtonItem * locateBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:locateButton];
    self.navigationItem.rightBarButtonItem = locateBarButtonItem;
    [locateBarButtonItem release];
    
    //设置地图视图
    if (!mMapView) {
        CGRect mapFrame = self.view.frame;
        mapFrame.size.height -= 44.f + 44.f + 20.f;
        mapFrame.origin.y = 20.f;
        mMapView = [[MKMapView alloc] initWithFrame:mapFrame];
        mMapView.centerCoordinate = mRegion.center;
        mMapView.delegate = self;
        mMapView.showsUserLocation = NO;
        [self.view addSubview:mMapView];
    }
    
    //设置列表视图
    if (!mTableView) {
        CGRect tableframe = self.view.frame;
        tableframe.size.height -= 44.f + 44.f + 20.f;
        tableframe.origin.y = 20.f;
        mTableView = [[UITableView alloc] initWithFrame:tableframe
                                                  style:UITableViewStylePlain];
        mTableView.delegate = self;
        mTableView.dataSource = self; 
        [self.view addSubview:mTableView];
    }
    //人文地理信息展示条
    if (!mLocationInfoView) {
        UIImageView * bg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"lightblue.png"]];
        [bg setFrame:CGRectMake(0.f, 0.f, 320.f, 20.f)];
        [self.view addSubview:bg];
        [bg release];
        mLocationInfoView = [[UILabel alloc] initWithFrame:CGRectMake(2.f, 4.f, 300.f, 15.f)];
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
                              initWithFrame:CGRectMake(0.0f, -108.0f - mTableView.bounds.size.height, mTableView.frame.size.width, self.view.bounds.size.height)]; 
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
        [mSoftNoticeViewLoad setMessage:@"附近的微博..."];
        [mSoftNoticeViewLoad setActivityindicatorHidden:NO];
        [mSoftNoticeViewLoad setHidden:YES];
        [self.view addSubview:mSoftNoticeViewLoad];
    }
    //设置弹出框
    if (!mQueryAction) {
        mQueryAction = [[UIActionSheet alloc] initWithTitle:@"" delegate:self cancelButtonTitle:@"关闭" destructiveButtonTitle:nil otherButtonTitles:@"查看最新", @"查看最近", nil];
    }
    
    /**-----------------开始加载数据--------------------**/
    NSLog(@"viewdidload");
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
    mMapView = nil;
    [mMapView release];
    mQueryAction = nil;
    [mQueryAction release];
}

- (void)viewWillAppear:(BOOL)animated
{
    //导航条不隐藏
    [self.navigationController setNavigationBarHidden:NO];
    [self.navigationController setHidesBottomBarWhenPushed:NO];
    //设置头部显示名称
    UIButton * backToHeadButton = (UIButton *)self.navigationItem.titleView;
    [backToHeadButton setTitle:[DataController getUserScreenName] forState:UIControlStateNormal];
    if ([DataController getShenbianVCNeedRefreash]) {
        [DataController setShenbianVCNeedRefreash:NO];
        //[self refreshData];
    }
    else {
        //如果没有数据结束定位
        if ([mStatuses count] == 0) {
            [self performSelector:@selector(endDefaultLocate)];
        }
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
        [self reverseGeocoderBegin:[DataController getDefaultRegion].center];
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
    [self reverseGeocoderBegin:newLocation.coordinate];
}
/**定位失败**/
- (void) locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    [manager stopUpdatingLocation];
    [manager setDelegate:nil];
    
    [self endDefaultLocate];
    [self alert:@"网络异常"];
}
/**人文信息**/
-(void)reverseGeocoderBegin:(CLLocationCoordinate2D)coordinate
{
    MKReverseGeocoder * reverseGeocoder = [[MKReverseGeocoder alloc] initWithCoordinate:coordinate];
    [reverseGeocoder setDelegate:self];
    [reverseGeocoder start];
}
-(void)reverseGeocoder:(MKReverseGeocoder *)geocoder didFindPlacemark:(MKPlacemark *)placemark
{
    if ([geocoder retainCount]) {
        [geocoder release];
    }
    mCurrentLocation.title = placemark.locality;
    mCurrentLocation.subtitle = placemark.subLocality;
    mCurrentLocation.streetAddress = placemark.thoroughfare;
    mCurrentLocation.region = placemark.administrativeArea;
    mCurrentLocation.city = placemark.locality;
    mCurrentLocation.country = placemark.country;
    [mCurrentLocation format];
    
    [DataController setMinLocationDescription:[[NSString alloc] initWithFormat:@"%@",mCurrentLocation.streetAddress]];
    [DataController setLocationDescription:[[NSString alloc] initWithFormat:@"我在：%@ %@ %@",mCurrentLocation.title, mCurrentLocation.subtitle,mCurrentLocation.streetAddress]];  
    
    [self endDefaultLocate];
}
-(void)reverseGeocoder:(MKReverseGeocoder *)geocoder didFailWithError:(NSError *)error
{
    //获取当前人文信息
    GoogleClient * googleClient = [[GoogleClient alloc] init];
    NSDictionary * json = [googleClient allocGetReverseGeocoder:[DataController getDefaultLatitude] longitude:[DataController getDefaultLongitude]];
    [googleClient release];
    if (!json) {
        [self endDefaultLocate];
        [self alert:@"网络异常"];
    }
    else
    {
        NSDictionary * status = [json objectForKey:@"Status"];
        int resultCode = [[status objectForKey:@"code"] intValue];
        if (resultCode != 200) {
            [self endDefaultLocate];
            [self alert:@"网络异常"];
        }
        else {
            [GoogleClient setWLocationByJson:json wLocation:mCurrentLocation];
            [mCurrentLocation format];
            [DataController setMinLocationDescription:[[NSString alloc] initWithFormat:@"%@",mCurrentLocation.streetAddress]];
            [DataController setLocationDescription:[[NSString alloc] initWithFormat:@"我在：%@ %@ %@",mCurrentLocation.title,mCurrentLocation.subtitle,mCurrentLocation.streetAddress]];
            [self endDefaultLocate];
        }
    }
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
    else{
        StatusFilter * statusFilter = [[StatusFilter alloc] init]; 
        //清理数据
        if (mLoadingDataType == 1) {
            [self initMStatusData];
        }
        //存储微博数据
        mStatusCount = [[(NSDictionary *)obj objectForKey:@"total_number"] longValue];
        NSArray * ary = [(NSDictionary *)obj objectForKey:@"statuses"];;
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
    //    [self mapViewBegin];
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
    //    [self mapViewBegin];
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
    if (indexPath.row < [mStatuses count]) {
        StatusItemCellPic * cell = (StatusItemCellPic *)[self tableView:tableView cellForRowAtIndexPath:indexPath];
        return [cell getCellHeight];
    }
    else {
        return 110.f;
    }
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{//add by max
//    int count = [mStatuses count];
//    if ([self ifCanLoadMore]) 
//        count ++ ;
//    return count;
    int total = [mStatuses count];
    int count = 0;
    if (total%3==0){
        count = total/3;
    }else{
        count = total/3+1;
    }
    return count;
}
/**生成列表表格**/
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{    
    if (indexPath.row < [mStatuses count]) {
        StatusItemCellPic *cell = (StatusItemCellPic *)[tableView dequeueReusableCellWithIdentifier:@"cell_statuspic"];
        if (cell == nil) {
            cell = [[[StatusItemCellPic alloc] initWithStyle:UITableViewCellStyleValue1
                                          reuseIdentifier:@"cell_statuspic"] autorelease];
        }
        int intTemp = indexPath.row * 3;
        
        Status * statusOne = [mStatuses objectAtIndex:intTemp];       
        [cell.statusImgOne setImageUrl:statusOne.bmiddlePic];
        [cell.statusImgOne getImageByUrl:6];
        
        if((intTemp+1)<[mStatuses count]){
            Status * statusTwo = [mStatuses objectAtIndex:intTemp+1];         
            [cell.statusImgTwo setImageUrl:statusTwo.bmiddlePic];
            [cell.statusImgTwo getImageByUrl:6];
        }
       if((intTemp+2)<[mStatuses count]){        
            Status * statusThree = [mStatuses objectAtIndex:intTemp+2]; 
            [cell.statusImgThree setImageUrl:statusThree.bmiddlePic];
            [cell.statusImgThree getImageByUrl:6];
       }
        [cell sizeToFit];
        
        return cell;
    }
    else if(indexPath.row == [mStatuses count]){   
        
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
/**表格点击事件处理,查微博的详细信息**///********待改
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
#pragma mark - 展示数据 之 [地图展示]

/**地图开始展示**/
- (void) mapViewBegin
{
    //设置地图当前位置，触发regionDidChangeAnimated事件
    mIsFirstLoadData = YES;
    [mMapView setRegion:mRegion animated:YES];
}

/**地图位置变换后，重新加载数据(代理)**/
- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
    if (mIsFirstLoadData) {
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(mapViewAnnotationLoad) object:nil];
        [self performSelector:@selector(mapViewAnnotationLoad) withObject:nil];
    }
}
/**用微博返回的数据生成地图标识**/
- (void)mapViewAnnotationLoad
{
    if(mIsFirstLoadData){
        [mMapView removeAnnotations:[mMapView annotations]];
        //中心位置
        int index  = 0;
        LocationAnnotation * annotaion = [[LocationAnnotation alloc] init];
        annotaion.wLocation = mCurrentLocation;
        annotaion.indexTag = index;
        [mMapView addAnnotation:annotaion];
        [annotaion release];
        index = 0;
        //微博数据位置
        for (Status * status in mStatuses) {
            StatusAnnotation * annotaion = [[StatusAnnotation alloc] init];
            annotaion.status = status;
            annotaion.indexTag = index;
            [mMapView addAnnotation:annotaion];
            [annotaion release];
            index ++;
        }
        //设置为已加载过
        mIsFirstLoadData = NO;
    }
}
/**地图注释生成(代理)**/
- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation;
{  
    
    //微博标志
    if ([annotation isKindOfClass:[StatusAnnotation class]]) {
        static NSString * StatusAnnotationIdentifier = @"StatusAnnotationIdentifier";
        
        StatusAnnotationView * pinView = (StatusAnnotationView *)[mMapView dequeueReusableAnnotationViewWithIdentifier:StatusAnnotationIdentifier];
        if (pinView == nil) {
            pinView = [[[StatusAnnotationView alloc] initWithAnnotation:annotation
                                                        reuseIdentifier:StatusAnnotationIdentifier] autorelease];
            pinView.canShowCallout = YES;
            //标志图片
            UIImage * image = [[UIImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"locate" 
                                                                                                      ofType:@"png"]];
            pinView.image = image;
            [image release];
            
        }
        else {
            pinView.annotation = annotation;  
        }
        //详细按钮 , 并设置当前点击的Status
        StatusAnnotation * curAnnotation = (StatusAnnotation *) annotation;
        UIButton * detailButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        detailButton.tag = curAnnotation.indexTag;
        [detailButton addTarget:self
                         action:@selector(toStatusDetailViewByMap:)
               forControlEvents:UIControlEventTouchUpInside];
        pinView.rightCalloutAccessoryView = detailButton;
        return pinView;
        
    }
    //中心标志
    else if([annotation isKindOfClass:[LocationAnnotation class]]){
        static NSString * LocationAnnotationIdentifier = @"LocationAnnotationIdentifier";
        
        MKPinAnnotationView * pinView = (MKPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:LocationAnnotationIdentifier];
        if (!pinView) {
            MKPinAnnotationView * pinView = [[[MKPinAnnotationView alloc]
                                              initWithAnnotation:annotation reuseIdentifier:LocationAnnotationIdentifier] autorelease];
            pinView.pinColor = MKPinAnnotationColorPurple;
            pinView.animatesDrop = YES; 
            pinView.canShowCallout = YES;
        }
        else {
            pinView.annotation = annotation;
        }
        return pinView;
        
    }else{
        return nil;
    }
}


#pragma mark - 
#pragma mark - 事件处理 之 [微博事件（查看详细,视图切换,视图刷新,筛选,搜索）]

/****/
- (void)toPlacesSearchView
{
    PlacesSearchViewController * placesSearchViewController = [[PlacesSearchViewController alloc] init];
    placesSearchViewController.finishTarget = self;
    placesSearchViewController.finishAction = @selector(backFromPlacesSearchView);
    [self presentModalViewController:placesSearchViewController animated:YES];
    [placesSearchViewController release];
}
- (void)backFromPlacesSearchView
{
    [self defaultLocate:NO];
}
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
    statusDetailViewController.region = mRegion;
    [statusDetailViewController setHidesBottomBarWhenPushed:YES];
    [self.navigationController pushViewController:statusDetailViewController animated:YES];
    [statusDetailViewController release];
    //保存点击事件 add by max
    [self saveWeiboClick:status
            onlineuserid:(long)mOAuthEngine.username
          onlineusername:[DataController getUserScreenName]
         onlineuserimage:((User *)[DataController getUser]).profileImageUrl   
             nowlatitude:[DataController getDefaultLatitude] 
             nowlongtude:[DataController getDefaultLongitude]
              nowaddress:[[NSString alloc] initWithFormat:@"%@",[DataController getMinLocationDescription]]];
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
/**切换微博数据的［列表］表示与［地图］表示**/
- (void)exchangeTableViewAndMapView
{
    [self.view exchangeSubviewAtIndex:1 withSubviewAtIndex:2];
}


/**筛选数据为[所有]**/
- (void)filterDataToAll
{
    mQueryCondition.isImage = NO;
    [mTableView addSubview:mRefreshHeaderView]; 
    [self tableViewBegin];
    [self mapViewBegin];
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
    [self mapViewBegin];
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
//add by max
- (void)saveWeiboClick:(Status *) status 
          onlineuserid:(long)userid  
        onlineusername:(NSString *)username
       onlineuserimage:(NSString *)userimage 
           nowlatitude:(double)geolat 
           nowlongtude:(double)geolng 
            nowaddress:(NSString *)address
{
    mWeiexClient= [[WeiexClient alloc] initWithDele:self];
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
@end
