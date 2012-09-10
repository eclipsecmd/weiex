//
//  TansuoRootViewController.m
//  WeiTansuo
//
//  Created by chishaq on 11-8-22.
//  Copyright 2011年 Invidel. All rights reserved.
//

#import "TansuoRootViewController.h"
#import "GoogleLocalObject.h"
#import "GTMNSString+URLArguments.h"

@implementation TansuoRootViewController

@synthesize oAuthEngine = mOAuthEngine;
@synthesize region = mRegion;
@synthesize statuses = mStatuses;
@synthesize searchLocations = mSearchLocations;

#pragma mark - 构造与析构

- (id)init
{
    self = [super init];
    if (self) {
        mOAuthEngine = [DataController getOAuthEngine];
        mGoogleLocalConnection = [[GoogleLocalConnection alloc] initWithDelegate:self];
        mKeyword = [[NSString alloc] init];
        mStatuses = [[NSMutableArray alloc] init];
        mSearchLocations = [[NSMutableArray alloc] init]; 
        mIsFirstLoadData = YES;
        //设置tabBar标题，背景图
        self.title = @"探索";
        UITabBarItem * tabBarItem = [[UITabBarItem alloc] initWithTitle:@"探索" 
                                                                image:[UIImage imageNamed:@"exploreGlobe.png"]
                                                                  tag:3];
        self.tabBarItem = tabBarItem;
        [tabBarItem release];
    }
    return self;
}

- (void)dealloc
{
    [mMapView release];
    [mKeywordTextField release];
    [mKeywordInputView release];
    [mKeyword release];
    [mToolbar release];
    [mSearchLocations release];
    [mStatuses release];
    [mGoogleLocalConnection release];
    [super dealloc];
}

#pragma mark -
#pragma mark - 视图

- (void)loadView
{
    
    [super loadView];
    //加载工具条
    if(!mToolbar) {
        mToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0.f, 0.f, 320.f, 44.f)];
        UIBarButtonItem * searchButton = [[UIBarButtonItem alloc] 
                           initWithTitle:@"搜索" 
                           style:UIBarButtonItemStyleBordered
                           target:self
                           action:@selector(toSearch)];
        UIBarButtonItem * refreshButton = [[UIBarButtonItem alloc] 
                                          initWithTitle:@"刷新" 
                                          style:UIBarButtonItemStyleBordered
                                          target:self
                                          action:@selector(refreshData)];
        NSArray * toolItems = [[NSArray alloc] initWithObjects:searchButton,refreshButton,nil];
        mToolbar.items = toolItems;
        [mToolbar sizeToFit];
        [refreshButton release];
        [searchButton release];
        [toolItems release];
    }
    [self.view addSubview:mToolbar];
    
    //设置搜索弹出框
    if(!mKeywordInputView) {
        mKeywordInputView = [[UIAlertView alloc] initWithTitle:@"请输入地点"
                                                       message:@"\n\n\n" 
                                                      delegate:self 
                                             cancelButtonTitle:@"取消" 
                                             otherButtonTitles:@"搜索", nil];
        mKeywordTextField = [[UITextField alloc] initWithFrame:CGRectMake(12.0, 50.0, 260.0, 25.0)];
        mKeywordTextField.delegate = self;
        mKeywordTextField.placeholder = @"地点";
        mKeywordTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
        mKeywordTextField.autocorrectionType = UITextAutocorrectionTypeNo;
        mKeywordTextField.returnKeyType = UIReturnKeyGo;
        mKeywordTextField.keyboardType = UIKeyboardTypeDefault;
        [mKeywordTextField setBackgroundColor:[UIColor whiteColor]];
        [mKeywordInputView addSubview:mKeywordTextField];
        CGAffineTransform mTransform = CGAffineTransformMakeTranslation(0.0, 0.0);
        [mKeywordInputView setTransform:mTransform];
    }
    else {
        mKeywordInputView.title = @"请输入地点";
        mKeywordTextField = nil;
    }
    [mKeywordTextField becomeFirstResponder];
    
    //设置地图视图
    if (!mMapView) {
        CGRect mapFrame = self.view.frame;
        mapFrame.size.height -= 44.f+44.f;
        mapFrame.origin.y = 44.f;
        mMapView = [[MKMapView alloc] initWithFrame:mapFrame];
        mMapView.centerCoordinate = mRegion.center;
        mMapView.delegate = self;
        mMapView.showsUserLocation = NO;
    }
    [self.view addSubview:mMapView];
}

