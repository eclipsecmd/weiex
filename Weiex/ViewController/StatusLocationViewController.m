//
//  StatusLocationViewController.m
//  WeiTansuo
//
//  Created by chenyan on 9/13/11.
//  Copyright 2011 Invidel. All rights reserved.
//

#import "StatusLocationViewController.h"
#import "LocationAnnotation.h"
#import "UIViewControllerCategory.h"

@implementation StatusLocationViewController

@synthesize region = mRegion;

#pragma mark - 
#pragma mark - 构造与析构

- (id)init
{
    self = [super init];
    if (self) {
        mCurrentLocation = [[WLocation alloc] init];
        mIsFirstLoad = YES;
    }
    return self;
}

- (void)dealloc
{
    [mMapView release];
    [mCurrentLocation release];
    [super dealloc];
}

#pragma mark -
#pragma mark - 视图

- (void)loadView
{
    [super loadView];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
//    //导航栏
//    [self setBackBarItem:@selector(back)];
    
    //返回按钮    
    UIButton * backButton = [[UIButton alloc] initWithFrame:CGRectMake(9,7, 40, 30)];
    [backButton setImage:[UIImage imageNamed:@"title_icon_5_nor.png"] forState:UIControlStateNormal];
    [backButton setImage:[UIImage imageNamed:@"title_icon_5_press.png"] forState:UIControlStateHighlighted];
    [backButton addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:backButton];
    [backButton release];
    //头部中间标题
    UILabel * detailLabel = [[UILabel alloc] initWithFrame:CGRectMake(85, 7, 150, 30)];
    detailLabel.textAlignment = UITextAlignmentCenter;
    detailLabel.backgroundColor = [UIColor clearColor];
    detailLabel.text = @"查看地图";
    detailLabel.font = [UIFont fontWithName:@"TrebuchetMS-Bold" size:20];
    detailLabel.textColor = [UIColor whiteColor];
    [self.view addSubview:detailLabel];
    [detailLabel release];     
    //设置地图视图
    if (!mMapView) {
        CGRect mapFrame = self.view.frame;
//        mapFrame.size.height -= 44.f;
        mapFrame.origin.y = 37.f;
        mMapView = [[MKMapView alloc] initWithFrame:mapFrame];
        mMapView.centerCoordinate = mRegion.center;
        mMapView.delegate = self;
        mMapView.showsUserLocation = NO;
        [self.view addSubview:mMapView];
    }
    
    [self initMRegion];
    [self mapViewBegin];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    mMapView = nil;
    [mMapView release]; 
}

- (void)viewWillAppear:(BOOL)animated  
{  
    [super viewWillAppear:animated];  
}

#pragma mark -
#pragma mark - 地图
/**初始化地图中心**/
- (void)initMRegion
{ 
    mCurrentLocation.latitude = mRegion.center.latitude;
    mCurrentLocation.longitude = mRegion.center.longitude; 
    mCurrentLocation.title = @"";
    mCurrentLocation.subtitle = @"";
    mCurrentLocation.streetAddress = @"";
    mCurrentLocation.region = @"";
    mCurrentLocation.city = @"";
    mCurrentLocation.country = @"";
}
/**地图开始展示**/
- (void) mapViewBegin
{
    [mMapView setRegion:mRegion animated:YES];
}

/**地图位置变换后，重新加载数据(代理)**/
- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
    if (mIsFirstLoad) {
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(mapViewAnnotationLoad) object:nil];
        [self performSelector:@selector(mapViewAnnotationLoad) withObject:nil];
        mIsFirstLoad = NO;
    }
    
}
/**用微博返回的数据生成地图标识**/
- (void)mapViewAnnotationLoad
{
        [mMapView removeAnnotations:[mMapView annotations]];
        //中心位置
        int index  = 0;
        LocationAnnotation * annotaion = [[LocationAnnotation alloc] init];
        annotaion.wLocation = mCurrentLocation;
        annotaion.indexTag = index;
        [mMapView addAnnotation:annotaion];
        [annotaion release];
}
/**地图注释生成(代理)**/
- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation;
{  
    
//    if([annotation isKindOfClass:[LocationAnnotation class]]) {
//        static NSString * LocationAnnotationIdentifier = @"LocationAnnotationIdentifier";
//        
//        MKPinAnnotationView * pinView = (MKPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:LocationAnnotationIdentifier];
//        if (!pinView) {
//            MKPinAnnotationView * pinView = [[[MKPinAnnotationView alloc]
//                                              initWithAnnotation:annotation reuseIdentifier:LocationAnnotationIdentifier] autorelease];
//            pinView.pinColor = MKPinAnnotationColorPurple;
//            pinView.animatesDrop = YES; 
//            pinView.canShowCallout = YES;
//        }
//        else {
//            pinView.annotation = annotation;
//        }
//        return pinView;
//        
//    }
//    else {
//        return nil;
//    }
    return nil;
}

#pragma mark -
#pragma mark - 事件
-(void) back
{
    [self.navigationController popViewControllerAnimated:YES];
}
@end
