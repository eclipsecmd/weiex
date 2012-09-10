//
//  SortViewController.m
//  WeiTansuo
//
//  Created by Yuqing Huang on 10/8/11.
//  Copyright 2011 Invidel. All rights reserved.
//

#import "SortRootViewController.h"

#define STATUSDATA_MAX_PAGE  15
#define STATUSDATA_PAGE_SIZE 5
#define MAX_LONG_LONG_INT 9999999999999999
#define MAX_TEMP_NUM 8

@implementation SortRootViewController

@synthesize finishTarget,finishAction;
@synthesize optFlag,starHotplaceid;
@synthesize hotplaceDescription=mHotplaceDescription;
@synthesize nowRegion=mNowRegion;
@synthesize regionLat=mRegionLat;
@synthesize regionLng=mRegionLng;
@synthesize regionProvince=mRegionProvince;
@synthesize isPushOrShow = mISpushorShow;

- (id)init
{
    self = [super init];
    if (self) {
        self.title = @"热点";
        self.tabBarItem = [[[UITabBarItem alloc] initWithTitle:@"热点" 
                                                         image:[UIImage imageNamed:@"hot.png"]
                                                           tag:2] autorelease];
        mPlaces = [[NSMutableArray alloc] init];
        //        HotPlace * example = [[HotPlace alloc]init];
        //        [example setTitle:@"天安门"];
        //        [example setStarNum:1];
        //        [mPlaces addObject:example];
        mImgUrls = [[NSMutableArray alloc] init];
        mQueryCondition = [[QueryCondition alloc] init];      
        mHotStyle = 1;//默认展示最新热点 
    }
    return self;
}

