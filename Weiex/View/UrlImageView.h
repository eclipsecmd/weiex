//
//  UrlImageView.h
//  WeiTansuo
//
//  Created by Sai Li on 8/22/11.
//  Copyright 2011 Invidel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIImageView+WebCache.h"
#import "SDWebImageManager.h"

@interface UrlImageView : UIImageView <SDWebImageManagerDelegate>{
    NSString *mImageUrl;
    int mTempImageType;
    NSString *mPreviewImageUrl;
}

@property (nonatomic,assign) id finishTarget;
@property (nonatomic,assign) SEL finishAction;
@property (copy) NSString *imageUrl;
@property (copy) NSString *previewImageUrl;

- (void)processImageDataWithBlock:(void (^)(NSData * imageData))processImage;

- (void)requestPreviewImage:(NSString *)imgurl;
- (void) getImageByUrl:(int)tempImageType;       //1:头像图片 2:列表图片 3:详细页图片 4:微博图片列表展示图片
- (void) displayImage:(UIImage *)image;
- (void) cancelCurrentImageLoad;
- (void) setViewSize:(UIImage *)image;
- (void)setImageSze:(UIImage *)image
          withWidth:(float) width 
         withHeight:(float) height;
@end