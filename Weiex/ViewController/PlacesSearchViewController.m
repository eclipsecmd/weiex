//
//  PlacesViewController.m
//  WeiTansuo
//
//  Created by HYQ on 9/21/11.
//  Copyright 2011 Invidel. All rights reserved.
//

#import "PlacesSearchViewController.h"
#import <QuartzCore/QuartzCore.h>

#define MAX_LONG_LONG_INT 9999999999999999
#define MAX_LOCATE_TIME 4


@implementation PlacesSearchViewController

@synthesize finishTarget,finishAction;
@synthesize _searchStr;

- (id)init
{
    self = [super init];
    if(self) {
        mGoogleLocalConnection = [[GoogleLocalConnection alloc] initWithDelegate:self];
        mSearchLocations = [[NSMutableArray alloc] init];       
        mIsFirstLoadData = NO;
        
        //pick below, pick datasource init
        mRangeSelectTitles = [[NSArray alloc] initWithObjects:@"1000",@"1500",@"2000",@"2500",@"3000",@"3500",@"4000",@"4500",@"5000",@"5500",@"6000",@"6500",@"7000",@"7500",@"8000",@"8500",@"9000",@"9500",@"10000", nil];
        //time
        mTimelineTitles = [[NSArray alloc] initWithObjects:@"最新" ,@"1小时", @"3小时", @"8小时", @"1天前", @"2天前", @"5天前", @"10天前", @"20天前", @"1个月前", @"2个月前", @"很久以前", nil];
        mTimelineTitlesValues = [[NSArray alloc] initWithObjects:@"0", @"60", @"180", @"480", @"1440", @"2880", @"7200", @"14400", @"28800", @"43200", @"86400", @"172800", nil];
        
        
    }
    return self;
}

- (void)dealloc
{
    [super dealloc];
    [mDisableViewOverlay release];
    [mSearchLocations release];
    [mSearchBar release];
    [mSearchInstant release];
    [mSoftNoticeViewLoad release];
    [mMapView release];
    [mGoogleLocalConnection release];
    [mShowPickRangeLabel release];
    [mShowPickTimelineLabel release];
    [mBelowView release];
//    [mBigView release];
    
    //below is uipicker
    [mRangeSelectView release];
    
    [mRangeSelectTitles release];
    [mTimelineTitles release];
    [mTimelineTitlesValues release];
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
    
    //背景
    UIImageView * bgImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bg.png"]];
    [bgImageView setFrame:CGRectMake(0.f, -20.f, 320.f, 480.f)];
    [self.view addSubview:bgImageView];
    [bgImageView release];
    
    //返回按钮
    UIButton * backButton = [[UIButton alloc] initWithFrame:CGRectMake(9, 9, 26, 26)];
    [backButton setImage:[UIImage imageNamed:@"title_icon_5_nor.png"] forState:UIControlStateNormal];
    [backButton setImage:[UIImage imageNamed:@"title_icon_5_press.png"] forState:UIControlStateHighlighted];
    [backButton addTarget:self action:@selector(cancel) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:backButton];
    [backButton release];
    
    //头部中间标题
    UILabel * titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(85, 7, 150, 30)];
    titleLabel.textAlignment = UITextAlignmentCenter;
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.text = @"查找位置";
    titleLabel.font = [UIFont fontWithName:@"TrebuchetMS-Bold" size:20];
    titleLabel.textColor = [UIColor whiteColor];
    [self.view addSubview:titleLabel];
    [titleLabel release]; 
    
    //搜索-搜索条
    if (!mSearchBar) {
        mSearchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(6, 45, 308, 44)];
        mSearchBar.delegate = self;
        mSearchBar.barStyle = UIBarStyleBlackOpaque;
        mSearchBar.backgroundColor = [UIColor clearColor];
        [mSearchBar setBackgroundImage:[UIImage imageNamed:@"seach_bg.png"]];
        [[mSearchBar.subviews objectAtIndex:0] removeFromSuperview];
        [self.view addSubview:mSearchBar];
        
        //别针
        UIImageView * clipImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Clip_img.png"]];
        [clipImageView setFrame:CGRectMake(270, -10, 36, 36)];
        [mSearchBar addSubview:clipImageView];
        [clipImageView release];
    }
    //搜索-
    if (!mSearchInstant) {
        mSearchInstant = [[searchInstant alloc] initWithStyle:UITableViewStylePlain];
        mSearchInstant._delegate = self;
        [mSearchInstant.view setFrame:CGRectMake(30, 44, 250, 0)];
        [mSearchInstant.view setBackgroundColor:[UIColor whiteColor]];
        _searchStr = [[NSString alloc] initWithString:@""];
        [mSearchBar insertSubview:mSearchInstant.view atIndex:0];
        
    }
    //搜索-半透明蒙板
    if (!mDisableViewOverlay) {
        mDisableViewOverlay = [[UIView alloc] initWithFrame:CGRectMake(0, 89, 320, 317)];  
        mDisableViewOverlay.backgroundColor=[UIColor blackColor];  
        mDisableViewOverlay.alpha = 0; 
    }
    
    //搜索-
