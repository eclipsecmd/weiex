//
//  BigImageView.m
//  WeiTansuo
//
//  Created by HYQ on 10/4/11.
//  Copyright 2011 Invidel. All rights reserved.
//

#import "BigImageView.h"
#import <QuartzCore/QuartzCore.h>

@implementation BigImageView

@synthesize imageUrl = mImageUrl;
@synthesize imageView = mImageView;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setBackgroundColor:[UIColor blackColor]];
        mScrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        [mScrollView setContentSize:CGSizeMake(frame.size.width, frame.size.height)];
        [mScrollView setShowsVerticalScrollIndicator:YES];
        [mScrollView setShowsHorizontalScrollIndicator:YES];
        [self addSubview:mScrollView];
        
        mImageView = [[ClickImageView alloc] initWithFrame:CGRectMake(10, 180, 300, 100)];
        [mScrollView addSubview:mImageView];
    }
    
    return self;
}

- (void) getImageByUrl
{  
    if ([mImageUrl length] <=5) {
        return;
    }
    
    SDWebImageManager *manager = [SDWebImageManager sharedManager];
    UIImage * cachedImage = [manager imageWithURL:[NSURL URLWithString:mImageUrl]];
    if (cachedImage)
    {
        [self displayImage:cachedImage];
    }
    else
    {   
        [mImageView setImage:[UIImage imageNamed:@"loadbg300.png"]];  
        [manager downloadWithURL:[NSURL URLWithString:mImageUrl] delegate:self];
    }
}

- (void)webImageManager:(SDWebImageManager *)imageManager didFinishWithImage:(UIImage *)image
{
    [self displayImage:image];
}

- (void)cancelCurrentImageLoad
{
    [[SDWebImageManager sharedManager] cancelForDelegate:self];
}

- (void)displayImage:(UIImage *)image 
{
    [mImageView setImage:image];
    CGRect scrollFrame = mScrollView.frame;
   
    CGFloat realWidth = image.size.width;
    CGFloat realHeight = image.size.height;
    CGFloat frameWidth = realWidth > 300 ? 300:realWidth;
    CGFloat frameHeight = realHeight * frameWidth/realWidth;
    
    float x = (320 - frameWidth)/2;
    float y = frameHeight > scrollFrame.size.height ? 20 : (460 - frameHeight)/2 ;
    
    [mImageView setFrame:CGRectMake(x, y, frameWidth, frameHeight)]; 
    [mScrollView setContentSize:CGSizeMake(scrollFrame.size.width,  frameHeight+y)];
}

/**显示大图片**/
-(void)showBigImage
{	
	[self getImageByUrl];    
}

- (void)dealloc {
    [mImageView release];
    [mScrollView release];
    [mImageUrl release];
    [super dealloc];
}

@end
