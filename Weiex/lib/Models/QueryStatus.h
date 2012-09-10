//
//  QueryStatus.h
//  WeiTansuo
//
//  Created by CMD on 9/21/11.
//  Copyright 2011 Invidel. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QueryStatus : NSObject
{
    long long sinceID;
    long long maxID;
    int       Count;
    int       Page;
    int       BaseApp;
    int       Feature;
    
}

@property (nonatomic,assign) long long sinceId;
@property (nonatomic,assign) long long maxId;
@property (nonatomic,assign) int count;
@property (nonatomic,assign) int page;
@property (nonatomic,assign) int baseApp;
@property (nonatomic,assign) int feature;

@end