//    if (!mBigView) {
//        CGRect mBigViewFrame = self.view.frame;
//        mBigViewFrame.origin.y = 0;
//        [mBigView setAlpha:0.9f];
//        mBigView = [[UIView alloc] initWithFrame:mBigViewFrame];
//        [mBigView setBackgroundColor:[UIColor blackColor]];
//        [mBigView insertSubview:mBelowView atIndex:0];
//        [mBigView insertSubview:mMapView atIndex:1];
//        [self.view insertSubview:mBigView atIndex:0];
//        
//    }
    
    //地图视图
    if (!mMapView) {
        mMapView = [[MKMapView alloc] initWithFrame:CGRectMake(6, 89, 308, 372)];
        mMapView.centerCoordinate = mMapCenterRegion.center;
        mMapView.delegate = self;
        mMapView.showsUserLocation = YES;
        [mMapView.userLocation setTitle:@"我在这里"];
        [self.view addSubview:mMapView];
        //地图长按事件
        UILongPressGestureRecognizer * tap = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(tapLongPress:)];
        [mMapView addGestureRecognizer:tap];
        [tap release];
    }
       
    //时间范围选择器
    mCancelButtonForRangeSelectView = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [mCancelButtonForRangeSelectView setFrame:CGRectMake(20, 105, 120, 30)];
    [mCancelButtonForRangeSelectView setTitle:@"取消" forState:UIControlStateNormal];
    [mCancelButtonForRangeSelectView addTarget:self action:(@selector(getCancelPick)) forControlEvents:UIControlEventTouchUpInside];  
    mDoneButtonForRangeSelectView = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [mDoneButtonForRangeSelectView setFrame:CGRectMake(180, 105, 120, 30)];
    [mDoneButtonForRangeSelectView setTitle:@"确定" forState:UIControlStateNormal];
    [mDoneButtonForRangeSelectView addTarget:self action:(@selector(getDonePick)) forControlEvents:UIControlEventTouchUpInside];
    if (!mRangeSelectView) {
        mRangeSelectView = [[UIPickerView alloc] init];
        [mRangeSelectView setFrame:CGRectMake(0, 145, 320, 216)];
        [mRangeSelectView setBackgroundColor:[UIColor clearColor]];
        [mRangeSelectView setShowsSelectionIndicator:YES];
        [mRangeSelectView setDelegate:self];
        //[mRangeSelectView setDataSource:self];
        [mRangeSelectView setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didselValuesChange) name:@"didselValuesChange" object:nil]; 
    }
    if (!mBelowView) {
        mBelowView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 460)];
        [mBelowView setBackgroundColor:[UIColor blackColor]];
        [mBelowView addSubview:mCancelButtonForRangeSelectView];
        [mBelowView addSubview:mDoneButtonForRangeSelectView];
        [mBelowView addSubview:mRangeSelectView];  
    }
    
    //底部条
    UIView * bottomView = [[UIView alloc] init];
    [bottomView setFrame:CGRectMake(0, 416, 320, 44)];
    [bottomView setBackgroundColor:[UIColor blackColor]];
    [bottomView setAlpha:0.9];
    //底部条-定位
    UIButton * locateButton = [[UIButton alloc] initWithFrame:CGRectMake(20, 5, 33, 33)];
    [locateButton setImage:[UIImage imageNamed:@"tab_icon_5_nor.png"] forState:UIControlStateNormal];
    [locateButton setImage:[UIImage imageNamed:@"tab_icon_5_press.png"] forState:UIControlStateHighlighted];
    [locateButton addTarget:self action:@selector(toUserCurrentLocation) forControlEvents:UIControlEventTouchUpInside];
    [bottomView addSubview:locateButton];
    [locateButton release];
    //底部条-范围按钮
    UIButton * rangeTitleButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [rangeTitleButton setFrame:CGRectMake(65, 5, 105, 34)];
    [rangeTitleButton setBackgroundImage:[UIImage imageNamed:@"Distance_button_nor.png"] forState:UIControlStateNormal];
    [rangeTitleButton setBackgroundImage:[UIImage imageNamed:@"Distance_button_press.png"] forState:UIControlStateHighlighted];
    [rangeTitleButton addTarget:self action:@selector(toPickerView) forControlEvents:UIControlEventTouchUpInside];
    [bottomView addSubview:rangeTitleButton];
    //底部条-时间按钮
    UIButton * timelineTitleButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [timelineTitleButton setFrame:CGRectMake(185, 5, 105, 34)];
    [timelineTitleButton setBackgroundImage:[UIImage imageNamed:@"time_button_nor.png"] forState:UIControlStateNormal];
    [timelineTitleButton setBackgroundImage:[UIImage imageNamed:@"time_button_press.png"] forState:UIControlStateHighlighted];
    [timelineTitleButton addTarget:self action:@selector(toPickerView) forControlEvents:UIControlEventTouchUpInside];
    [bottomView addSubview:timelineTitleButton];
    //底部条-范围
    if (!mShowPickRangeLabel) {
        mShowPickRangeLabel = [[UILabel alloc] initWithFrame:CGRectMake(50, 19, 70, 11)];
        [mShowPickRangeLabel setFont:[UIFont fontWithName:@"Arial" size:10]];
        [mShowPickRangeLabel setText:[NSString stringWithFormat:@"%d米",[DataController getKLocateSelfDistence]]];
        [mShowPickRangeLabel setBackgroundColor:[UIColor clearColor]];
        [mShowPickRangeLabel setTextColor:[UIColor colorWithRed:220/255.f green:220/255.f blue:220/255.f alpha:1]];
        [mShowPickRangeLabel setAdjustsFontSizeToFitWidth:YES];
        [mShowPickRangeLabel setTextAlignment:UITextAlignmentLeft];
        [rangeTitleButton addSubview:mShowPickRangeLabel];
        
        UILabel * rangeTitleLable = [[UILabel alloc] initWithFrame:CGRectMake(50, 5, 70, 11)];
        [rangeTitleLable setFont:[UIFont fontWithName:@"Arial" size:10]];
        [rangeTitleLable setText:@"范围"];
        [rangeTitleLable setBackgroundColor:[UIColor clearColor]];
        [rangeTitleLable setTextColor:[UIColor grayColor]];
        [rangeTitleLable setTextAlignment:UITextAlignmentLeft];
        [rangeTitleButton addSubview:rangeTitleLable];
        [rangeTitleLable release];
    }
    //底部条-时间   
    if (!mShowPickTimelineLabel) {
        mShowPickTimelineLabel = [[UILabel alloc] initWithFrame:CGRectMake(50, 19, 70, 11)];
        [mShowPickTimelineLabel setFont:[UIFont fontWithName:@"Arial" size:10]];
        [mShowPickTimelineLabel setText:[NSString stringWithFormat:@"%@",[self getTimelineTitleByValue:[DataController getTimeline]]]];
        [mShowPickTimelineLabel setAdjustsFontSizeToFitWidth:YES];
        [mShowPickTimelineLabel setBackgroundColor:[UIColor clearColor]];
        [mShowPickTimelineLabel setTextColor:[UIColor colorWithRed:220/255.f green:220/255.f blue:220/255.f alpha:1]];
        [mShowPickTimelineLabel setTextAlignment:UITextAlignmentLeft];
        [timelineTitleButton addSubview:mShowPickTimelineLabel];
        
        UILabel * timelineTitleLable = [[UILabel alloc] initWithFrame:CGRectMake(50, 5, 70, 11)];
        [timelineTitleLable setFont:[UIFont fontWithName:@"Arial" size:10]];
        [timelineTitleLable setText:@"时间"];
        [timelineTitleLable setBackgroundColor:[UIColor clearColor]];
        [timelineTitleLable setTextColor:[UIColor grayColor]];
        [timelineTitleLable setTextAlignment:UITextAlignmentLeft];
        [timelineTitleButton addSubview:timelineTitleLable];
        [timelineTitleLable release];
    }
    
    [self.view addSubview:bottomView];
    [bottomView release];

    //加载框
    if (!mSoftNoticeViewLoad) {
        mSoftNoticeViewLoad = [[SoftNoticeView alloc] initWithFrame:CGRectMake(90, 170, 140, 140)];
        [mSoftNoticeViewLoad setMessage:@"搜索中"];
        [mSoftNoticeViewLoad setActivityindicatorHidden:NO];
        [mSoftNoticeViewLoad setHidden:YES];
        [self.view addSubview:mSoftNoticeViewLoad];
    }  
    //主流程开始
    [self initPickViewDataSource];
    [self initMRegion];
    [self initMQueryCondition];
    [self mapViewBegin];
    
}


