//
//  StatusItemCellPro.m
//  WeiTansuo
//
//  Created by CMD on 9/20/11.
//  Copyright 2011 Invidel. All rights reserved.
//

#import "StatusItemCellPro.h"
#import <QuartzCore/QuartzCore.h>
#import "BigImageView.h"

#define MAX_MIDDLEPIC_WIDTH  120
#define MIN_MIDDLEPIC_WIDTH  40
#define MAX_MIDDLEPIC_HEIGHT  80

@implementation StatusItemCellPro

@synthesize bigImgTarget;
@synthesize showBigImgAction;
@synthesize timeLabel = mTimeLabel;
@synthesize cellContentView = mContentView;
@synthesize relativeLocation = mRelativeLocation;
@synthesize middlePicView = mMiddlePicView;
@synthesize btmRightCornerView = mBtmRightCornerView;

@synthesize reTeweetView = mReTeweetView;
@synthesize origialName = mOrigialName;
@synthesize origialContent = mOrigialContent;
@synthesize origialSmallPic = mOrigialSmallPic;
@synthesize isRetweet = mIsRetwwet;

@synthesize middlePicUrl = mMiddlePicUrl;
@synthesize origialPicUrl = mOrigialPicUrl;


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        mIsRetwwet = NO;
        
        //详细内容
        mContentView = [[UILabel alloc] initWithFrame:CGRectMake(5, 5, 300, 0)];
        mContentView.font = [UIFont systemFontOfSize:15];
        [mContentView setNumberOfLines:0];
        [mContentView setBackgroundColor:[UIColor clearColor]];
        mContentView.lineBreakMode = UILineBreakModeWordWrap;
        [self addSubview:mContentView];
        
        //自身weibo的大图
        mMiddlePicView = [[UrlImageView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)]; 
        [self addSubview:mMiddlePicView];
        
        //相对位置
        mRelativeLocation = [[UILabel alloc] initWithFrame:CGRectMake(2, 1, 0, 12)];        
        mRelativeLocation.font = [UIFont fontWithName:@"Arial" size:11];
        mRelativeLocation.textColor = [UIColor grayColor];
        [mRelativeLocation setBackgroundColor:[UIColor clearColor]];
        //发表时间
        mTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(mRelativeLocation.frame.size.width + mRelativeLocation.frame.origin.x + 2, 1.f, 0.f, 12.f)];
        mTimeLabel.font = [UIFont fontWithName:@"Arial" size:11];
        mTimeLabel.textColor = [UIColor grayColor];
        [mTimeLabel setBackgroundColor:[UIColor clearColor]];
        //右下角
        mBtmRightCornerView = [[UIView alloc] initWithFrame:CGRectMake(55.f, 0.f, 200.f, 15.f)];
        [mBtmRightCornerView addSubview:mRelativeLocation];
        //[mBtmRightCornerView addSubview:mTimeLabel];
        
        [self addSubview:mBtmRightCornerView];
        
        mReTeweetView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
        [mReTeweetView setBackgroundColor:[UIColor colorWithRed:245/255.f green:245/255.f blue:247/255.f alpha:1]];
        mOrigialName = [[UILabel alloc] init];
        [mOrigialName setBackgroundColor:[UIColor clearColor]];
        [mOrigialName setFont:[UIFont fontWithName:@"Arial" size:15]];
        [mOrigialName setFrame:CGRectMake(10, 4, 250, 15)];
        [mReTeweetView addSubview:mOrigialName];
        
        mOrigialContent = [[UILabel alloc] init];
        [mOrigialContent setBackgroundColor:[UIColor clearColor]];
        [mOrigialContent setNumberOfLines:0];
        [mOrigialContent setFont:[UIFont fontWithName:@"Arial" size:14]];
        [mReTeweetView addSubview:mOrigialContent];
        
        //转发的图
        mOrigialSmallPic = [[UrlImageView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
        [mReTeweetView addSubview:mOrigialSmallPic];
        
        
        
    }
    return self;
}
- (void)dealloc
{
    [mOrigialSmallPic release];
    [mOrigialContent release];
    [mOrigialName release];
    [mReTeweetView release];
    [mBtmRightCornerView release];
    [mTimeLabel release];
    [mRelativeLocation release];
    [mMiddlePicView release];
    [mContentView release];
    [mOrigialPicUrl release];
    [mMiddlePicUrl release];
    
    [super dealloc];
}

#pragma mark -
#pragma mark - 布局调整

