//
//  GetImageOperation.h
//  WeiTansuo
//
//  Created by chenyan on 8/27/11.
//  Copyright 2011 Invidel. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GetImageOperation : NSOperation {
    NSString * mImageUrl;
}

@property (nonatomic, assign) id target;
@property (nonatomic, assign) SEL action;
@property (nonatomic, assign) NSString * imageUrl;

@end