- (void)viewDidUnload
{   
    [super viewDidUnload];
    mMapView = nil;
    [mMapView release];
    mSearchBar = nil;
    [mSearchBar release];
    mSearchInstant = nil;
    [mSearchInstant release]; 
    mShowPickRangeLabel = nil;
    [mShowPickRangeLabel release];
    mShowPickTimelineLabel = nil;
    [mShowPickTimelineLabel release];
    mBelowView = nil;
    [mBelowView release];     
}


#pragma mark -
#pragma mark - 自定义初始化函数


/**初始化选择器**/
- (void)initPickViewDataSource
{   
//    int timelinedata = [DataController getTimeline];
//    long long distances = [DataController getKLocateSelfDistence];
//    NSUInteger selectRowForTimeline = [mTimelineTitlesValues indexOfObject:(NSObject *)timelinedata];
//    if (selectRowForTimeline != NSNotFound) {
//        [mRangeSelectView selectRow:selectRowForTimeline inComponent:0 animated:YES];
//    }
//    NSUInteger selectRowForRange = [mRangeSelectTitles indexOfObject:(NSObject *)distances];
//    
//    [mRangeSelectView selectRow:selectRowForRange inComponent:1 animated:YES];
    
    
}


/**初始化地点**/
- (void)initMRegion
{
    mMapCenterRegion = [DataController getDefaultRegion];
    WLocation * wLocation = [[WLocation alloc] init];
    wLocation.latitude = mMapCenterRegion.center.latitude;
    wLocation.longitude = mMapCenterRegion.center.longitude; 
    wLocation.title = [DataController getMinLocationDescription];
    wLocation.subtitle = [DataController getMinLocationDescription];
    wLocation.guid = @"";
    [mSearchLocations removeAllObjects];
    [mSearchLocations insertObject:wLocation atIndex:0];
    [wLocation release];
}
/**初始化查询条件**/
- (void)initMQueryCondition
{
    [mSearchBar setText:@""];
}

