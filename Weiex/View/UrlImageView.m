//
//  UrlImageView.m
//  WeiTansuo
//
//  Created by Sai Li on 8/22/11.
//  Copyright 2011 Invidel. All rights reserved.
//

#import "UrlImageView.h"


@implementation UrlImageView

@synthesize finishTarget,finishAction;
@synthesize imageUrl = mImageUrl;
@synthesize previewImageUrl = mPreviewImageUrl;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
    }
    return self;
}

- (void)requestPreviewImage:(NSString *)imgurl
{
    if ([mImageUrl length] <=5) {
        return;
    }    
    SDWebImageManager * manager = [SDWebImageManager sharedManager];
    UIImage * cachedImage = [manager imageWithURL:[NSURL URLWithString:mImageUrl]];
    if (cachedImage)
    {
        [self displayImage:cachedImage];
    }
    else
    {
        //[self setImage:[UIImage imageNamed:@"loadbg60.png"]];
        NSURL* url = [NSURL URLWithString:[imgurl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];//网络图片url
        NSData* data = [NSData dataWithContentsOfURL:url];//获取网咯图片数据
        if(data!=nil){
            UIImage * image = [[UIImage alloc] initWithData:data];//根据图片数据流构造image
            [self setImage:image];
            [image release];
        }        
    }
    [manager downloadWithURL:[NSURL URLWithString:mImageUrl] delegate:self];
    [manager release];
}


- (void)getImageByUrl:(int)tempImageType
{  
    if ([mImageUrl length] <=5) {
        return;
    }
    
    mTempImageType = tempImageType;
    
    SDWebImageManager * manager = [SDWebImageManager sharedManager];
    
    UIImage * cachedImage = [manager imageWithURL:[NSURL URLWithString:mImageUrl]];
    //UIImage * cachedImage = nil;
    if (cachedImage)
    {
        [self displayImage:cachedImage];  
    }
    else
    {
        if (mTempImageType == 1) {
            [self setImage:[UIImage imageNamed:@"loadbg60.png"]];
        }
        else if (mTempImageType == 2) {
            [self setImage:[UIImage imageNamed:@"loadbg120.png"]];
        }
        else if (mTempImageType == 3){
            [self setImage:[UIImage imageNamed:@"loadbg300.png"]];
        }
        else if (mTempImageType == 4){
            [self setImage:[UIImage imageNamed:@"loadbg100.png"]];
        }
        else if (mTempImageType == 5){               //left图片
            [self setImage:[UIImage imageNamed:@"loadbg100.png"]];
        }
        else if (mTempImageType == 6){               //cellPic图片
            [self setImage:[UIImage imageNamed:@"loadbg100.png"]];
        }
        [manager downloadWithURL:[NSURL URLWithString:mImageUrl] delegate:self];
    }
    /*
    
    [self processImageDataWithBlock:^(NSData * imageData) {
        imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:self.imageUrl]];
        UIImage *image = [UIImage imageWithData:imageData];
        [self setImage:image];
        
    }];
    */
}


- (void)processImageDataWithBlock:(void (^)(NSData * imageData))processImage
{
    NSString *imageurl = self.imageUrl;
    dispatch_queue_t callerQueue = dispatch_get_current_queue();
    dispatch_queue_t downloadQueue = dispatch_queue_create("image donwloader", NULL);
    dispatch_async(downloadQueue, ^{
        NSData * imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:imageurl]];
        dispatch_async(callerQueue, ^{
            processImage(imageData);
        });
    });
    dispatch_release(downloadQueue);
    
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
    [self setImage:image];
    [self setViewSize:image];
    if ( [finishTarget retainCount] > 0 && [finishTarget respondsToSelector:finishAction]) {
        [finishTarget performSelector:finishAction  withObject:nil];
    }
}

- (void) setViewSize:(UIImage *)image
{
    if (mTempImageType == 2) {                  //重新调整列表页图片宽度，使其比例适中
        CGRect frame = self.frame;
        CGFloat frameHeight = frame.size.height;
        CGFloat realWidth = image.size.width;
        CGFloat realHeight = image.size.height;
        CGFloat frameWidth = realWidth * frameHeight/realHeight;
        frameWidth = frameWidth > 260 ? 260:frameWidth;
        frameWidth = frameWidth < 40 ? 40:frameWidth;
        
        [self setFrame:CGRectMake(frame.origin.x, frame.origin.y, frameWidth, frameHeight)];
    }
    else if(mTempImageType == 5){              //微博图片展示列表中，对微博图片进行切割取中间部分－－－－－－left image 宽100 长100  cellPic:102.5
        [self setImageSze:image withWidth:100 withHeight:100];
    }
    else if(mTempImageType == 6){  
        [self setImageSze:image withWidth:100 withHeight:100];
    }
}

- (void)setImageSze:(UIImage *)image
          withWidth:(float) width 
         withHeight:(float) height
{
    CGFloat realX ;
    CGFloat realY ;
    CGFloat realWidth;
    CGFloat realHeight;
    
    float xScale = image.size.width / width ;
    float yScale = image.size.height / height;
    
    float coeScale;
    if (xScale < yScale) {
        coeScale = xScale;
    }else {
        coeScale = yScale;
    }

    realX = (image.size.width < width)?0:(image.size.width-coeScale * width)/2;
    realY = (image.size.height < height)?0:(image.size.height-coeScale * height)/2;
    realWidth  = (image.size.width < width)?image.size.width:coeScale * width;
    realHeight = (image.size.height < height)?image.size.height:coeScale * height;

    UIGraphicsBeginImageContext(CGSizeMake(realWidth, realHeight));
    
    CGRect myImageRect = CGRectMake(realX, realY, realWidth, realHeight);
    CGImageRef imageRef = image.CGImage;
    CGImageRef subImageRef = CGImageCreateWithImageInRect(imageRef, myImageRect);
    
    
    
    CGSize size;
    
    size.width = realWidth;
    
    size.height = realHeight;

    UIGraphicsBeginImageContext(size);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextDrawImage(context, myImageRect, subImageRef);
    
    UIImage* destImage = [UIImage imageWithCGImage:subImageRef];
    
    UIGraphicsEndImageContext();
    
    
    //缩小
    
    UIGraphicsBeginImageContext(CGSizeMake(width, height));
    [destImage drawInRect:CGRectMake(self.frame.origin.x , self.frame.origin.y, width, height)];    
    [self setImage:destImage];
    UIGraphicsEndImageContext();
    [self setFrame:CGRectMake(self.frame.origin.x , self.frame.origin.y, width, height)]; 

}
- (void)dealloc {
    [mImageUrl release];
    [super dealloc];
}

@end