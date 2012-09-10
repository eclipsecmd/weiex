//
//  ShenbianRootViewController.h
//  WeiTansuo
//
//  Created by chishaq on 11-8-19.
//  Copyright 2011年 Invidel. All rights reserved.
//

#import <MessageUI/MessageUI.h>
#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import "Status.h"
#import "WeiboClient.h"
#import "DataController.h"
#import "StatusDetailViewController.h"
#import "WLocation.h"
#import "LocationAnnotation.h"
#import "StatusAnnotation.h"
#import "StatusAnnotationView.h"
#import "OAuthViewController.h"
#import "StatusItemCellPic.h"
#import "QueryCondition.h"
#import "ClickImageView.h"
#import "EGORefreshTableHeaderView.h"
#import "SoftNoticeView.h"
#import "PlacesSearchViewController.h"
#import "StatusFilter.h"
#import "BigImageViewController.h"
#import "WeiexClient.h"


@interface ShenbianPicViewController : UIViewController <MKMapViewDelegate,UITableViewDataSource,UITableViewDelegate,EGORefreshTableHeaderDelegate, UIActionSheetDelegate,CLLocationManagerDelegate, UITabBarControllerDelegate> {
    
    OAuthEngine * mOAuthEngine;                         //权限信息
    MKCoordinateRegion mRegion;                         //当前地区
    QueryCondition * mQueryCondition;                   //微博数据查询条件
    NSMutableArray * mStatuses;                         //微博数据
    long long mCurrentStatueId;                         //当前微博的最大ID(防止翻页时数据重复)
    long mStatusCount;                                  //当前地点微博总数
    WLocation * mCurrentLocation;                       //定位地址
    UIActivityIndicatorView *   mLoadMoreAIView;        //页面加载更多转场
    UIImageView * mLoadMoreImageView;                   //加载更多图标
    SoftNoticeView * mSoftNoticeViewLoad;               //加载框
    UILabel * mLocationInfoView;                        //显示当前用户地理信息
    MKMapView * mMapView;                               //地图视图
    UITableView * mTableView;                           //列表视图
    EGORefreshTableHeaderView *mRefreshHeaderView;      //下拉刷新view
    BOOL mIsFirstLoadData;                              //是否第一次加载微博数据
    BOOL mIsLoadingData;                                //是否正在加载数据
    int mLoadingDataType;                               //加载数据类型 1：刷新 2：更多
    UIActionSheet * mQueryAction;
    WeiexClient *  mWeiexClient;                        //Weiex处理接口  add by max  
    NSMutableArray * mStatusImgUrls;                    //图片地址数组    add by max
}

@property (retain,nonatomic) OAuthEngine * oAuthEngine;
@property (assign,nonatomic) MKCoordinateRegion region;
@property (assign,nonatomic) QueryCondition * queryCondition;
@property (assign,nonatomic) NSMutableArray * statuses;

- (id) init;
- (void) initToolbarButtion;
- (void) initMRegion;
- (void) initMQueryCondition;
- (void) initMStatusData;
- (void) defaultLocate:(BOOL)needLocate;
- (void) reverseGeocoderBegin:(CLLocationCoordinate2D)coordinate;
- (void) loadDataBegin;
- (void) tableViewBegin;
- (void) refreshData;
- (void) loadMoreData;
- (void) endLoadData;
- (void) mapViewBegin;
- (void) tableviewScrollToTop:(BOOL)animated;
- (void) mapViewAnnotationLoad;
- (void) toStatusDetailViewByTable:(Status *)status;
- (void) exchangeTableViewAndMapView;
- (void) backToHead;
- (void) alert:(NSString *)message;
//max method
- (void)saveWeiboClick:(Status *) status
          onlineuserid:(long)userid  
        onlineusername:(NSString *)username
       onlineuserimage:(NSString *)userimage 
           nowlatitude:(double)geolat
           nowlongtude:(double)geolng
            nowaddress:(NSString *)address;
@end