#pragma mark -
#pragma mark - 搜索(代理)
- (BOOL)beforeSearch
{
    if (mIsloading) {
        return NO;
    }
    mIsloading = YES;
    [mSoftNoticeViewLoad setMessage:@"搜索中"];
    [mSoftNoticeViewLoad setHidden:NO];
    [mSoftNoticeViewLoad start];
    return YES;
}
- (void)endSearch
{
    [mSoftNoticeViewLoad stop];
    [mSoftNoticeViewLoad setHidden:YES];
    [self mapViewBegin];
    mIsloading = NO;
}
/**开始搜索**/
- (void)SearchBegin
{
    if (![self beforeSearch]) {
        return;
    }    
    //搜索
    [mGoogleLocalConnection getGoogleObjectsWithQuery:mSearchBar.text 
                                         andMapRegion:mMapCenterRegion
                                   andNumberOfResults:10 
                                        addressesOnly:NO 
                                           andReferer:@"http://www.weiex.com"];
}

/**请求google api 成功的回调（代理）**/
- (void)googleLocalConnection:(GoogleLocalConnection *)conn didFinishLoadingWithGoogleLocalObjects:(NSMutableArray *)objects andViewPort:(MKCoordinateRegion)region
{    
    if ([objects count] == 0) {
        [self endSearch];
        [self alert:@"没有结果"];
    } 
    //-----搜索地点结果更新,微博数据清空,并在地图显示，以供用户选择-----//
    else {
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
        
        //更新地图中心(位置及精度)，地图刷新
        mMapCenterRegion.center.latitude = newLatitudeMean/resultcount;
        mMapCenterRegion.center.longitude = newLongtitudeMean/resultcount;
        if(resultcount > 1) {
            if ((newLatitudeMax -newLatitudeMin)> mMapCenterRegion.span.latitudeDelta) {
                mMapCenterRegion.span.latitudeDelta = (newLatitudeMax -newLatitudeMin)*1.6;
            }
            if ((newLongtitudeMax -newLongtitudeMin)> mMapCenterRegion.span.latitudeDelta) {
                mMapCenterRegion.span.longitudeDelta = (newLongtitudeMax - newLongtitudeMin)*1.6;
            }
        }
        [self endSearch];
    }
    //
}

