//
//  DetailViewController.h
//  WeiTansuo
//
//  Created by chishaq on 11-8-15.
//  Copyright 2011年 Invidel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Status.h"
#import "UrlImageView.h"
#import "OAuthEngine.h"
#import "UINavigationBarCategory.h"
#import "ClickImageView.h"
#import "DataController.h"
#import "StatusItemCell.h"
#import "QueryCondition.h"
#import "StatusLocationViewController.h"
#import "SoftNoticeView.h"
#import "WeiboClient.h"
#import "GoogleClient.h"
#import "WeiexClient.h"
#import "DataController.h"

@interface StatusDetailViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UIActionSheetDelegate>{
    Status *                    mStatus;                    //内容对象
    MKCoordinateRegion          mRegion;                    //当前地区
    OAuthEngine *               mOAuthEngine;               //权限信息
    NSMutableArray *            mComments;                  //评论数据
    QueryCondition *            mQueryCondition;            //微博评论数据查询条件
    UrlImageView *              mUserPicView;               //用户头像
    UILabel *                   mDetailContent;             //内容
    UrlImageView *              mMiddlePicView;             //图片区 
    UIWebView *                 mMapImageView;              //相对位置地图展示区
    UITableView *               mCommentsTableView;         //评论列表
    UIActivityIndicatorView *   mRefreshAIView;             //页面刷新转场
    UIActivityIndicatorView *   mLoadMoreAIView;            //页面加载更多转场
    //SoftNoticeView *            mSoftNoticeViewLoad;        //加载框
    BOOL                        mIsLoadingImage;            //是否正在下载图片 
	UILabel *                   mRetweetsCount;             //转发数
    int                         mCommentsCount;             //评论数
    BOOL                        mIsLoadingComment;          //是否正在下载评论数据
    BOOL                        mIsAlert;                   //
    long long                   mCommentsCurrentStatueId;   //当前评论中的最大ID(防止翻页时数据重复)
    int                         mCommentsCuttrntPageDataCount;//当前页评论数
    int                         mLoadingCommentDataType;    //加载数据类型 1：刷新 2：更多
    UIView *                    mTimeLocationView;
    UILabel *                   mUserNameLabel;
    WeiboClient *               mWeiboClient;
    WeiexClient *               mWeiexClient;               //Weiex处理接口  add by max     
    UIActionSheet *             mFunctionAction;            //功能弹出框
}

@property (nonatomic, retain) Status * status;
@property (nonatomic, retain) OAuthEngine * oAuthEngine;
@property (nonatomic, assign) MKCoordinateRegion region;

- (id) init;
- (void) refreshCommentData;
- (void) loadCommentsCountBegin;
- (void) loadCommentsBegin;
- (void) endLoadData;
- (void) tableViewBegin;
- (void) alert:(NSString *)message;
- (void) toFunctionActionSheet;
- (void)saveWbUserClick:(long long) wbuserid 
           onlineuserid:(long)userid 
         onlineusername:(NSString *)username 
        onlineuserimage:(NSString *)userimage
            nowlatitude:(double)geolat 
            nowlongtude:(double)geolng 
             nowaddress:(NSString *)address;
- (void)likeWeiboClick:(Status *) status 
          onlineuserid:(long)userid  
        onlineusername:(NSString *)username 
       onlineuserimage:(NSString *)userimage
           nowlatitude:(double)geolat 
           nowlongtude:(double)geolng 
            nowaddress:(NSString *)address;
/**根据参数获取微博加星数**/
- (void)loadWeiboStarBegin:(Status *)status;
@end
