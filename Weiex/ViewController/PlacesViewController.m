//
//  PlacesViewController.m
//  WeiTansuo
//
//  Created by HYQ on 9/21/11.
//  Copyright 2011 Invidel. All rights reserved.
//

#import "PlacesViewController.h"

#define MAX_LONG_LONG_INT 9999999999999999
#define MAX_LOCATE_TIME 4


@implementation PlacesViewController

@synthesize finishTarget,finishAction;

- (id)init
{
    self = [super init];
    if(self) {
        mPlaces = [[NSMutableArray alloc] init];
        mQueryCondition = [[QueryCondition alloc] init];
        mLocationManager = [[CLLocationManager alloc] init];
        mCurrentLocation = [[WLocation alloc] init];
        mSelectRegion = [DataController getDefaultRegion];
        mPlaceSelect = NO;
        mIsFirstLoadData = NO;
        mSearchLocations = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)dealloc
{
    [mSearchLocations release];
    [mLoadMoreAIView release];
    [mLoadMoreImageView release];
    [mSoftNoticeViewLoad release];
    [mRefreshHeaderView release];
    [mTableView release];
    [mMapView release];
    [mHeadToolbar release];
    [mCurrentLocation release];
    [mLocationManager release];
    [mPlaces release];
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - 视图

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
}
*/

//view
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //头部-导航
    if(!mHeadToolbar){
        mHeadToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
        
        //背景
        [mHeadToolbar setBarStyle:UIBarStyleBlackOpaque];
    
        //中间
        UIButton * backToHeadButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [backToHeadButton setFrame:CGRectMake(35, 11, 250, 20)];
        [backToHeadButton setTitle:@"选择所在地点" forState:UIControlStateNormal];
        [backToHeadButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [backToHeadButton setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
        [backToHeadButton addTarget:self action:@selector(backToHead) forControlEvents:UIControlEventTouchDown];
        [mHeadToolbar addSubview:backToHeadButton];
        //取消      
        UIButton * cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [cancelButton setFrame:CGRectMake(0, 4, 54, 33)];
        [cancelButton setImage:[UIImage imageNamed:@"locateCancelButton.png"] forState:UIControlStateNormal];
        [cancelButton setImage:[UIImage imageNamed:@"locateCancelButton2.png"] forState:UIControlStateHighlighted];
        [cancelButton addTarget:self action:@selector(cancel) forControlEvents:UIControlEventTouchUpInside];
        [mHeadToolbar addSubview:cancelButton];
       
        [self.view addSubview:mHeadToolbar];
    }
//    //搜索条
//    if (!mSearchBar) {
//        mSearchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
//        mSearchBar.delegate = self;
//        mSearchBar.barStyle = UIBarStyleBlackOpaque;
//        mSearchBar.backgroundColor = [UIColor clearColor];
//        [[mSearchBar.subviews objectAtIndex:0] removeFromSuperview];
//        //加入导航条
//        UIView * searchBgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 270, 44)];
//        [searchBgView addSubview:mSearchBar];
//        [mSearchBar sizeToFit];
//        [mHeadToolbar addSubview:searchBgView];
//        [searchBgView release];
//    }
//    
    //功能区按钮
//    UIButton * functionButton = [[UIButton alloc] initWithFrame:CGRectMake(275, 7, 38, 30)];
//    [functionButton setImage:[UIImage imageNamed:@"export.png"] forState:UIControlStateNormal];
//    [functionButton setImage:[UIImage imageNamed:@"exportPressed.png"] forState:UIControlStateHighlighted];
//    [functionButton addTarget:self action:@selector(toFunctionActionSheet) forControlEvents:UIControlEventTouchUpInside];
//    [mHeadToolbar addSubview:functionButton];
//    [functionButton release];
//    
//    if (!mFunctionAction) {
//        mFunctionAction = [[UIActionSheet alloc] initWithTitle:@"" 
//                                                      delegate:self 
//                                             cancelButtonTitle:@"关闭" 
//                                        destructiveButtonTitle:nil 
//                                             otherButtonTitles:@"列表模式",@"地图模式", @"退出定位", nil];
//        mFunctionAction.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
//        mFunctionAction.alpha =0.95;
//    }
    
    //设置地图视图
//    if (!mMapView) {
//        CGRect mapFrame = self.view.frame;
//        mapFrame.size.height -= 44.f;
//        mapFrame.origin.y = 44.f;
//        mMapView = [[MKMapView alloc] initWithFrame:mapFrame];
//        mMapView.centerCoordinate = mSelectRegion.center;
//        mMapView.delegate = self;
//        mMapView.showsUserLocation = YES;
//        [self.view addSubview:mMapView];
//        mViewState = 1;
//    }
    
    //设置列表视图
    if (!mTableView) {
        CGRect tableframe = self.view.frame;
        tableframe.size.height -=  44.f;
        tableframe.origin.y = 44.f;
        mTableView = [[UITableView alloc] initWithFrame:tableframe
                                                  style:UITableViewStylePlain];
        [mTableView setBackgroundColor:[UIColor clearColor]];
        UIImageView * backgroundImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"blackbg.png"]];
        [mTableView setBackgroundView:backgroundImageView];
        [backgroundImageView release];
        mTableView.delegate = self;
        mTableView.dataSource = self; 
        [self.view addSubview:mTableView];
        mViewState = 0;
    }
    
    //设置头部下拉刷新
    if (!mRefreshHeaderView) { 
        mRefreshHeaderView = [[EGORefreshTableHeaderView alloc] 
                              initWithFrame:CGRectMake(0.0f, -44.0f-mTableView.bounds.size.height, mTableView.frame.size.width, self.view.bounds.size.height)]; 
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
        mLoadMoreAIView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhite; 
    }
    
    //加载框
    if (!mSoftNoticeViewLoad) {
        mSoftNoticeViewLoad = [[SoftNoticeView alloc] initWithFrame:CGRectMake(90, 170, 140, 140)];
        [mSoftNoticeViewLoad setMessage:@"定位中..."];
        [mSoftNoticeViewLoad setActivityindicatorHidden:NO];
        [mSoftNoticeViewLoad setHidden:YES];
        [self.view addSubview:mSoftNoticeViewLoad];
    }

    
    [self locateBegin];

}