/**请求google api 失败的回调（delegate）**/
- (void) googleLocalConnection:(GoogleLocalConnection *)conn didFailWithError:(NSError *)error
{
    [self endSearch];
    [self alert:@"搜索失败"];
}

#pragma mark - 
#pragma mark - 事件处理 之 ［地理位置搜索部分］

//above is the search instant search

- (void)passValue:(NSString *)value
{
	if (value) {
		mSearchBar.text = value;
		[self searchBarSearchButtonClicked:mSearchBar];
	}
	else {
		
	}
}

- (void)setDDListHidden:(BOOL)hidden {
	NSInteger height = hidden ? 0 : 180;
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:.2];
	[mSearchInstant.view setFrame:CGRectMake(30, 44, 200, height)];
	[UIView commitAnimations];
}


- (void)searchBar:(UISearchBar *)searchBar  
    textDidChange:(NSString *)searchText 
{  
    // We don't want to do anything until the user clicks   
    // the 'Search' button.  
    // If you wanted to display results as the user types   
    // you would do that here.
    if ([searchText length] != 0) {
		mSearchInstant._searchText = searchText;
		[mSearchInstant updateData];
		[self setDDListHidden:NO];
	}
	else {
		[self setDDListHidden:YES];
	}
}  

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar 
{  
    // searchBarTextDidBeginEditing is called whenever   
    // focus is given to the UISearchBar  
    // call our activate method so that we can do some   
    // additional things when the UISearchBar shows.
    mSearchBar.text = @"";
    [self searchBar:mSearchBar activate:YES];  
}  

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar 
{  
    // searchBarTextDidEndEditing is fired whenever the   
    // UISearchBar loses focus  
    // We don't need to do anything here.  
}  

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar 
{  
    // Clear the search text  
    // Deactivate the UISearchBar
    [self setDDListHidden:YES];
	[searchBar resignFirstResponder];    
    mSearchBar.text=@"";  
    [self searchBar:mSearchBar activate:NO];  
}  

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar 
{  
    // Do the search and show the results in tableview  
    // Deactivate the UISearchBar  
    
    // You'll probably want to do this on another thread  
    // SomeService is just a dummy class representing some   
    // api that you are using to do the search
    
    [self setDDListHidden:YES];
	self._searchStr = [mSearchBar text];
	[mSearchBar resignFirstResponder];
    [self SearchBegin];
    [self searchBar:mSearchBar activate:NO];  
    
}  

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar {
	mSearchBar.showsCancelButton = YES;
	for(id cc in [searchBar subviews])
    {
        if([cc isKindOfClass:[UIButton class]])
        {
            UIButton *btn = (UIButton *)cc;
            [btn setTitle:@"取消"  forState:UIControlStateNormal];
        }
    }
	return YES;
}

// We call this when we want to activate/deactivate the UISearchBar  
// Depending on active (YES/NO) we disable/enable selection and   
// scrolling on the UITableView  
// Show/Hide the UISearchBar Cancel button  
// Fade the screen In/Out with the disableViewOverlay and   
// simple Animations  
- (void)searchBar:(UISearchBar *)searchBar activate:(BOOL) active
{    
    if (!active) {  
        [mDisableViewOverlay removeFromSuperview];
        [mSearchBar resignFirstResponder];  
    } else {  
        mDisableViewOverlay.alpha = 0;  
        [self.view addSubview:mDisableViewOverlay];  
        
        [UIView beginAnimations:@"FadeIn" context:nil];  
        [UIView setAnimationDuration:0.5];  
        mDisableViewOverlay.alpha = 0.6;  
        [UIView commitAnimations];   
    }  
    [mSearchBar setShowsCancelButton:active animated:YES];  
} 


