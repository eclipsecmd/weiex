//
//  TansuoRootViewController.h
//  WeiTansuo
//
//  Created by chishaq on 11-8-22.
//  Copyright 2011年 Invidel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import "Status.h"
#import "WeiboClient.h"
#import "DataController.h"
#import "StatusDetailViewController.h"
#import "GoogleLocalConnection.h"
#import "WLocation.h"
#import "LocationAnnotation.h"
#import "StatusAnnotation.h"
#import "StatusAnnotationView.h"
#import "OAuthViewController.h"

@interface TansuoRootViewController : UIViewController <UIAlertViewDelegate, UITextFieldDelegate,MKMapViewDelegate,GoogleLocalConnectionDelegate> {
    OAuthEngine * mOAuthEngine;                         //权限信息
    GoogleLocalConnection *mGoogleLocalConnection;      //google API 接口
    MKCoordinateRegion mRegion;                         //当前地区
    NSMutableArray * mStatuses;                         //微博数据
    NSMutableArray * mSearchLocations;                  //搜索结果地址数组
    NSString * mKeyword;                                //地点搜索关键词
    UIToolbar * mToolbar;                               //工具条
    UIAlertView * mKeywordInputView;                    //搜索弹出框
    UITextField * mKeywordTextField;                    //搜索输入框
    MKMapView * mMapView;                               //地图视图
    BOOL mIsFirstLoadData;                              //是否第一次加载地图数据
    int mTime;                                          //定时器的事件
}

@property (assign,nonatomic) OAuthEngine * oAuthEngine;
@property (assign,nonatomic) MKCoordinateRegion region;
@property (assign,nonatomic) NSMutableArray * statuses;
@property (assign,nonatomic) NSMutableArray * searchLocations;

- (id) init;
- (void) initMRegion;
- (void) loadDataBegin;
- (void) mapViewBegin;
- (void) mapViewAnnotationLoad;
//- (void)StartTimer;

@end