/**(此阶段隐藏工具条)**/
- (void)viewWillAppear:(BOOL)animated  
{  
    [super viewWillAppear:animated];  
    //隐藏导航条
    [self.navigationController setNavigationBarHidden:YES]; 
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    //-----初始化数据-----//
    //初始化当前地图中心
    [self initMRegion];
    //-----主流程开始-----//
    //开始获取默认数据
    [self loadDataBegin];
}

- (void)viewDidUnload
{
    [mMapView release];
    [mKeywordInputView release];
    [mKeywordTextField release];
    [mToolbar release];
    [super viewDidUnload];
}

#pragma mark -
#pragma mark - 自定义初始化函数
/**初始化地图中心**/
- (void)initMRegion
{
    mRegion = [DataController getDefaultRegion];    
    [mSearchLocations removeAllObjects];
    WLocation * wLocation = [[WLocation alloc] init];
    wLocation.latitude = mRegion.center.latitude;
    wLocation.longitude = mRegion.center.longitude; 
    wLocation.title = @"中心";
    wLocation.subtitle = @"鸟巢";
    [mSearchLocations insertObject:wLocation atIndex:0];
    [wLocation release];
}



#pragma mark - 
#pragma mark - 获取数据

/**开始获取数据**/
- (void)loadDataBegin
{
    WeiboClient * weiboClient= [[[WeiboClient alloc] initWithTarget:self 
                                                   engine:mOAuthEngine
                                                   action:@selector(loadDataFinished:obj:)] retain];   
    
    [weiboClient getLocationStatusesRange:[DataController getKLocateSelfDistence]
                                 longitude:mRegion.center.longitude
                                  latitude:mRegion.center.latitude 
                                      time:0 
                                  sortType:1
                            startingAtPage:1
                                     count:50
                                   baseApp:0];
    [weiboClient release];
}
/**数据获取结束，数据存入内存，准备展示数据(代理)**/
- (void)loadDataFinished:(WeiboClient*)sender
                     obj:(NSObject*)obj
{
    if (sender.hasError) {
		[sender alert];
        
        if (sender.statusCode == 401) {
            
        }
         
    }
    else {
        //存储微博数据
        NSArray * ary = [(NSDictionary *)obj objectForKey:@"statuses"];
        [mStatuses removeAllObjects]; 
        for (int i = [ary count] - 1; i >= 0; --i) {
            NSDictionary *dic = (NSDictionary*)[ary objectAtIndex:i];
            if (![dic isKindOfClass:[NSDictionary class]]) {
                continue;
            }
            Status* sts = [Status statusWithJsonDictionary:[ary objectAtIndex:i] MyRegion:mRegion];
            [mStatuses insertObject:sts atIndex:0];
        }
        //展示数据
        [self mapViewBegin];
    }
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
        int index = 0;
        //中心位置
        for (WLocation * wLocation in mSearchLocations) {
            LocationAnnotation * annotaion = [[LocationAnnotation alloc] init];
            annotaion.wLocation = wLocation;
            annotaion.indexTag = index;
            [mMapView addAnnotation:annotaion];
            [annotaion release];
            index ++;
        }
        //微博数据位置
        index = 0;
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
                        action:@selector(toStatusDetailView:)
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
        //设置当前点击的wLocation,更新地图中心,生成按钮
//        UIButton * detailButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
//        [detailButton addTarget:self
//                       action:@selector(toReloadWeiboData:)
//              forControlEvents:UIControlEventTouchUpInside];
//        pinView.rightCalloutAccessoryView = detailButton;
        return pinView;
        
    }else{
        return nil;
    }
}


#pragma mark - 
#pragma mark - 事件处理 之 [地图事件（刷新，详细，搜索加载,筛选）]

/**查看微博的详细信息**/
- (void)toStatusDetailView:(id)sender 
{    
    UIButton * detailButton = sender;
    int index = detailButton.tag;
    StatusDetailViewController * statusDetailViewController = [[StatusDetailViewController alloc] init];
    statusDetailViewController.status = [mStatuses objectAtIndex:index];
    statusDetailViewController.oAuthEngine = mOAuthEngine;
    [statusDetailViewController setHidesBottomBarWhenPushed:YES];
    [self.navigationController pushViewController:statusDetailViewController animated:YES];
    [statusDetailViewController release];
    
}
/**根据搜索后选择的地点，重新加载微博数据**/
- (void)toReloadWeiboData:(id)sender
{
//    LocationAnnotationButton * locationAnnotationButton = (LocationAnnotationButton *) sender;
//    mRegion.center.longitude = locationAnnotationButton.wLocation.longitude;
//    mRegion.center.latitude = locationAnnotationButton.wLocation.latitude;
    [self loadDataBegin];
}
/**刷新微博数据**/
- (void)refreshData
{
    [self initMRegion];
    [self loadDataBegin];
}
/**筛选数据为[所有]**/
- (void)filterDataToAll
{
    
}
/**筛选数据为［图片］**/
- (void)filterDataToImage
{
    
}