/**根据内容调整控件高度**/
-(void) sizeToFit
{
    [super sizeToFit];
    //调整内容部分大小
    CGSize contentViewSize = [mContentView.text sizeWithFont:[UIFont fontWithName:@"Arial" size:15] 
                                           constrainedToSize:CGSizeMake(310,500)  
                                               lineBreakMode:UILineBreakModeWordWrap];
    CGRect contentViewFrame = mContentView.frame;
    [mContentView setFrame:CGRectMake(contentViewFrame.origin.x, contentViewFrame.origin.y, 
                                      contentViewSize.width, contentViewSize.height)];
    //调整图片部分大小
    if ([mMiddlePicView.imageUrl length] <= 5) {
        [mMiddlePicView setFrame:CGRectMake(contentViewFrame.origin.x, contentViewFrame.origin.y + contentViewSize.height + 5.f, 0, 0)];
    }else {
        [mMiddlePicView setFrame:CGRectMake(contentViewFrame.origin.x, contentViewFrame.origin.y + contentViewSize.height + 5.f, MAX_MIDDLEPIC_WIDTH, MAX_MIDDLEPIC_HEIGHT)];
        [self resetMiddlePicImage];
        UIButton * showBigImageButton = [[UIButton alloc] initWithFrame:mMiddlePicView.frame];
        [showBigImageButton addTarget:self action:@selector(showBigImage) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:showBigImageButton];
        [showBigImageButton release];
    }  
      
    //转发部分
    CGFloat reTweetHight = 0.f;
    if (mIsRetwwet) {
        [mReTeweetView removeFromSuperview];
        [self addSubview:mReTeweetView];
        
        [mOrigialContent setFrame:CGRectMake(10, 20, 260, 0)];
        [mOrigialContent sizeToFit];
        
        if ([mOrigialSmallPic.imageUrl length] <= 5) {
            [mOrigialSmallPic setFrame:CGRectMake(10, mOrigialContent.frame.size.height + 15 + 10, 0, 0)];
        }
        else {
            [mOrigialSmallPic setFrame:CGRectMake(10, mOrigialContent.frame.size.height + 15 + 10, MAX_MIDDLEPIC_WIDTH, MAX_MIDDLEPIC_HEIGHT)];
            [self resetOrigialSmallPicImage];
            //点击看大图
            UIButton * showBigImageButton = [[UIButton alloc] initWithFrame:mOrigialSmallPic.frame];
            [showBigImageButton addTarget:self action:@selector(showRetwwetBigImage) forControlEvents:UIControlEventTouchUpInside];
            [mReTeweetView addSubview:showBigImageButton];
            [showBigImageButton release];
        }
        [mReTeweetView setFrame:CGRectMake(15, mMiddlePicView.frame.origin.y + mMiddlePicView.frame.size.height + 5, 275, 15 + mOrigialContent.frame.size.height + mOrigialSmallPic.frame.size.height + 15 + 5)];
        mReTeweetView.layer.cornerRadius = 5.f;
        reTweetHight = mReTeweetView.frame.size.height;
    } 
    else {
        [mReTeweetView removeFromSuperview];
    }
    
    //调整右下角部分大小
    //[mTimeLabel sizeToFit];
    [mRelativeLocation sizeToFit];
    [mRelativeLocation setFrame:CGRectMake(5, 2, mRelativeLocation.frame.size.width, mRelativeLocation.frame.size.height)];
    [mTimeLabel setFrame:CGRectMake(2, 3.f, mTimeLabel.frame.size.width, mRelativeLocation.frame.size.height)];
    CGRect btmRightFrame = mBtmRightCornerView.frame;
    CGFloat alignConrnerView = 300 - mRelativeLocation.frame.size.width - 5;
    [mBtmRightCornerView setFrame:CGRectMake(alignConrnerView, 
                                             contentViewFrame.origin.y + contentViewSize.height +mMiddlePicView.frame.size.height + 10.f + reTweetHight + 3.f, 
                                             btmRightFrame.size.width, 
                                             btmRightFrame.size.height)];
}
/**获取cell高度**/
- (CGFloat)getCellHeight
{
    CGFloat height = mContentView.frame.size.height + 25.f + mBtmRightCornerView.frame.size.height;
    if([mMiddlePicView.imageUrl length] > 5) {
        height += mMiddlePicView.frame.size.height;
    }
    if (mIsRetwwet) {
        height += mReTeweetView.frame.size.height;
    }
    return height;
}

/**图片下载成功后的回调**/
- (void)resetMiddlePicImage
{
    //重新调整图片的缩放比例
    CGRect frame = mMiddlePicView.frame;
    CGFloat frameHeight = frame.size.height;
    CGFloat realWidth = mMiddlePicView.image.size.width;
    CGFloat realHeight = mMiddlePicView.image.size.height;
    CGFloat frameWidth = realWidth * frameHeight/realHeight;
    
    frameWidth = frameWidth > MAX_MIDDLEPIC_WIDTH ? MAX_MIDDLEPIC_WIDTH:frameWidth;
    frameWidth = frameWidth < MIN_MIDDLEPIC_WIDTH ? MIN_MIDDLEPIC_WIDTH:frameWidth;
    [mMiddlePicView setFrame:CGRectMake(frame.origin.x, frame.origin.y, frameWidth, frameHeight)];
    
}
- (void)resetOrigialSmallPicImage
{
    //重新调整图片的缩放比例
    CGRect frame = mOrigialSmallPic.frame;
    CGFloat frameHeight = frame.size.height;
    CGFloat realWidth = mOrigialSmallPic.image.size.width;
    CGFloat realHeight = mOrigialSmallPic.image.size.height;
    CGFloat frameWidth = realWidth * frameHeight/realHeight;

    frameWidth = frameWidth > MAX_MIDDLEPIC_WIDTH ? MAX_MIDDLEPIC_WIDTH:frameWidth;
    frameWidth = frameWidth < 40 ? 40:frameWidth;
    [mOrigialSmallPic setFrame:CGRectMake(frame.origin.x, frame.origin.y, frameWidth, frameHeight)];
}

#pragma mark -
#pragma mark - 事件
/**显示大图片**/
- (void)showBigImage
{
    if ( [bigImgTarget retainCount] > 0 && [bigImgTarget respondsToSelector:showBigImgAction]) {
        [bigImgTarget performSelector:showBigImgAction  withObject:mMiddlePicUrl];
    }    
}
- (void)showRetwwetBigImage
{
    if ( [bigImgTarget retainCount] > 0 && [bigImgTarget respondsToSelector:showBigImgAction]) {
        [bigImgTarget performSelector:showBigImgAction  withObject:mOrigialPicUrl];
    }
}
@end