- (void)viewDidUnload
{
    [super viewDidUnload];
    mLoadMoreAIView = nil;
    [mLoadMoreAIView release];
    mLoadMoreImageView = nil;
    [mLoadMoreImageView release];
    mRefreshHeaderView = nil;
    [mRefreshHeaderView release];
    mMapView = nil;
    [mMapView release];
    mTableView = nil;
    [mTableView release];
    mSearchBar = nil;
    [mSearchBar release];
    mHeadToolbar = nil;
    [mHeadToolbar release];  
}


#pragma mark -
#pragma mark - 自定义初始化函数
/**初始化地点**/
- (void)initMRegion
{
    mSelectRegion = [DataController getDefaultRegion];    
    mCurrentLocation.latitude = mSelectRegion.center.latitude;
    mCurrentLocation.longitude = mSelectRegion.center.longitude; 
    mCurrentLocation.title = [DataController getMinLocationDescription];//@"";
    mCurrentLocation.subtitle = [DataController getMinLocationDescription];
    mCurrentLocation.guid = @"";
    [mSearchLocations removeAllObjects];
    [mSearchLocations insertObject:mCurrentLocation atIndex:0];
}
/**初始化查询条件**/
- (void)initMQueryCondition
{
    mQueryCondition.latitude = [DataController getDefaultLatitude];
    mQueryCondition.longitude = [DataController getDefaultLongitude];
    mQueryCondition.startpage = 1;
    mQueryCondition.count = 30;
}
/**初始化微博数据**/
- (void)initMPlaceData
{
    [mPlaces removeAllObjects];
}


#pragma mark -
#pragma mark - 定位(代理)
- (BOOL)beforeLocate
{
    if (mIsloading) {
        return NO;
    }
    mIsloading = YES;
    [mSoftNoticeViewLoad setMessage:@"定位中..."];
    mLoadingDataType = 1;
    [mSoftNoticeViewLoad setHidden:NO];
    [mSoftNoticeViewLoad start];
    return YES;
}
- (void)endLocate
{
    [mRefreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:mTableView];
    mLoadingDataType = 0;
    [mSoftNoticeViewLoad stop];
    [mSoftNoticeViewLoad setHidden:YES];
    [self tableViewBegin];
//    [self mapViewBegin];
    mIsloading = NO;
}
/**开始定位**/
- (void)locateBegin
{   
    if (![self beforeLocate]) {
        return;
    }
    [self initMRegion];
    [self initMQueryCondition];
    
    //定位
    mBestEffortAtLocation = nil;
    mLocateTimes = 0;
    mLocationManager.delegate = self;
    mLocationManager.desiredAccuracy = kCLLocationAccuracyBest; 
    [mLocationManager startUpdatingLocation];
}