#pragma mark -
#pragma mark - 展示数据 之 [地图展示]
/**地图开始展示**/
- (void)mapViewBegin
{
    mIsFirstLoadData = YES;
    [mMapView setRegion:mMapCenterRegion animated:YES];
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
        //设置为已加载过
        mIsFirstLoadData = NO;
        [mMapView setSelectedAnnotations:[mMapView annotations]];
    }
}
/**地图注释生成(代理)**/
- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation;
{  
    
    if([annotation isKindOfClass:[LocationAnnotation class]]){
        static NSString * LocationAnnotationIdentifier = @"LocationAnnotationIdentifier";
        
        MKPinAnnotationView * pinView = (MKPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:LocationAnnotationIdentifier];
        if (!pinView) {
            pinView = [[[MKPinAnnotationView alloc]
                        initWithAnnotation:annotation 
                        reuseIdentifier:LocationAnnotationIdentifier] autorelease];   
        }
        else {
            pinView.annotation = annotation;
        }
        pinView.canShowCallout = YES;
        //标志图片
        //UIImage * image = [UIImage imageNamed:@"locateleft.png" ];
        //pinView.image = image;
        LocationAnnotation * curAnnotation = (LocationAnnotation *) annotation;
        UIButton * detailButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        detailButton.tag = curAnnotation.indexTag;
        [detailButton addTarget:self
                         action:@selector(SelectLocationInMapView:)
               forControlEvents:UIControlEventTouchUpInside];
        pinView.rightCalloutAccessoryView = detailButton;
        return pinView;
    }
    else {
        return nil;
    }
}

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view
{
    if([view.annotation isKindOfClass:[MKUserLocation class]]) {
        UIButton * detailButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        [detailButton addTarget:self
                         action:@selector(SelectLocationInMapViewOfUserLocation)
               forControlEvents:UIControlEventTouchUpInside];
        view.rightCalloutAccessoryView = detailButton;
    }
}


#pragma mark -
#pragma mark - 事件 之 页面触摸
- (void)tapLongPress:(UIGestureRecognizer*)gestureRecognizer {
    
    if (mIsPressing) {
        return;
    }
    mIsPressing = YES;
    CGPoint touchPoint = [gestureRecognizer locationInView:mMapView];//这里touchPoint是点击的某点在地图控件中的位置
    CLLocationCoordinate2D touchMapCoordinate = [mMapView convertPoint:touchPoint toCoordinateFromView:mMapView];//这里touchMapCoordinate就是该点的经纬度了
    mMapCenterRegion.center = touchMapCoordinate;
    mMapCenterRegion.span = mMapView.region.span;
    WLocation * wLocation = [[WLocation alloc] init];
    wLocation.latitude = touchMapCoordinate.latitude;
    wLocation.longitude = touchMapCoordinate.longitude;
    wLocation.title = @"看看这里";
    wLocation.subtitle = @"这里也精彩";
    wLocation.streetAddress = @"";
    wLocation.city = @"";
    wLocation.region =@"";
    wLocation.country = @"";
    [mSearchLocations removeAllObjects];
    [mSearchLocations insertObject:wLocation atIndex:0];
    [wLocation release];
    [self mapViewBegin];
    
    [self performSelector:@selector(endLongPress) withObject:nil afterDelay:1.7f];
}
- (void)endLongPress
{
    mIsPressing = NO;
}

#pragma mark -
#pragma mark - 事件 之 按钮触发

/**打开最近最新选择器**/
- (void)toPickerView
{    
    if (mIsAlert) {
        return;
    }
    [self.view addSubview:mBelowView];
    /*
    if (mIsAlert) {
        return;
    }
    [self dismissModalViewControllerAnimated:YES];
    if ([finishTarget retainCount] > 0 && [finishTarget respondsToSelector:finishAction]) {
        [finishTarget performSelector:finishAction  withObject:@"last"];
    }
    */
//    RangePickViewController * rangepick = [[RangePickViewController alloc] init];
//    rangepick.currentRange = [DataController getKLocateSelfDistence];
//    rangepick.currentTimeline = [DataController getTimeline];
//    
//    rangepick.finishTarget = self;
//    rangepick.finishAction = @selector(changeRangeandTimeLine);
//    //[self presentModalViewController:rangepick animated:YES];
//    [rangepick presentedViewController];    
    
}

