//
//  PlacesViewController.h
//  WeiTansuo
//
//  Created by HYQ on 9/21/11.
//  Copyright 2011 Invidel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import "WLocation.h"
#import "UIViewControllerCategory.h"
#import "SBJsonParser.h"
#import <CoreLocation/CoreLocation.h>
#import "DataController.h"
#import "SoftNoticeView.h"
#import "QueryCondition.h"
#import "EGORefreshTableHeaderView.h"
#import "JiepangClient.h"
#import "GoogleClient.h"
#import "LocationAnnotation.h"

@interface PlacesViewController : UIViewController <UITableViewDataSource,UITableViewDelegate,CLLocationManagerDelegate,EGORefreshTableHeaderDelegate,UISearchBarDelegate,UIActionSheetDelegate,MKMapViewDelegate> {
    NSMutableArray *        mPlaces;                    //地点
    CLLocation * mBestEffortAtLocation;                 //当前最精确位置
    int mLocateTimes;                                   //定位次数
    CLLocationManager * mLocationManager;               //定位管理器
    QueryCondition * mQueryCondition;                   //位置查询条件
    WLocation * mCurrentLocation;                       //定位地址
    MKCoordinateRegion mSelectRegion;                   //选择的地区
    int mLoadingDataType;                               //加载数据类型 1：定位 2：更多
    BOOL mIsloading;                                    //正在下载数据
    BOOL mIsAlert;                                      //
    BOOL mHasMore;                                      //是否还有更多数据
    UITableView * mTableView;                           //列表视图
    MKMapView * mMapView;                               //地图视图
    int mViewState;                                     //0:列表  1:地图
    EGORefreshTableHeaderView *mRefreshHeaderView;      //下拉刷新view
    SoftNoticeView * mSoftNoticeViewLoad;               //加载框
    UIActivityIndicatorView *   mLoadMoreAIView;        //页面加载更多转场
    UIImageView * mLoadMoreImageView;                   //加载更多图标
    UIToolbar * mHeadToolbar;                           //头部工具条
    JiepangClient *  mJiepangClient;                    //街旁接口
    BOOL mPlaceSelect;                                  //是否选择了地点
    BOOL mIsFirstLoadData;                              //是否第一次加载数据
    UISearchBar * mSearchBar;                           //搜索条
    UIActionSheet *  mFunctionAction;                   //功能弹出框
    NSMutableArray * mSearchLocations;                  //搜索结果地址数组
}

@property (nonatomic,assign) id finishTarget;
@property (nonatomic,assign) SEL finishAction;


- (void)initMRegion;
- (void)initMQueryCondition;
- (void)locateBegin;
- (void)loadPlaceBegin;
- (void)endLoadData;
- (void)tableviewScrollToTop:(BOOL)animated;
- (void)tableViewBegin;
//- (void)mapViewBegin;
- (void)setRegion:(WLocation *)wLocation;
- (void)loadLatLonByGuid:(WLocation *)wLocation;
- (void)alert:(NSString *)message;
@end
