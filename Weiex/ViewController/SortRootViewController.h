//
//  SortViewController.h
//  WeiTansuo
//
//  Created by Yuqing Huang on 10/8/11.
//  Copyright 2011 Invidel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WLocation.h"
#import "ShenbianRootViewController.h"
#import "WeiboClient.h"
#import "DataController.h"
//#import "HotPlaceCell.h"
#import "HotPlace.h"
#import "HotPlaceNewCell.h"

@interface SortRootViewController : UIViewController <UITableViewDataSource,UITableViewDelegate>{
    UITableView * mSortTableView;
    NSMutableArray * mPlaces;   
    QueryCondition * mQueryCondition;                                           
    NSMutableArray * mImgUrls1;
    NSMutableArray * mImgUrls2;
    NSMutableArray * mImgUrls3;
    NSMutableArray * mImgUrls4;
    NSMutableArray * mImgUrls5;
    NSMutableArray * mImgUrls6;
    NSMutableArray * mImgUrls;
    int mHotStyle;                                      //展现形式
    
    long long mCurrentPlaceId;                          //当前微博的最大ID(防止翻页时数据重复)
    long mPlacesCount;                                  //当前地点微博总数
    UIActivityIndicatorView *   mLoadMoreAIView;        //页面加载更多view
    UIImageView * mLoadMoreImageView;                   //加载更多图标
    BOOL mIsFirstLoadData;                              //是否第一次加载数据
    BOOL mIsLoadingData;                                //是否正在加载数据
    int mLoadingDataType;                               //加载数据类型 1：刷新 2：更多
    SoftNoticeView * mSoftNoticeViewLoad;               //加载框
    int              mISpushorShow;
    
}

@property (nonatomic,assign) id  finishTarget;
@property (nonatomic,assign) SEL finishAction;
@property (nonatomic,assign) int optFlag;
@property (nonatomic,assign) long long starHotplaceid;
@property (nonatomic,retain) NSString * hotplaceDescription;
@property (nonatomic,retain) NSString * nowRegion;
@property (nonatomic,assign) double regionLat;
@property (nonatomic,assign) double regionLng;
@property (nonatomic,retain) NSString * regionProvince;
@property (nonatomic,assign) int isPushOrShow;

- (void)addData;
- (void) tableViewBegin;
- (void)saveHotplaceClick:(long long) hotplaceid 
             onlineuserid:(long)userid  
           onlineusername:(NSString *)username
          onlineuserimage:(NSString *)userimageurl 
              nowlatitude:(double)geolat 
              nowlongtude:(double)geolng 
               nowaddress:(NSString *)address;
-(void)saveStarHotplace:(int)placetype
        description:(NSString *)description
           onlineuserid:(long long)oluserid
         onlineusername:(NSString *)username
        onlineuserimage:(NSString *)userimageurl
        nowlatitude:(double)lat
        nowlongtude:(double)lng
         nowaddress:(NSString *)address
        nowprovince:(NSString *)province;
- (void)saveHotplaceStar:(long long) hotplaceid 
            onlineuserid:(long)userid  
          onlineusername:(NSString *)username
         onlineuserimage:(NSString *)userimageurl 
             nowlatitude:(double)geolat 
             nowlongtude:(double)geolng 
              nowaddress:(NSString *)address;
- (void)initMQueryCondition;
- (void)loadHotPlaceBegin;
- (void)alert:(NSString *)message;

- (BOOL)ifCanLoadMore;
- (void) tableviewScrollToTop:(BOOL)animated;

- (void)refreshData;
- (BOOL)beforeLoadMoreData;
- (void)endLoadMoreData;
- (void)loadMoreData;

@end