//选择器打开动画
- (void)pressCurl
{
	// Curl the image up or down
	CATransition *animation = [CATransition animation];
	[animation setDelegate:self];
	[animation setDuration:0.50];
	[animation setTimingFunction:UIViewAnimationCurveEaseInOut];
	if (!mIsCurl){
		animation.type = @"pageCurl";
		animation.fillMode = kCAFillModeForwards;
		animation.endProgress = 0.85;
    } else {
		animation.type = @"pageUnCurl";
        animation.fillMode = kCAFillModeBackwards;
		animation.startProgress = 0.30;
	}
	[animation setRemovedOnCompletion:NO];
    
//	[mBigView exchangeSubviewAtIndex:0 withSubviewAtIndex:1];
    
//	[mBigView addAnimation:animation forKey:@"pageCurlAnimation"];
    
	// Disable user interaction where necessary
	if (!mIsCurl) {

	}
	
	mIsCurl = !mIsCurl;
}

- (void)rangeSelect:(long long)range
{
    [DataController setKLocateSelfDistence:range];
    if ([finishTarget retainCount] > 0 && [finishTarget respondsToSelector:finishAction]) {
        [finishTarget performSelector:finishAction  withObject:@"range"];
    }
}

///**前往收藏页**/
//- (void)tofavPlaces
//{
//    if (mIsAlert) {
//        return;
//    }
//    if (mIsCurl) {
//        [self pressCurl];
//    }
//    FavoritePlaceViewController * favoritePlaceViewController = [[FavoritePlaceViewController alloc] init];
//    favoritePlaceViewController.finishTarget = self;
//    favoritePlaceViewController.finishAction = @selector(goFavoritesPlace:);
//    [self presentModalViewController:favoritePlaceViewController animated:YES];
//    [favoritePlaceViewController release];
//}
///**收藏页返回回调**/
//- (void)goFavoritesPlace:(WLocation *)wLocation
//{
//    CLLocationCoordinate2D touchMapCoordinate = CLLocationCoordinate2DMake(wLocation.latitude, wLocation.longitude);
//    mMapCenterRegion.center = touchMapCoordinate;
//    mMapCenterRegion.span = mMapView.region.span;
//    [mSearchLocations removeAllObjects];
//    [mSearchLocations insertObject:wLocation atIndex:0];
//    [wLocation release];
//    [self mapViewBegin];    
//}


/**退出**/
- (void)cancel
{
    if (mIsAlert) {
        return;
    }
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)cancel:(NSString *)message
{
    if (mIsAlert) {
        return;
    }
    if ([finishTarget retainCount] > 0 && [finishTarget respondsToSelector:finishAction]) {
        [finishTarget performSelector:finishAction  withObject:message];
    }    
    
    [self.navigationController popViewControllerAnimated:YES];
}

/**定位**/
- (void)toUserCurrentLocation
{
    if (mIsCurl) {
        [self pressCurl];
    }
    mMapCenterRegion.center = mMapView.userLocation.coordinate;
    mMapCenterRegion.span = mMapView.region.span;
    [mSearchLocations removeAllObjects];
    [self mapViewBegin];
}
/**地图中选择地点**/
- (void)SelectLocationInMapViewOfUserLocation
{
    if (mIsAlert) {
        return;
    }
    mMapCenterRegion.center.latitude = mMapView.userLocation.coordinate.latitude;
    mMapCenterRegion.center.longitude = mMapView.userLocation.coordinate.longitude;
    
    [DataController setDefaultRegion:mMapCenterRegion];
    [DataController setDefaultLatitude:mMapView.userLocation.coordinate.latitude];
    [DataController setDefaultLongitude:mMapView.userLocation.coordinate.longitude];
    [DataController setMinLocationDescription:[[NSString alloc] initWithFormat:@"%@",mMapView.userLocation.title]];
    [DataController setLocationDescription:[[NSString alloc] initWithFormat:@"我在：%@",mMapView.userLocation.subtitle]];
//    [self addFavPlaceEntity:mMapView.userLocation.title 
//                   latitude:mMapView.userLocation.coordinate.latitude 
//                  longitude:mMapView.userLocation.coordinate.longitude];
    [self cancel:@"location"];
}


