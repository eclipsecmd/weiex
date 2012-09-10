//
//  ProfileStatusViewController.h
//  WeiTansuo
//
//  Created by CMD on 9/20/11.
//  Copyright 2011 Invidel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EGORefreshTableHeaderView.h"
#import "OAuthEngine.h"
#import "SoftNoticeView.h"
#import "User.h"
#import "WeiboClient.h"
#import "Status.h"
#import "StatusItemCellPro.h"
#import "StatusDetailViewController.h"
#import "DataController.h"
#import "QueryCondition.h"
#import "QueryStatus.h"

@interface ProfileStatusViewController : UIViewController <UITableViewDataSource,UITableViewDelegate,EGORefreshTableHeaderDelegate>
{
    OAuthEngine * mOAuthEngine;
    QueryStatus * mQueryStatus;                   //微博数据查询条件
    NSMutableArray * mStatuses;                         //微博数据
    //NSMutableArray * mDisplayStatuses;                  //用于显示的微博数据(起到筛选缓存作用)
    long long mCurrentStatueId;                         //当前微博的最大ID(防止翻页时数据重复)
    long mStatusCount;                                  //当前地点微博总数
    UIActivityIndicatorView *   mLoadMoreAIView;        //页面加载更多转场
    UIImageView * mLoadMoreImageView;                   //加载更多图标
    SoftNoticeView * mSoftNoticeViewLoad;               //加载框
    UITableView * mTableView;                           //列表视图
    EGORefreshTableHeaderView *mRefreshHeaderView;      //下拉刷新view
    BOOL mIsFirstLoadData;                              //是否第一次加载微博数据
    BOOL mIsLoadingData;                                //是否正在加载数据
    int mLoadingDataType;                               //加载数据类型 1：刷新 2：更多
    
    User * mUser;
    
}

@property (retain,nonatomic) OAuthEngine * oAuthEngine;
@property (assign,nonatomic) NSMutableArray * statuses;
@property (retain,nonatomic) User * user;
@property (retain,nonatomic) QueryStatus * queryStatus;

- (id) init;

- (void) initQueryStatus;
- (void) toStatusDetailViewByTable:(Status *)status;
- (void) initMStatusData;
- (void) loadDataBegin;
- (void) tableViewBegin;
- (void) refreshData;
- (void) loadMoreData;
- (void) endLoadData;
- (void) tableviewScrollToTop:(BOOL)animated;
- (void) alert:(NSString *)message;

@end
