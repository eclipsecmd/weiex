//
//  CommentToMeViewController.h
//  WeiTansuo
//
//  Created by CMD on 10/15/11.
//  Copyright 2011 Invidel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "User.h"
#import "OAuthEngine.h"
#import "WeiboClient.h"
#import "ProfileStatusViewController.h"
#import "EGORefreshTableHeaderView.h"
#import "SoftNoticeView.h"
#import "User.h"
#import "WeiboClient.h"
#import "Comment.h"
#import "StatusItemCellNotice.h"
#import "StatusDetailViewController.h"
#import "DataController.h"
#import "QueryCondition.h"
#import "QueryStatus.h"
#import "StatusCommentViewController.h"
#import "ProfileViewController.h"
#import "StatusDetailViewController.h"

@interface UserMessageRootViewController : UIViewController <UITableViewDataSource,UITableViewDelegate,EGORefreshTableHeaderDelegate, UIActionSheetDelegate> {
    User *mUser;
    OAuthEngine *mOauth;
    BOOL  mIsLoadingTrendCount;
    BOOL  mIsLoadingTagCount;
    WeiboClient * mWeiboClient;
    NSArray * mTags;
    UILabel * mProfile;
    UILabel * mTagsLabel;
    int isFollowClient;
    BOOL mIsLoadingFollow;
    UIView * mNamePic;

    QueryStatus * mQueryStatus;                         //微博数据查询条件
    NSMutableArray * mStatuses;                         //微博数据
    long long mCurrentStatueId;                         //当前微博的最大ID(防止翻页时数据重复)
    long mCurrentPageStatueCount;
    long mStatusCount;                                  //当前地点微博总数
    UIActivityIndicatorView *   mLoadMoreAIView;        //页面加载更多转场
    UIImageView * mLoadMoreImageView;                   //加载更多图标
    SoftNoticeView * mSoftNoticeViewLoad;               //加载框
    UITableView * mTableView;                           //列表视图
    EGORefreshTableHeaderView *mRefreshHeaderView;      //下拉刷新view
    BOOL mIsFirstLoadData;                              //是否第一次加载微博数据
    BOOL mIsLoadingData;                                //是否正在加载数据
    int mLoadingDataType;                               //加载数据类型 1：刷新 2：更多
    BOOL mIsAlert;
    
    
    UIActionSheet * mFunctionSheet;
    Comment * mTempComment;
    
    NSTimer * mClockerForNotice;
}

@property (nonatomic, retain) User *user;
@property (nonatomic, retain) OAuthEngine *oauth;
@property (assign,nonatomic) NSMutableArray * statuses;
@property (retain,nonatomic) QueryStatus * queryStatus;

- (id) init;
- (void) initQueryStatus;
- (void) initMStatusData;
- (void) loadDataBegin;
- (void) tableViewBegin;
- (void) refreshData;
- (void) loadMoreData;
- (void) endLoadData;
- (void) tableviewScrollToTop:(BOOL)animated;
- (void) showBigImage:(NSString *)imageUrl;
- (void) alert:(NSString *)message;

- (void)toFunctionActionSheetWithComment:(Comment *)comment;
- (void)goUserProfile;
- (void)goOriWeibo;
- (void)replyComment;


//////notices message
- (void)getUnreadCount;

- (void)setCountByType;

@end
