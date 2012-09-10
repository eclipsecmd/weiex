//
//  FeedStruct.h
//  WeiTansuo
//
//  Created by hyq on 11/25/11.
//  Copyright (c) 2011 Invidel. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FeedStruct : NSObject{
    NSString * mUserName;
    NSString * mUserHeadUrl;
    NSString * mImgUrl;
    NSString * mLocation;
    long long mWeiboId;
}

@property (retain,nonatomic) NSString * userName;
@property (retain,nonatomic) NSString * userHeadUrl;
@property (retain,nonatomic) NSString * imgUrl;
@property (retain,nonatomic) NSString * location;
@property (assign,nonatomic) long long weiboId;

- (id)init;
- (void)format;

@end
