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
#import "UINavigationBarCategory.h"
#import "SBJsonParser.h"     
#import "DataController.h"
#import "SoftNoticeView.h"
#import "LocationAnnotation.h"
#import "GoogleLocalConnection.h"
#import "RangePickViewController.h"
#import "FavoritePlaceViewController.h"
#import "searchInstant.h"
#import "PassValueDelegate.h"


@interface PlacesSearchViewController : UIViewController <CLLocationManagerDelegate,UISearchBarDelegate,UIActionSheetDelegate,MKMapViewDelegate,GoogleLocalConnectionDelegate, UIPickerViewDelegate, UIPickerViewDataSource, PassValueDelegate> {

    MKCoordinateRegion mMapCenterRegion;                //地图中心
    BOOL mIsloading;                                    //正在下载数据
    BOOL mIsAlert;                                      //
    BOOL mIsPressing;                                   //防止长按事件便宜
    MKMapView * mMapView;                               //地图视图
    SoftNoticeView * mSoftNoticeViewLoad;               //加载框
    UIToolbar * mHeadToolbar;                           //头部工具条
    UIView * mDisableViewOverlay;                       //
    BOOL mIsFirstLoadData;                              //是否第一次加载数据
    UISearchBar * mSearchBar;                           //搜索条
    searchInstant  *mSearchInstant;
	NSMutableArray		 *_resultArray;
	NSString			 *_searchStr;
    NSMutableArray * mSearchLocations;                  //搜索结果地址数组
    GoogleLocalConnection * mGoogleLocalConnection;     //google API 接口
    UILabel *  mShowPickRangeLabel;
    UILabel *  mShowPickTimelineLabel;
    UIView *   mBelowView;
    BOOL       mIsCurl;
    UIPickerView *mRangeSelectView;                     //范围选取器
    NSArray *mRangeSelectTitles;                        //范围选取器选项
    NSArray *mTimelineTitles;                           //时间选择数据
    NSArray *mTimelineTitlesValues;                     //时间选择数据
    UIButton *mDoneButtonForRangeSelectView;
    UIButton *mCancelButtonForRangeSelectView;
    long long mCurrentRange;
    long long mCurrentTimeline;
    NSInteger mPickRow;
    NSInteger mPickComponent;
    
    
    
    
    
}

@property (nonatomic, assign) id finishTarget;
@property (nonatomic, assign) SEL finishAction;

@property (nonatomic, copy)NSString *_searchStr;

- (void)setDDListHidden:(BOOL)hidden;

- (void)initMRegion;
- (void)initMQueryCondition;
- (void)mapViewBegin;
- (void)searchBar:(UISearchBar *)searchBar activate:(BOOL) active;
- (void)alert:(NSString *)message;
- (void)pressCurl;// the view roll up. aka Curl.
//below is pick method
- (void)rangeSelect:(long long)range;//unkown method
//function as the title
- (void)initPickViewDataSource;
- (void)getDonePick;//Done Button above on the UIPickerView
- (void)getCancelPick;//Cancel botton above on the UIPickerView
- (void)didselValuesChange;//change the sarchbartitle
//- (void)goFavoritesPlace:(WLocation *)wLocation;
//
//- (void)addFavPlaceEntity:(NSString *)placename 
//                 latitude:(float)latitude 
//                longitude:(float)longitude;

- (void)cancel;
- (void)cancel:(NSString *)message;
- (NSString *)getTimelineTitleByValue:(int)value;

@end