- (void)dealloc
{
    [mQueryCondition release] ;
    [mLoadMoreImageView release];
    [mLoadMoreAIView release];
    [mSoftNoticeViewLoad release];
    [mSortTableView release];
    [mPlaces release];                         
    [mImgUrls1 release];
    [mImgUrls2 release];
    [mImgUrls3 release];
    [mImgUrls4 release];
    [mImgUrls5 release];
    [mImgUrls6 release];
    [mImgUrls release];  
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
    [self.view setBackgroundColor:[UIColor clearColor]];
    
    UIView * headToolBar = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
    [headToolBar setBackgroundColor:[UIColor clearColor]];
    [self.view addSubview:headToolBar];
    
    UILabel * title1 =  [[UILabel alloc] initWithFrame:CGRectMake(68, 14.5, 70, 14)];
    title1.font = [UIFont fontWithName:@"TrebuchetMS" size:14];
    title1.text = @"最新|热点";
    [title1 setAdjustsFontSizeToFitWidth:YES];
    [title1 setTextColor:[UIColor whiteColor]];
    [title1 setBackgroundColor:[UIColor clearColor]];
    [self.view addSubview: title1];
    [title1 release];
    UILabel * title2 =  [[UILabel alloc] initWithFrame:CGRectMake(193, 14.5, 70, 14)];    
    [title2 setAdjustsFontSizeToFitWidth:YES];
    title2.font = [UIFont fontWithName:@"TrebuchetMS" size:14];
    title2.text = @"最热|热点";
    [title2 setTextColor:[UIColor whiteColor]];
    [title2 setBackgroundColor:[UIColor clearColor]];
    [self.view addSubview: title2];
    [title2 release];
    
    //切换工具条 add by mayongxing
    UISegmentedControl * styleControl = [[UISegmentedControl alloc] initWithItems:nil];
    styleControl.frame = CGRectMake(39, 7, 242, 29);    
    [styleControl setBackgroundColor:[UIColor clearColor]];
    styleControl.segmentedControlStyle = UISegmentedControlStyleBar;
    [styleControl insertSegmentWithImage:[UIImage imageNamed:@"tab_l_press.png"] atIndex:0 animated:FALSE];
    [styleControl insertSegmentWithImage:[UIImage imageNamed:@"tab_r_nor.png"] atIndex:1 animated:FALSE];
    
    styleControl.selectedSegmentIndex = 0;
    [headToolBar addSubview:styleControl];
    [styleControl addTarget:self action:@selector(changeListStyle:) forControlEvents:UIControlEventValueChanged];
    [styleControl release];   
    
    //设置列表视图
    CGRect tableframe = self.view.frame;
    tableframe.size.height -= 48.f + 44.f + 2.f;
    tableframe.size.width = 308.f;
    tableframe.origin.x = 6.f;
    tableframe.origin.y = 48.f+2.f;
    mSortTableView = [[UITableView alloc] initWithFrame:tableframe style:UITableViewStylePlain];
    mSortTableView.delegate = self;
    mSortTableView.dataSource = self;
    [mSortTableView setBackgroundColor:[UIColor clearColor]];
    [self.view addSubview:mSortTableView]; 
    
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
        [mSoftNoticeViewLoad setMessage:@"热点地区加载..."];
        [mSoftNoticeViewLoad setActivityindicatorHidden:NO];
        [mSoftNoticeViewLoad setHidden:YES];
        [self.view addSubview:mSoftNoticeViewLoad];
    }
    
    if(optFlag==2){
        optFlag = 1;
        //记录热点地区点击
        [self saveHotplaceClick:starHotplaceid
                   onlineuserid:(long)([DataController getOAuthEngine].username)
                 onlineusername:[DataController getUserScreenName]
                onlineuserimage:((User *)[DataController getUser]).profileImageUrl            
                    nowlatitude:[DataController getDefaultLatitude] 
                    nowlongtude:[DataController getDefaultLongitude]
                     nowaddress:[[NSString alloc] initWithFormat:@"%@",[DataController getMinLocationDescription]]];        
    }else if(optFlag==3){
        NSLog(@"--------热点全新地区保存--------");
        optFlag = 1;
        //热点地区加星
        [self  saveStarHotplace:-1
                    description:mHotplaceDescription
                   onlineuserid:(long)([DataController getOAuthEngine].username)
                 onlineusername:[DataController getUserScreenName]
                onlineuserimage:((User *)[DataController getUser]).profileImageUrl            
                    nowlatitude:[DataController getDefaultLatitude] 
                    nowlongtude:[DataController getDefaultLongitude]
                     nowaddress:[[NSString alloc] initWithFormat:@"%@",[DataController getMinLocationDescription]]
                    nowprovince:@""]; 
    }
    [self addData];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    mSoftNoticeViewLoad= nil;
    [mSoftNoticeViewLoad release];
    mLoadMoreAIView    = nil;
    [mLoadMoreAIView release];
    mLoadMoreImageView = nil;
    [mLoadMoreImageView release];
}
#pragma mark -
#pragma mark - 初始化操作
/**初始化查询条件**/
/**初始化查询条件**/
- (void)initMQueryCondition
{
    mQueryCondition.startpage = 1;
    mQueryCondition.count     = 30;
}

/**初始化热点数据**/
- (void)initMPlaceData
{
    mCurrentPlaceId = MAX_LONG_LONG_INT;
    mPlacesCount = 0;
}

#pragma mark -
#pragma mark - 其他相关操作

/**刷新数据**/
- (void)addData
{
    [self initMQueryCondition];
    [self loadHotPlaceBegin]; 
}

/**修改列表展示形式**/
- (void) changeListStyle: (id)sender{
    int selectedSegment = [sender selectedSegmentIndex];
    switch (selectedSegment) 
    {
        case 0:
            mHotStyle = 1;  
            [sender setImage:[UIImage imageNamed:@"tab_l_press.png"] forSegmentAtIndex:0];
            [sender setImage:[UIImage imageNamed:@"tab_r_nor.png"] forSegmentAtIndex:1];
            [mPlaces removeAllObjects];
            [self refreshData];
            [self tableViewBegin];
            break;
        case 1:
            mHotStyle = 2; 
            [sender setImage:[UIImage imageNamed:@"tab_l_nor.png"] forSegmentAtIndex:0];
            [sender setImage:[UIImage imageNamed:@"tab_r_press.png"] forSegmentAtIndex:1];
            [mPlaces removeAllObjects];
            [self refreshData];
            [self tableViewBegin];
            break;
        default:
            break;
    }
}


/**回到头部**/
- (void)backToHead 
{
    [self tableviewScrollToTop:YES];
}
#pragma mark -
#pragma mark - 展示数据 之 [列表展示]
/**列表开始展示**/
- (void) tableViewBegin
{
    [mSortTableView reloadData];
}

