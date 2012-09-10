//
//  FilterCondition.m
//  WeiTansuo
//
//  Created by chenyan on 8/30/11.
//  Copyright 2011 Invidel. All rights reserved.
//

#import "QueryCondition.h"

@implementation QueryCondition

@synthesize range;
@synthesize longitude;
@synthesize latitude;
@synthesize time;
@synthesize sorttype;
@synthesize startpage;
@synthesize count;
@synthesize baseapp;
@synthesize isImage;

- (id)init
{
    self = [super init];
    if (self) {
    }
    return self;
}

@end
