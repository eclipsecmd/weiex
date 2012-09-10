//
//  FeedRootViewController.h
//  WeiTansuo
//
//  Created by hyq on 11/25/11.
//  Copyright (c) 2011 Invidel. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "EGORefreshTableHeaderView.h"
#import "SoftNoticeView.h"
#import "WeiexClient.h"
#import "QueryCondition.h"
#import "BasicCell.h"
#import "FeedCell.h"
#import "FeedStruct.h"
#import "StatusImageDetailViewController.h"
#import "DataController.h"
#import "ProfileViewController.h"

@interface FeedRootViewController : UIViewController <UITableViewDataSource,UITableViewDelegate,EGORefreshTableHeaderDelegate>{
    UITableView * mTableView;                           //列表视图
    EGORefreshTableHeaderView * mRefreshHeaderView;      //下拉刷新view
    UIActivityIndicatorView *   mLoadMoreAIView;        //页面加载更多转场
    UIImageView * mLoadMoreImageView;                   //加载更多图标
    SoftNoticeView * mSoftNoticeViewLoad;               //加载框
    long mFeedCount;                                    //展示的加星微博总数
    NSMutableArray * mFeeds;                            //数据源
    WeiexClient * mWeiexClient;                         
    QueryCondition * mQueryCondition;                   //获得数据源的设置条件
    BOOL mIsLoadingData;                                //是否正在加载数据
    int mLoadingDataType;                               //加载数据类型 1：刷新 2：更多
    User * curUser;                                     //当前Feed的用户，用于用户详细跳转
}
- (id) init;
- (void) alert:(NSString *)message;
- (void) closeAlert:(SoftNoticeView *)msgBox;
- (void) addData;
- (void) tableViewBegin;
- (void) refreshData;
- (void) initMQueryCondition;
- (void) loadFeedsBegin;
- (void) loadFeedFinished:(WeiexClient *)sender json:(NSDictionary*)json;
- (void) getStatusByFeed:(long long)feed;
- (void) getStatusfinished:(WeiboClient*)sender obj:(NSObject*)obj;
- (void) toStatusDetailViewByTable:(Status *)status;
- (void)tableviewScrollToTop:(BOOL)animated;
- (void)toUserProfile:(id)sender;
//- (void) getCurUserfinished:(WeiboClient*)sender obj:(NSObject*)obj;
@end