/**到顶部**/
- (void)tableviewScrollToTop:(BOOL)animated 
{
    [mSortTableView setContentOffset:CGPointMake(0,0) animated:animated];
}

/**生成列表表格 Height**/
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{  
    return 60.f;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    int placecount = [mPlaces count];
    if ([self ifCanLoadMore]) 
        placecount ++ ;
    return placecount;
}


/**生成列表表格**/
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row < [mPlaces count]) {
        HotPlaceNewCell *cell = (HotPlaceNewCell *)[tableView dequeueReusableCellWithIdentifier:@"cell_hotplace"];
        if (cell == nil) {
            cell = [[HotPlaceNewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell_hotplace"];
        }
        HotPlace * wl = [mPlaces objectAtIndex:indexPath.row];
        cell.placeinfo.text   = wl.title;
        cell.starComment.text = wl.descrption;
        cell.starAmount.text  = [NSString stringWithFormat:@"%lld",wl.starNum];
        
        [cell sizeToFit];
        return cell;
    }else if(indexPath.row == [mPlaces count]){   
        
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
        [loadMoreLabel setText:@"上拉查看更多"];
        [cell addSubview:loadMoreLabel];
        [loadMoreLabel release];
        
        UIButton * loadMoreButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [loadMoreButton setFrame:CGRectMake(80.f, 0.f, 160.f, 60.f)];
        [loadMoreButton setBackgroundColor:[UIColor clearColor]];
        [loadMoreButton addTarget:self action:(@selector(loadMoreData)) forControlEvents:UIControlEventTouchUpInside];
        [cell addSubview:loadMoreButton];
        
        return cell;
    }else {
        UITableViewCell * cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"cell_place_other"];
        if (cell == nil){
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                           reuseIdentifier:@"cell_place_other"] autorelease];
        }
        return cell;
    }
} 

/**表格点击事件处理,查热点地区微博信息**/
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    if (indexPath.row < [mPlaces count]) {
        HotPlace * hotPlace = [mPlaces objectAtIndex:indexPath.row];
        //设置地点
        float lat = hotPlace.latitude;
        float lon = hotPlace.longitude;
        MKCoordinateRegion mRegion;   
        mRegion.center.longitude = lon;
        mRegion.center.latitude = lat;
        [DataController setDefaultRegion:mRegion];
        [DataController setDefaultLatitude:lat];
        [DataController setDefaultLongitude:lon];
        [DataController setMinLocationDescription:[[NSString alloc] initWithFormat:@"%@",hotPlace.title]];
        [DataController setLocationDescription:[[NSString alloc] initWithFormat:@"这里是：%@",hotPlace.title]];
        
        //记录热点地区点击
        [self saveHotplaceClick:hotPlace.placeId
                   onlineuserid:(long)([DataController getOAuthEngine].username)
                 onlineusername:[DataController getUserScreenName]
                onlineuserimage:((User *)[DataController getUser]).profileImageUrl            
                    nowlatitude:[DataController getDefaultLatitude] 
                    nowlongtude:[DataController getDefaultLongitude]
                     nowaddress:[[NSString alloc] initWithFormat:@"%@",[DataController getMinLocationDescription]]];
        //跳转到身边
        [DataController setShenbianVCNeedRefreash:YES];
        if(mISpushorShow == 1) {
            [self.navigationController popViewControllerAnimated:YES];
        } else {
            [self.tabBarController setSelectedIndex:0];
        }
        
        
    }
}
#pragma mark -
#pragma mark - 加载更多
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
    [self loadHotPlaceBegin]; 
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
    [self loadHotPlaceBegin];
    
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
    return (mQueryCondition.startpage <= STATUSDATA_MAX_PAGE && [mPlaces count] > 0 && [mPlaces count] < mPlacesCount);
}

