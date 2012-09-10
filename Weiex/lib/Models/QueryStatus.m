//
//  QueryStatus.m
//  WeiTansuo
//
//  Created by CMD on 9/21/11.
//  Copyright 2011 Invidel. All rights reserved.
//

#import "QueryStatus.h"

@implementation QueryStatus

@synthesize sinceId = sinceID;
@synthesize maxId = maxID;
@synthesize count = Count;
@synthesize page = Page;
@synthesize baseApp = BaseApp;
@synthesize feature = Feature;

- (id)init
{
    self = [super init];
    if (self) {
        sinceID = 0;
        maxID = 0;
        Count = 20;
        Page = 1;
        BaseApp = 0;
        Feature = 0;
    }
    
    return self;
}

@end
