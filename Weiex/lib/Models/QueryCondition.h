//
//  FilterCondition.h
//  WeiTansuo
//
//  Created by chenyan on 8/30/11.
//  Copyright 2011 Invidel. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QueryCondition : NSObject
{
    long long range;            //范围
    float longitude;            //经度
    float latitude;             //纬度
    int time;                   //事件限制
    int sorttype;               //排序方式
    int startpage;              //起始页
    int count;                  //查询数
    int baseapp;                //app 类型
    BOOL isImage;               //是否只显示包含图片的消息
}

@property (nonatomic, assign) long long range;
@property (nonatomic, assign) float longitude;
@property (nonatomic, assign) float latitude;
@property (nonatomic, assign) int time;
@property (nonatomic, assign) int sorttype;
@property (nonatomic, assign) int startpage;
@property (nonatomic, assign) int count;
@property (nonatomic, assign) int baseapp;
@property (nonatomic, assign) BOOL isImage;

@end