/**热点地区列表中加星操作**/
- (void)addStarForHotplace:(id)sender 
{
    UIButton * picButton = (UIButton *)sender;
    int btnTag = picButton.tag;
    HotPlace  * hotplace = [mPlaces objectAtIndex:btnTag];
    //加星操作
    [self  saveHotplaceStar:hotplace.placeId
               onlineuserid:(long)([DataController getOAuthEngine].username)
             onlineusername:[DataController getUserScreenName]
            onlineuserimage:((User *)[DataController getUser]).profileImageUrl            
                nowlatitude:[DataController getDefaultLatitude] 
                nowlongtude:[DataController getDefaultLongitude]
                 nowaddress:[[NSString alloc] initWithFormat:@"%@",[DataController getMinLocationDescription]]]; 
    
}
#pragma mark - 
#pragma mark - Weiex 接口处理方法 
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
/**记录热点地区《普通》加星事件**/
- (void)saveHotplaceStar:(long long) hotplaceid 
            onlineuserid:(long)userid  
          onlineusername:(NSString *)username
         onlineuserimage:(NSString *)userimageurl 
             nowlatitude:(double)geolat 
             nowlongtude:(double)geolng 
              nowaddress:(NSString *)address
{
    WeiexClient * mWeiexClient= [[WeiexClient alloc] initWithDele:self];
    [mWeiexClient saveClickNum:5 
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


/**根据参数获取热点地区列表**/
- (void)loadHotPlaceBegin
{
    WeiexClient * mWeiexClient= [[WeiexClient alloc] initWithTarget:self action:@selector(loadHotPlaceFinished:json:)]; 
    switch(mHotStyle)
    {
        case 1://最新热点地区
            [mWeiexClient getHotplaceList:1 
                                  pagenum:mQueryCondition.startpage 
                                 pagesize:mQueryCondition.count];            
            break;
        case 2://最热热点地区
            [mWeiexClient getHotplaceList:2 
                                  pagenum:mQueryCondition.startpage 
                                 pagesize:mQueryCondition.count];            
            break;
        default:
            [mWeiexClient getHotplaceList:1 
                                  pagenum:mQueryCondition.startpage 
                                 pagesize:mQueryCondition.count];                
            break;
    }
}

- (void)loadHotPlaceFinished:(WeiexClient *)sender
                        json:(NSDictionary*)json
{
    if (json != nil)
    {
        
        NSString * returnflag = [json valueForKey:@"resultflag"];
        if([returnflag isEqualToString:@"200"]){
            //清理数据
            if (mLoadingDataType == 1) {
                [self initMPlaceData];
            }
            NSMutableArray * hotPlaceTemp = [[NSMutableArray alloc]init];  
            int intTemp = 0;
            NSArray * items = (NSArray *)[(NSDictionary *)json objectForKey:@"resultvalue"];
            mPlacesCount = [[json valueForKey:@"resultnum"] intValue];
            for (NSDictionary * item in items) {
                
                HotPlace * hotPlace = [[HotPlace alloc] init];
                NSString * strHid = [item objectForKey:@"hotpId"];
                hotPlace.placeId = [strHid longLongValue];
                hotPlace.title = [item objectForKey:@"hotpName"]; 
                hotPlace.descrption = [item objectForKey:@"hotpDetail"]; 
                NSString * strHlng = [item objectForKey:@"hotpGeolng"]; 
                hotPlace.longitude = [strHlng doubleValue];
                NSString * strHlat= [item objectForKey:@"hotpGeolat"]; 
                hotPlace.latitude = [strHlat doubleValue];
                NSString * strHClick = [item objectForKey:@"hotpClickNum"];
                hotPlace.clickNum = [strHClick longLongValue];
                NSString * strHStar = [item objectForKey:@"hotpStarNum"];
                hotPlace.starNum = [strHStar longLongValue];
                [hotPlaceTemp addObject:hotPlace];            
                [hotPlace release];
                intTemp++;
                mCurrentPlaceId = hotPlace.placeId;
            }
            //有网络，存缓存
            [DataController setHotPlace:hotPlaceTemp];
            mPlaces = hotPlaceTemp;
        }
        else{
//            [self alert:@"网络异常"];
            //无网络，用缓存
            mPlaces = [DataController getHotPlace];
        }
        
    }
    else{
        [self alert:@"网络异常"];
    }
    [self beforeRefreshData];
    [self endLoadData];
}

#pragma mark - 
#pragma mark - 辅助功能函数

/**提示框**/
- (void)alert:(NSString *)message
{
    
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
}

@end

