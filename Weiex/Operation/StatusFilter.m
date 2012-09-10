//
//  StatusFilter.m
//  WeiTansuo
//
//  Created by chenyan on 10/7/11.
//  Copyright 2011 Invidel. All rights reserved.
//

#import "StatusFilter.h"

@implementation StatusFilter

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (BOOL)shenbianStatusFilter:(Status *)status
{
    if (status) {
        //过滤非图片
        if ([status.thumbnailPic length]<=5) {
            return NO;
        }
        //过滤weilingdi
        if ([status.text rangeOfString:@"微领地"].length > 0) {
            return NO;
        }
        //过滤爱微拍
        if ([status.text rangeOfString:@"爱微拍"].length > 0) {
            return NO;
        }
        return YES;
    }
    else {
        return NO;
    }
}

@end
