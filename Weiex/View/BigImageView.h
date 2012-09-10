//
//  BigImageView.h
//  WeiTansuo
//
//  Created by HYQ on 10/4/11.
//  Copyright 2011 Invidel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIImageView+WebCache.h"
#import "SDWebImageManager.h"
#include "ClickImageView.h"

@interface BigImageView : UIView <SDWebImageManagerDelegate,UIScrollViewDelegate>{
    NSString * mImageUrl;
    UIScrollView * mScrollView;
    ClickImageView * mImageView;
}

@property (copy) NSString *imageUrl;
@property (nonatomic, retain) ClickImageView * imageView;

- (void) getImageByUrl;
- (void) showBigImage;
- (void) displayImage:(UIImage *)image;

@end