/**定位成功**/
- (void)locationManager:(CLLocationManager *)manager
	didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation  
{
    [mLocationManager stopUpdatingLocation];
    mLocateTimes ++;
    if (!mBestEffortAtLocation) {
        mBestEffortAtLocation  = newLocation;
        [mBestEffortAtLocation retain];
    }
    else if (newLocation.horizontalAccuracy < mBestEffortAtLocation.horizontalAccuracy) {
        mBestEffortAtLocation = newLocation;
        [mBestEffortAtLocation retain];
    }
    if (mLocateTimes < MAX_LOCATE_TIME) {
        [mLocationManager startUpdatingLocation];
    }
    else {
        mQueryCondition.latitude = mBestEffortAtLocation.coordinate.latitude;
        mQueryCondition.longitude = mBestEffortAtLocation.coordinate.longitude;
        //获取周边地点
        [self loadPlaceBegin];
        //获取当前人文信息

    }      
}
/**定位失败**/
- (void) locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    [mLocationManager stopUpdatingLocation];
    mLocateTimes ++;
    if (mLocateTimes < MAX_LOCATE_TIME) {
        [mLocationManager startUpdatingLocation];
    }
    else {
        [self endLoadData];
    } 
}

#pragma mark -
#pragma mark - 数据 之(街旁接口 获取周围人文信息)

/**根据经纬度获取周围人文信息**/
- (void)loadPlaceBegin
{
    mJiepangClient= [[JiepangClient alloc] initWithTarget:self action:@selector(loadPlaceFinished:json:)]; 
    [mJiepangClient getPlaces:mQueryCondition.latitude
                   longitude:mQueryCondition.longitude
              startingAtPage:mQueryCondition.startpage 
                       count:mQueryCondition.count];
}
- (void)loadPlaceFinished:(JiepangClient *)sender
                     json:(NSDictionary*)json
{
    if (sender.hasError || json == nil) {
        [self endLoadData];
        [self alert:@"网络异常"];
    }
    else{
        if (mLoadingDataType == 1) {
            [self initMPlaceData];
        }
        
        mHasMore = [[(NSDictionary *)json objectForKey:@"has_more"] boolValue];
        NSArray * items = (NSArray *)[(NSDictionary *)json objectForKey:@"items"];
        for (NSDictionary * item in items) {
            WLocation * wLocation = [[WLocation alloc] init];
            wLocation.title = [item objectForKey:@"name"];
            wLocation.subtitle = [item objectForKey:@"addr"];
            wLocation.guid = [item objectForKey:@"guid"];
            [mPlaces addObject:wLocation];
            [wLocation release];
            
        }
        [self endLoadData];
    }
}


#pragma mark -
#pragma mark - 数据 之 控制

/**加载更多**/
- (BOOL)beforeLoadMorePlace
{
    if (mIsloading) {
        return NO;
    }
    mIsloading = YES;
    mLoadingDataType = 2;
    [mLoadMoreImageView setHidden:YES];
    [mLoadMoreAIView startAnimating];
    return YES;
}
- (void)endLoadMorePlace
{
    [mLoadMoreAIView stopAnimating];
    [mLoadMoreImageView setHidden:NO];
    [self tableViewBegin];
//    [self mapViewBegin];
    mLoadingDataType = 0;
    mIsloading = NO;
}
- (void)loadMorePlace
{
    if (![self beforeLoadMorePlace])  return;
    mQueryCondition.startpage++;
    [self loadPlaceBegin];
}
/**辅助方法**/
- (void)endLoadData
{
    if (mLoadingDataType == 1) {
        [self endLocate];
    } 
    else if(mLoadingDataType == 2) {
        [self endLoadMorePlace];
    }
}
/**是否可以加载更多**/
- (BOOL)ifCanLoadMore
{
    return mHasMore;
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
        return 50.f;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{ 
    int count = [mPlaces count];
    if ([self ifCanLoadMore]) {
        return count+1;
    }
    else {
        return count;
    }
}
/**生成列表表格**/
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row < [mPlaces count]) {
        UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"PlaceCell"];
        if (cell == nil) {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                          reuseIdentifier:@"PlaceCell"] autorelease];
        }
        
        WLocation * wLocation = [mPlaces objectAtIndex:indexPath.row];
        //cell.imageView.image = [ UIImage imageNamed: @"locateleft.png"];
        cell.textLabel.text = wLocation.title;
        [cell.textLabel setTextColor:[UIColor whiteColor]];
        cell.detailTextLabel.text = wLocation.subtitle;
        [cell.detailTextLabel setTextColor:[UIColor lightGrayColor]];
        return cell;
    }
    else if(indexPath.row == [mPlaces count]){   
        
        UITableViewCell * cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"PlaceCell_loadmore"];
        if (cell == nil){
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                           reuseIdentifier:@"PlaceCell_loadmore"] autorelease];
        }
        
        [cell addSubview:mLoadMoreImageView];
        [cell addSubview:mLoadMoreAIView];

        UILabel * loadMoreLabel = [[UILabel alloc] initWithFrame:CGRectMake(125, 14, 150, 17)];
        [loadMoreLabel setFont:[UIFont fontWithName:@"Arial" size:13]];
        [loadMoreLabel setTextColor:[UIColor grayColor]];
        [loadMoreLabel setText:@"上拉加载更多"];
        [loadMoreLabel setBackgroundColor:[UIColor clearColor]];
        [cell addSubview:loadMoreLabel];
        [loadMoreLabel release];
        
        UIButton * loadMoreButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [loadMoreButton setFrame:CGRectMake(80.f, 0.f, 160.f, 60.f)];
        [loadMoreButton setBackgroundColor:[UIColor clearColor]];
        [loadMoreButton addTarget:self action:(@selector(loadMorePlace)) forControlEvents:UIControlEventTouchUpInside];
        [cell addSubview:loadMoreButton];
        
        return cell;
    }
    else {
        UITableViewCell * cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"PlaceCell_other"];
        if (cell == nil){
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                           reuseIdentifier:@"PlaceCell_other"] autorelease];
        }
        return cell;
    }
}
/**表格点击事件处理,设置地点**/
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    if (indexPath.row < [mPlaces count]) {
        WLocation * wLocation = [mPlaces objectAtIndex:indexPath.row];
        NSString * placeText = wLocation.title;
        //设置地点
        //[self setRegion:wLocation];
        [self dismissModalViewControllerAnimated:YES];
        if ([finishTarget retainCount] > 0 && [finishTarget respondsToSelector:finishAction]) {
            [finishTarget performSelector:finishAction  withObject:placeText];
        }
    }
}
#pragma mark – 
#pragma mark - 上拉加载更多