- (void)SelectLocationInMapView:(id)sender
{
    if (mIsAlert) {
        return;
    }
    UIButton * detailButton = sender;
    int index = detailButton.tag;
    WLocation * wLocation = [mSearchLocations objectAtIndex:index];
    
    mMapCenterRegion.center.latitude = wLocation.latitude;
    mMapCenterRegion.center.longitude = wLocation.longitude;
    [DataController setDefaultRegion:mMapCenterRegion];
    [DataController setDefaultLatitude:wLocation.latitude];
    [DataController setDefaultLongitude:wLocation.longitude];
    [DataController setMinLocationDescription:[[NSString alloc] initWithFormat:@"%@",wLocation.title]];
    [DataController setLocationDescription:[[NSString alloc] initWithFormat:@"我在：%@",wLocation.subtitle]];
//    [self addFavPlaceEntity:wLocation.title 
//                   latitude:wLocation.latitude 
//                  longitude:wLocation.longitude];
    [self cancel:@"location"];
}
/**选择的地点入数据库**/
- (void)addFavPlaceEntity:(NSString *)placename 
                 latitude:(float)latitude 
                longitude:(float)longitude
{
    //搜索结果加入数据库 
    FavPlaceDao *favPlaceDao = [[FavPlaceDao alloc] init];
    [favPlaceDao initCoreData];    
    [favPlaceDao addObject:placename 
                  latitude:latitude 
                 longitude:longitude];
    [favPlaceDao release];
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
#pragma mark - 范围选取器
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView 
{
    return 2;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    switch (component) {
        case 0:
            return [mRangeSelectTitles count]; 
            break;
        case 1:
            return [mTimelineTitles count];
        default:
            return 0;
            break;
    }
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    switch (component) {
        case 0:
            return [mRangeSelectTitles objectAtIndex:row]; 
            break;
        case 1:
            return [mTimelineTitles objectAtIndex:row];
        default:
            return 0;
            break;
    }
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{    
    
    mPickRow = row;
    mPickComponent = component;
    NSNotificationCenter * notificationCenter = [NSNotificationCenter defaultCenter];
    NSNotification * notification = [NSNotification notificationWithName:@"didselValuesChange" object:nil];
    [notificationCenter postNotification:notification];
    
    
}

/**选择器选择**/
- (void)didselValuesChange
{
    switch (mPickComponent) {
        case 0:
            [DataController setKLocateSelfDistence:[[mRangeSelectTitles objectAtIndex:mPickRow] longLongValue]];
            [mShowPickRangeLabel setText: [NSString stringWithFormat:@"%@ 米", [mRangeSelectTitles objectAtIndex:mPickRow]]];
            break;
        case 1:
            [DataController setTimeline:[[mTimelineTitles objectAtIndex:mPickRow] intValue]];
            [mShowPickTimelineLabel setText:(NSString *)[mTimelineTitles objectAtIndex:mPickRow]];
            break;
        default:
            break;
    }
}

/****/
- (void)getDonePick
{
    NSInteger row1, row2;
    row1 = [mRangeSelectView selectedRowInComponent:0];
    row2 = [mRangeSelectView selectedRowInComponent:1];    
    [DataController setKLocateSelfDistence:[[mRangeSelectTitles objectAtIndex:row1] longLongValue]];
    [DataController setTimeline:[[mTimelineTitlesValues objectAtIndex:row2] intValue]]; 
    
    if (mIsCurl) {
        [self pressCurl];  
    }
    [self cancel:@"range"];
}


- (void)getCancelPick
{
    if (mIsCurl) {
        [self pressCurl];        
    }
    [mBelowView removeFromSuperview];
}

#pragma mark -
#pragma mark - 功能函数
- (NSString *)getTimelineTitleByValue:(int)value
{
    int i;
    for (i=0; i<[mTimelineTitlesValues count]; i++) {
        if ([[mTimelineTitlesValues objectAtIndex:i] intValue]==value) {
            return [mTimelineTitles objectAtIndex:i];
        }
    }
    return [mTimelineTitles objectAtIndex:0];
}
@end
