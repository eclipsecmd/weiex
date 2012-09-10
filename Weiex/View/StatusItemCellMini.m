//
//  StatusItemCellMini.m
//  WeiTansuo
//
//  Created by CMD on 10/5/11.
//  Copyright 2011 Invidel. All rights reserved.
//

#import "StatusItemCellMini.h"

#define MAX_MIDDLEPIC_WIDTH  260
#define MAX_MIDDLEPIC_HEIGHT  80

@implementation StatusItemCellMini

@synthesize timeLabel = mTimeLabel;
@synthesize userName = mUserName;
@synthesize cellContentView = mContentView;
@synthesize relativeLocation = mRelativeLocation;
@synthesize userPicView = mUserPicView;
@synthesize middlePicView = mMiddlePicView;
@synthesize btmRightCornerView = mBtmRightCornerView;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        //用户头像
        mUserPicView = [[UrlImageView alloc] initWithFrame:CGRectMake(5.f, 5.f, 40.f, 40.f)];        
        mUserPicView.highlighted = YES;
        mUserPicView.layer.masksToBounds = YES;
        mUserPicView.layer.cornerRadius = 5.0;
        [self addSubview:mUserPicView];
        
        //用户名
        mUserName = [[UILabel alloc] initWithFrame:CGRectMake(55.f, 5.f, 150.f, 16.f)];
        mUserName.font = [UIFont fontWithName:@"TrebuchetMS-Bold" size:15];
        [self addSubview:mUserName];
        
        //详细内容
        mContentView = [[UILabel alloc] initWithFrame:CGRectMake(55.0f, 27.0f, 0, 0)];
        mContentView.font = [UIFont systemFontOfSize:15];
        [mContentView setNumberOfLines:0];
        mContentView.lineBreakMode = UILineBreakModeWordWrap;
        [self addSubview:mContentView];
        
        //大图
        mMiddlePicView = [[UrlImageView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)]; 
        mMiddlePicView.layer.masksToBounds = YES;
        mMiddlePicView.layer.cornerRadius = 5.0;
        [self addSubview:mMiddlePicView];
        
        //位置图标
        mRelativeLocationImage = [[UIImageView alloc] initWithFrame:CGRectMake(0.f, 2.f, 12.f, 12.f)];
        mRelativeLocationImage.image = [UIImage imageNamed:@"position15px.png"];
        //相对位置
        mRelativeLocation = [[UILabel alloc] initWithFrame:CGRectMake(mRelativeLocationImage.frame.size.width + 2, 1.f, 0.f, 12.f)];        
        mRelativeLocation.font = [UIFont fontWithName:@"Arial" size:11];
        mRelativeLocation.textColor = [UIColor grayColor];
        //时间图标
        mTimeLabelImage = [[UIImageView alloc] initWithFrame:CGRectMake(mRelativeLocation.frame.size.width + mRelativeLocation.frame.origin.x + 2, 2.f, 12.f, 12.f)];
        mTimeLabelImage.image = [UIImage imageNamed:@"clock15px.png"];
        //发表时间
        mTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(mTimeLabelImage.frame.size.width + mTimeLabelImage.frame.origin.x + 2, 1.f, 0.f, 12.f)];
        mTimeLabel.font = [UIFont fontWithName:@"Arial" size:11];
        mTimeLabel.textColor = [UIColor grayColor];
        //右下角
        mBtmRightCornerView = [[UIView alloc] initWithFrame:CGRectMake(55.f, 0.f, 255.f, 15.f)];
        [mBtmRightCornerView addSubview:mRelativeLocationImage];
        [mBtmRightCornerView addSubview:mRelativeLocation];
        [mBtmRightCornerView addSubview:mTimeLabelImage];
        [mBtmRightCornerView addSubview:mTimeLabel];
        
        [self addSubview:mBtmRightCornerView];

    }
    return self;
}


