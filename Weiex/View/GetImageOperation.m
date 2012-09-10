//
//  GetImageOperation.m
//  WeiTansuo
//
//  Created by chenyan on 8/27/11.
//  Copyright 2011 Invidel. All rights reserved.
//

#import "GetImageOperation.h"

@implementation GetImageOperation

@synthesize target, action;
@synthesize imageUrl = mImageUrl;

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (void)main
{
    NSURL * userPicUrl = [NSURL URLWithString:mImageUrl];        
    NSData * userPicUrldata = [NSData dataWithContentsOfURL:userPicUrl];    
    
    if ([target retainCount] > 0 && [target respondsToSelector:action]) {
        [target performSelector:action  withObject:userPicUrldata];
    }
}

- (void)dealloc
{
    [super dealloc];
}

@end
