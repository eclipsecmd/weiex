//
//  SimpleImageCache.m
//  WeiTansuo
//
//  Created by Tu Jianfeng on 9/4/11.
//  Copyright 2011 Invidel. All rights reserved.
//

#import "SimpleImageCache.h"

#define FILE_NAME @"simplecache.plist"

static SimpleImageCache * sharedCache_;

@implementation SimpleImageCache

+ (SimpleImageCache *)sharedCache
{
    if (sharedCache_ == nil) {
        @synchronized(self) {
            if (sharedCache_ == nil) {
                sharedCache_ = [[SimpleImageCache alloc] init];
            }
        }
    }
    
    return sharedCache_;
}

+ (id)alloc
{
    NSAssert(sharedCache_ == nil, @"Attempted to allocate a second instance of a singleton."); 
    
    return [super alloc];
}

- (NSString *)fullPath:(NSString *)fileName
{
    NSString * ret = [mDocumentPath stringByAppendingPathComponent:fileName];
    return ret;
}

- (id)init
{
    self = [super init];
    if (self) {
        NSArray * documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        mDocumentPath = [[documentPaths objectAtIndex:0] retain];           
        mCacheDictionary = [NSMutableDictionary dictionaryWithContentsOfFile:[self fullPath:FILE_NAME]];
        [mCacheDictionary retain];
        if (mCacheDictionary == nil) {
            mCacheDictionary = [[NSMutableDictionary alloc] init];
        }
        
    }
    
    return self;
}

- (UIImage *)getImageByUrl:(NSString *)url;
{
    NSString * fileName = [mCacheDictionary objectForKey:url];
    
    UIImage * ret = nil;
    if (fileName != nil) {
        ret = [UIImage imageWithContentsOfFile:[self fullPath:fileName]];
    }
    
    return ret;
}

- (void)saveImage:(UIImage *)image withUrl:(NSString *)url
{
    @synchronized(self) {
        NSString * fileName = [mCacheDictionary objectForKey:url];
        if ([fileName length] == 0) {
            NSFileManager * fileManager = [NSFileManager defaultManager];
            int index = 0;
            fileName = [NSString stringWithFormat:@"%d.png", index];
            while (YES) {
                if (![fileManager fileExistsAtPath:[self fullPath:fileName]]) {
                    break;
                }
                
                index++;
                fileName = [NSString stringWithFormat:@"%d.png", index];
            }
            
            NSData * data = UIImagePNGRepresentation(image);
            NSError * error;
            
            [data writeToFile:[mDocumentPath stringByAppendingPathComponent:fileName] options:NSDataWritingAtomic error:&error];
            
            [mCacheDictionary setObject:fileName forKey:url];
            [mCacheDictionary writeToFile:[mDocumentPath stringByAppendingPathComponent:FILE_NAME] atomically:NO];
        }
    }
}

- (void)dealloc
{
    [mCacheDictionary release];
    
    [super dealloc];
}

@end