- (void) sizeToFit
{
    [super sizeToFit];
    //调整内容部分大小
    CGSize contentViewSize = [mContentView.text sizeWithFont:[UIFont fontWithName:@"Arial" size:15] 
                                           constrainedToSize:CGSizeMake(260,300)  
                                               lineBreakMode:UILineBreakModeWordWrap];
    CGRect contentViewFrame = mContentView.frame;
    [mContentView setFrame:CGRectMake(contentViewFrame.origin.x, contentViewFrame.origin.y, 
                                      contentViewSize.width, contentViewSize.height)];
    //调整图片部分大小
    if ([mMiddlePicView.imageUrl length] <= 5) {
        [mMiddlePicView setFrame:CGRectMake(0, 0, 0, 0)];
    }else {
        [mMiddlePicView setFrame:CGRectMake(contentViewFrame.origin.x, contentViewFrame.origin.y+contentViewSize.height+5.f,MAX_MIDDLEPIC_WIDTH, MAX_MIDDLEPIC_HEIGHT)];
        [self resetMiddlePicImage];
    }  
    //调整右下角部分大小
    [mTimeLabel sizeToFit];
    [mRelativeLocation sizeToFit];    
    
    //[mRelativeLocationImage setFrame:CGRectMake(0.f, 2.f, 12.f, 12.f)];
    //[mRelativeLocation setFrame:CGRectMake(12 + 2, 2.f, 0.f, 0.f)];    
    [mTimeLabelImage setFrame:CGRectMake(mRelativeLocation.frame.size.width + mRelativeLocation.frame.origin.x + 2, 2.f, 12.f, 12.f)];
    [mTimeLabel setFrame:CGRectMake(mTimeLabelImage.frame.size.width + mTimeLabelImage.frame.origin.x + 2, 3.f, mTimeLabel.frame.size.width, 12.f)];
    
    
    CGRect btmRightFrame = mBtmRightCornerView.frame;
    CGFloat alignConrnerView = 310 - mRelativeLocationImage.frame.size.width - 2 - mRelativeLocation.frame.size.width - 2 - mTimeLabelImage.frame.size.width - 3 - mTimeLabel.frame.size.width;
    [mBtmRightCornerView setFrame:CGRectMake(alignConrnerView, 
                                             contentViewFrame.origin.y + contentViewSize.height +mMiddlePicView.frame.size.height + 10.f, 
                                             btmRightFrame.size.width, 
                                             btmRightFrame.size.height)];
    if ([mRelativeLocation.text length] == 0) {
        [mRelativeLocationImage removeFromSuperview];
    }

}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

/**获取cell高度**/
- (CGFloat) getCellHeight
{
    CGFloat height = mUserName.frame.size.height + mContentView.frame.size.height + 25.f + mBtmRightCornerView.frame.size.height + 5.f;
    if([mMiddlePicView.imageUrl length] > 5) {
        height += mMiddlePicView.frame.size.height + 5.f;
    }
    if (height < mUserPicView.frame.size.height + 5.f) {
        height = mUserPicView.frame.size.height + 5.f;
    }
    return height;
}
/**图片下载成功后的回调**/
- (void) resetMiddlePicImage
{
    //重新调整图片的缩放比例
    CGRect frame = mMiddlePicView.frame;
    CGFloat frameHeight = frame.size.height;
    CGFloat realWidth = mMiddlePicView.image.size.width;
    CGFloat realHeight = mMiddlePicView.image.size.height;
    CGFloat frameWidth = realWidth * frameHeight/realHeight;
    if (frameWidth > MAX_MIDDLEPIC_WIDTH) {
        frameWidth = MAX_MIDDLEPIC_WIDTH;
    }
    [mMiddlePicView setFrame:CGRectMake(frame.origin.x, frame.origin.y, frameWidth, frameHeight)];
    
}

- (void)dealloc
{
    [mBtmRightCornerView release];
    [mTimeLabelImage release];
    [mRelativeLocationImage release];
    [mTimeLabel release];
    [mContentView release];
    [mUserName release];
    [mRelativeLocation release];
    [mMiddlePicView release];
    [mUserPicView release];
    
    [super dealloc];
}

@end