#pragma mark - 
#pragma mark - 事件处理 之 ［地理位置搜索部分］

/**搜索事件**/
- (void) toSearch
{
    [mKeywordInputView show];
}
/**点击弹出框按钮事件（UIAlertViewDelegate 接口）**/
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    //点击搜索按钮
    if (buttonIndex==1) {
        //请求google api，获取搜索结果
        [mGoogleLocalConnection getGoogleObjectsWithQuery:mKeywordTextField.text 
                                             andMapRegion:[DataController getDefaultSearchRegion]
                                       andNumberOfResults:8 
                                            addressesOnly:NO 
                                               andReferer:@"http://www.weiex.com"];
    }
}
/**请求google api 成功的回调（代理）**/
- (void)googleLocalConnection:(GoogleLocalConnection *)conn didFinishLoadingWithGoogleLocalObjects:(NSMutableArray *)objects andViewPort:(MKCoordinateRegion)region
{
    if ([objects count] == 0) {
        UIAlertView * alert = [[UIAlertView alloc] 
                               initWithTitle:@"没有匹配结果" 
                               message:@"请尝试另外一个地址！" 
                               delegate:nil 
                               cancelButtonTitle:@"确定" 
                               otherButtonTitles: nil];
        [alert show];
        [alert release];
    } 
    //-----搜索地点结果更新,微博数据清空,并在地图显示，以供用户选择-----//
    else{
       
        //搜索地点结果更新
        [mSearchLocations removeAllObjects];
        double newLatitudeMean = 0;
        double newLongtitudeMean = 0;
        double newLatitudeMax = 0;
        double newLatitudeMin = 1000;
        double newLongtitudeMax = 0;
        double newLongtitudeMin = 1000;
        int resultcount = 0;
        for (GoogleLocalObject * obj in objects) {
            if (![obj isKindOfClass:[GoogleLocalObject class]]) {
                continue;
            }
            WLocation * wLocation = [[WLocation alloc] init];
            wLocation.latitude = obj.coordinate.latitude;
            wLocation.longitude = obj.coordinate.longitude;
            wLocation.title = obj.titles;
            wLocation.subtitle = obj.subtitles;
            wLocation.streetAddress = obj.streetAddress;
            wLocation.city = obj.city;
            wLocation.region = obj.region;
            wLocation.country = obj.country;
            [mSearchLocations insertObject:wLocation atIndex:0];
            [wLocation release];
            
            //记录新地址均值及最大最小值
            newLatitudeMean += obj.coordinate.latitude;
            newLongtitudeMean += obj.coordinate.longitude;
            if (obj.coordinate.latitude > newLatitudeMax) {
                newLatitudeMax = obj.coordinate.latitude;
            }else if (obj.coordinate.latitude < newLatitudeMin) {
                newLatitudeMin = obj.coordinate.latitude;
            }
            if (obj.coordinate.latitude > newLongtitudeMax) {
                newLongtitudeMax = obj.coordinate.latitude;
            }else if (obj.coordinate.latitude < newLongtitudeMin) {
                newLongtitudeMin = obj.coordinate.latitude;
            }
            resultcount ++;
        }
        //微博数据清空
        [mStatuses removeAllObjects];
        //更新地图中心(位置及精度)，地图刷新
        mRegion.center.latitude = newLatitudeMean/resultcount;
        mRegion.center.longitude = newLongtitudeMean/resultcount;
        if(resultcount > 1) {
            if ((newLatitudeMax -newLatitudeMin)> mRegion.span.latitudeDelta) {
                mRegion.span.latitudeDelta = (newLatitudeMax -newLatitudeMin)*1.6;
            }
            if ((newLongtitudeMax -newLongtitudeMin)> mRegion.span.latitudeDelta) {
                mRegion.span.longitudeDelta = (newLongtitudeMax -newLongtitudeMin)*1.6;
            }
        }
        [self loadDataBegin];
    }
    //
}
/**请求google api 失败的回调（delegate）**/
- (void) googleLocalConnection:(GoogleLocalConnection *)conn didFailWithError:(NSError *)error
{
    UIAlertView *alert = [[UIAlertView alloc] 
                          initWithTitle:@"Error finding place - Try again" 
                          message:[error localizedDescription] 
                          delegate:nil 
                          cancelButtonTitle:@"OK" 
                          otherButtonTitles: nil];
    [alert show];
    [alert release];
}

#pragma mark - 
#pragma mark - 事件处理 之 ［3秒触摸屏幕事件（处理地点选择）］

@end