/** UIScrollViewDelegate Methods **/
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (!mIsloading) {
        [mRefreshHeaderView egoRefreshScrollViewDidScroll:scrollView]; 
        //下拉加载更多
        if ([self ifCanLoadMore]) {
            if (scrollView.isDragging) {
                if(scrollView.contentOffset.y >=  scrollView.contentSize.height - scrollView.frame.size.height + 60) {        
                    if (scrollView.contentOffset.y >= scrollView.contentSize.height - scrollView.frame.size.height) {
                        [self loadMorePlace]; 
                    }        
                }
            }
        }     
    }
}
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{ 
    if (!mIsloading && !mIsAlert) {
        [mRefreshHeaderView egoRefreshScrollViewDidEndDragging:scrollView]; 
    }
}
/** EGORefreshTableHeaderDelegate Methods **/ 
- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView*)view{
    [self locateBegin];
}

- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView*)view{
    return mIsloading; 
} 
- (NSDate*)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView*)view{
    return [NSDate date];     
} 


#pragma mark -
#pragma mark - 展示数据 之 [地图展示]

/**地图开始展示**/
//- (void) mapViewBegin
//{
//    mIsFirstLoadData = YES;
//    [mMapView setRegion:[DataController getDefaultRegion] animated:YES];
//}

/**地图位置变换后，重新加载数据(代理)**/
- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
    if (mIsFirstLoadData) {
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(mapViewAnnotationLoad) object:nil];
        [self performSelector:@selector(mapViewAnnotationLoad) withObject:nil];
    }
}

/**用微博返回的数据生成地图标识**/
//- (void)mapViewAnnotationLoad
//{
//    if(mIsFirstLoadData){
//        [mMapView removeAnnotations:[mMapView annotations]];
//        int index = 0;
//        //中心位置
//        for (WLocation * wLocation in mSearchLocations) {
//            LocationAnnotation * annotaion = [[LocationAnnotation alloc] init];
//            annotaion.wLocation = wLocation;
//            annotaion.indexTag = index;
//            [mMapView addAnnotation:annotaion];
//            [annotaion release];
//            index ++;
//        }
//        //设置为已加载过
//        mIsFirstLoadData = NO;
//    }
//}
/**地图注释生成(代理)**/
//- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation;
//{  
//    if([annotation isKindOfClass:[LocationAnnotation class]]){
//        static NSString * LocationAnnotationIdentifier = @"LocationAnnotationIdentifier";
//        
//        MKPinAnnotationView * pinView = (MKPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:LocationAnnotationIdentifier];
//        if (!pinView) {
//            pinView = [[[MKPinAnnotationView alloc]
//                         initWithAnnotation:annotation 
//                            reuseIdentifier:LocationAnnotationIdentifier] autorelease];   
//        }
//        else {
//            pinView.annotation = annotation;
//        }
//        pinView.canShowCallout = YES;
//        //标志图片
//        UIImage * image = [[UIImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"locateleft" 
//                                                                                                  ofType:@"png"]];
//        pinView.image = image;
//        [image release];
//        LocationAnnotation * curAnnotation = (LocationAnnotation *) annotation;
//        UIButton * detailButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
//        detailButton.tag = curAnnotation.indexTag;
//        [detailButton addTarget:self
//                         action:@selector(SelectLocationInMapView:)
//               forControlEvents:UIControlEventTouchUpInside];
//        pinView.rightCalloutAccessoryView = detailButton;
//        return pinView;
//    }else{
//        return nil;
//    }
//}


