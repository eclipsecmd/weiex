//
//  StatusImageDetailViewController.h
//  WeiTansuo
//
//  Created by CMD on 11/1/11.
//  Copyright 2011 Invidel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Status.h"
#import "UrlImageView.h"
#import "OAuthEngine.h"
//#import "UINavigationBarCategory.h"
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
#import <MapKit/MapKit.h>
#import "WildcardGestureRecognizer.h"
#import "MKMapView+ZoomLevel.h"


@interface StatusImageDetailViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UIActionSheetDelegate, MKMapViewDelegate> {
    Status *                    mStatus;                    //内容对象
    MKCoordinateRegion          mRegion;                    //当前地区
    OAuthEngine *               mOAuthEngine;               //权限信息
    NSMutableArray *            mComments;                  //评论数据
    QueryCondition *            mQueryCondition;            //微博评论数据查询条件
    UrlImageView *              mUserPicView;               //用户头像
    UILabel *                   mDetailContent;             //内容
    UrlImageView *              mMiddlePicView;             //图片区 
    UrlImageView *              mMapImageView;              //相对位置地图展示区
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
    UILabel *                   mUserNameLabel;
    WeiboClient *               mWeiboClient;   
    UIActionSheet *             mFunctionAction;            //功能弹出框
    
    UIImageView *               mVerifyinfo;
    UIImageView *               mCreateAtIcon;
    UILabel *                   mCreateAtLabel;
    UIImageView *               mRelationLocationIcon;
    UILabel *                   mRelationLocationLabel;
    NSInteger                   mIndexpathRowinTableViewCell;
    
    UIButton *                  mGoAnywhereButton;
    UIImageView *               mStarImageView;            //微博加星图
    UILabel *                   mStarView;                 //微博查看数  
    UIButton *                  mStarImageButton;          //微博加星图片点击按钮
    long long                   mStarAmount;               //加星数   
    UIImageView *               mLineImageView;            //分割线图片
    UIImageView *               mMiddlePicShadowView;      //图片阴影
    UILabel *                   mCommentCountLable;        //微博评论数
    UIImageView *               mCommentCountImage;        //微博评论图片
    BOOL                        mGoAnywhereButtonIsShow;     
    UIButton *                  mGoProfileView;    
    MKMapView *                 mMapViewForStatusGeo;    
    NSInteger                   mUpdateWeiboIndex;         //同步更新微博索引号
    BOOL                        mIsUpdateStatusAfterStar;  //加星后更新微博加星数
    UIButton  *                 mMapViewCover;
    UIImageView *               mMapBackView;              //定位地图背景图
    UIImageView *               mStarTipImageView;         //加星提示图片
    UILabel *                   mStarTipLabel;             //加星提示语
}

@property (nonatomic,assign) id finishTarget;
@property (nonatomic,assign) SEL finishAction;

@property (nonatomic, retain) Status * status;
@property (nonatomic, retain) OAuthEngine * oAuthEngine;
@property (nonatomic, assign) MKCoordinateRegion region;
@property (nonatomic, assign) BOOL goAnywhereButtonIsShow;
@property (nonatomic, assign) NSInteger updateWeiboIndex;


- (id) init;
- (void) refreshCommentData;
- (void) loadCommentsCountBegin;
- (void) loadCommentsBegin;
- (void) endLoadData;
- (void) tableViewBegin;
- (void) alert:(NSString *)message;
- (void) toFunctionActionSheet;

- (void)dispearAlert;

//reset the height of the tableview
- (void)resetTableViewHeight;

//this method code by cmd and quan
- (void) drawLayout;

- (void) drawFrame;

- (void) takeMeToAnyWhereMethod;

- (void) back;
//微博加星操作
- (void)weiboAddStarOpt:(id)sender;
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

@end
