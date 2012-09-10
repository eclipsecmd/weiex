//
//  SimpleImageCache.h
//  WeiTansuo
//
//  Created by Tu Jianfeng on 9/4/11.
//  Copyright 2011 Invidel. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface SimpleImageCache : NSObject {
    NSMutableDictionary * mCacheDictionary;
    NSString * mDocumentPath;
}

+ (SimpleImageCache *)sharedCache;

- (UIImage *)getImageByUrl:(NSString *)url;
- (void)saveImage:(UIImage *)image withUrl:(NSString *)url;

@end