#pragma mark -
#pragma mark - 事件
/**切换到列表模式**/
//- (void)changeViewToTable
//{
//    if (mViewState == 0) {
//        return ;
//    }
//    mViewState = 0;
//    [self.view exchangeSubviewAtIndex:1 withSubviewAtIndex:2];
//}
///**切换到地图模式**/
//- (void)changeViewToMap
//{
//    if (mViewState == 1) {
//        return ;
//    }
//    mViewState = 1;
//    [self.view exchangeSubviewAtIndex:1 withSubviewAtIndex:2];
//}
/**退出**/
- (void)cancel
{
    if (mIsAlert) {
        return;
    } 
    if (mIsloading) {
        [mJiepangClient cancel];
    } 
    [self dismissModalViewControllerAnimated:YES];
}
/**回到头部**/
- (void)backToHead
{
    [self tableviewScrollToTop:YES];
}
///**地图中选择地点**/
//- (void)SelectLocationInMapView:(id)sender
//{
//    
//}
/**根据选择的地点（街旁GUID），获取其经纬度**/
- (void)setRegion:(WLocation *)wLocation
{
    if (mIsAlert) {
        return;
    }
    if (mIsloading) {
        [mJiepangClient cancel];
    }
    [self loadLatLonByGuid:wLocation];
    
}
- (void)loadLatLonByGuid:(WLocation *)wLocation
{
    mIsloading = YES;
    [mSoftNoticeViewLoad setMessage:@"加载中..."];
    [mSoftNoticeViewLoad setHidden:NO];
    [mSoftNoticeViewLoad start];
    
    [DataController setMinLocationDescription:[[NSString alloc] initWithFormat:@"%@",wLocation.title]];
    [DataController setLocationDescription:[[NSString alloc] initWithFormat:@"我在：%@",wLocation.title]];
    
    mJiepangClient= [[JiepangClient alloc] initWithTarget:self action:@selector(loadLatLonByGuidFinished:json:)]; 
    [mJiepangClient getLatLonByGuid:wLocation.guid];
}
- (void)loadLatLonByGuidFinished:(JiepangClient *)sender
                            json:(NSDictionary*)json
{
    if (sender.hasError || json == nil) {
        [mSoftNoticeViewLoad stop];
        [mSoftNoticeViewLoad setHidden:YES];
        mIsloading = NO;
        [self alert:@"网络异常"];
    }
    else
    {
        float lat = [[json objectForKey:@"lat"] floatValue];
        float lon = [[json objectForKey:@"lon"] floatValue];
        
        mSelectRegion.center.latitude = lat;
        mSelectRegion.center.longitude = lon;
        
        [DataController setDefaultRegion:mSelectRegion];
        [DataController setDefaultLatitude:lat];
        [DataController setDefaultLongitude:lon];
        
        mPlaceSelect = YES;
        [mSoftNoticeViewLoad stop];
        [mSoftNoticeViewLoad setHidden:YES];
        mIsloading = NO; 
        
        [self dismissModalViewControllerAnimated:YES];
        if ([finishTarget retainCount] > 0 && [finishTarget respondsToSelector:finishAction]) {
            [finishTarget performSelector:finishAction  withObject:nil];
        }
    } 
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
    [self performSelector:@selector(closeAlert:) withObject:msgBox afterDelay:2.f];
    
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
//- (void) toFunctionActionSheet
//{
//    [mFunctionAction showInView:self.view];
//}
//
//
//- (void)actionSheet:(UIActionSheet *)modalView clickedButtonAtIndex:(NSInteger)buttonIndex
//{
//    switch (buttonIndex)
//    {
//        case 0:
//            [self changeViewToTable];
//            break;
//        case 1:
//            [self changeViewToMap];
//            break;
//        case 2:
//            [self cancel];
//            break;
//        default:
//            break;
//    }
//}
@end
