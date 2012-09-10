//
//  BigImageViewController.h
//  WeiTansuo
//
//  Created by HYQ on 10/5/11.
//  Copyright 2011 Invidel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BigImageView.h"
#import "SoftNoticeView.h"

@interface BigImageViewController : UIViewController
{
    NSString * mImageUrl;
    BigImageView * mBigImageView;
    BOOL mIsSaving;
    BOOL mIsAlert;
}

@property (nonatomic,assign) id bigImgTarget;
@property (nonatomic,assign) SEL removeBigImageAction;

- (id)initWithImageUrl:(NSString *) imageUrl;
- (void)alert:(NSString *)message;

@end
