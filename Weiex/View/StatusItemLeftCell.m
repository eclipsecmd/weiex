//
//  StatusItemLeftCell.m
//  WeiTansuo
//
//  Created by hyq on 10/22/11.
//  Copyright 2011 Invidel. All rights reserved.
//

#import "StatusItemLeftCell.h"


#define MAX_MIDDLEPIC_WIDTH  260
#define MIN_MIDDLEPIC_WIDTH  40
#define MAX_MIDDLEPIC_HEIGHT  80

@implementation StatusItemLeftCell



- (id) initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        //左边的图
        mMiddlePicView = [[UrlImageView alloc] initWithFrame:CGRectMake(5.f, 5.f, 100.f, 100.f)]; 
        mMiddlePicView.layer.masksToBounds = YES;
        mMiddlePicView.layer.cornerRadius = 5.0;
        [self addSubview:mMiddlePicView];
        
        //相对位置
        mRelativeLocation = [[UILabel alloc] initWithFrame:CGRectMake(10.f, 10.f, 90.f, 14.f)];        
        mRelativeLocation.font = [UIFont fontWithName:@"Arial" size:10];
        mRelativeLocation.backgroundColor = [UIColor clearColor];
        mRelativeLocation.textColor = [UIColor whiteColor];
        
        //用户头像
        mUserPicView = [[UrlImageView alloc] initWithFrame:CGRectMake(108.f, 5.f, 30.f, 30.f)];        
        mUserPicView.highlighted = YES;
        mUserPicView.layer.masksToBounds = YES;
        mUserPicView.layer.cornerRadius = 5.0;
        [self addSubview:mUserPicView];
        
        //用户名
        mUserName = [[UILabel alloc] initWithFrame:CGRectMake(140.f, 10.f, 110.f, 16.f)];
        mUserName.font = [UIFont fontWithName:@"TrebuchetMS" size:14];
        mUserName.backgroundColor = [UIColor clearColor];
        [self addSubview:mUserName];
        
        //发表时间
        mTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(255.f, 12.f, 50.f, 12.f)];
        mTimeLabel.font = [UIFont fontWithName:@"Arial" size:11];
        mTimeLabel.backgroundColor = [UIColor clearColor];
        mTimeLabel.textColor = [UIColor grayColor];
        
        //详细内容
        mContentView = [[UILabel alloc] initWithFrame:CGRectMake(110.f, 35.f, 195.f, 55.f)];
        mContentView.font = [UIFont systemFontOfSize:12];
        mContentView.backgroundColor = [UIColor clearColor];
        [mContentView setNumberOfLines:0];
        mContentView.lineBreakMode = UILineBreakModeWordWrap;
        [self addSubview:mContentView];
                
        //加星显示
        mStarOptImage = [[UIImageView alloc] initWithFrame:CGRectMake(220.f+20.f, 87.f, 15.f, 15.f)];
        mStarOptImage.image = [UIImage imageNamed:@"Like_icon.png"];
        mStarOptImage.backgroundColor = [UIColor clearColor];

        mStarAmount = [[UILabel alloc] initWithFrame:CGRectMake(240.f+20.f, 90.f, 20.f, 12.f)];        
        mStarAmount.font = [UIFont fontWithName:@"Arial" size:12];
        mStarAmount.backgroundColor = [UIColor clearColor];
        mStarAmount.textColor = [UIColor grayColor];        
        //浏览显示
//        mViewHisImage = [[UIImageView alloc] initWithFrame:CGRectMake(270.f, 87.f, 15.f, 15.f)];
//        mViewHisImage.image = [UIImage imageNamed:@"look_icon.png"];
//        mViewHisImage.backgroundColor = [UIColor clearColor];
        
//        mViewAmount = [[UILabel alloc] initWithFrame:CGRectMake(290.f, 90.f, 20.f, 12.f)];        
//        mViewAmount.font = [UIFont fontWithName:@"Arial" size:12];
//        mViewAmount.backgroundColor = [UIColor clearColor];
//        mViewAmount.textColor = [UIColor grayColor];          
    
        //相对位置背景
        UIView * relativeLocationBg = [[UIView alloc] initWithFrame:CGRectMake(8.f, 8.f, 94.f, 15.f)];        
        [relativeLocationBg setBackgroundColor:[UIColor blackColor]];
        [relativeLocationBg setAlpha:0.3];
        [self addSubview:relativeLocationBg];
        [relativeLocationBg release];
        
        [self addSubview:mRelativeLocation];
        [self addSubview:mTimeLabel];
        [self addSubview:mStarOptImage];
        [self addSubview:mStarAmount];
//        [self addSubview:mViewHisImage];
//        [self addSubview:mViewAmount];
    }
    return self;
}

/**根据内容调整控件高度**/
-(void) sizeToFit
{
    [super sizeToFit];
    //调整图片部分大小
    if ([mMiddlePicView.imageUrl length] <= 5) {
        [mMiddlePicView setFrame:CGRectMake(0, 0, 0, 0)];
    }else {
        //点击看大图
        UIButton * showBigImageButton = [[UIButton alloc] initWithFrame:mMiddlePicView.frame];
        [showBigImageButton addTarget:self action:@selector(showBigImage) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:showBigImageButton];
        [showBigImageButton release];
    }
}
/**获取cell高度**/
- (CGFloat) getCellHeight
{
    CGFloat height = 110.f;
    return height;
}
- (void)dealloc
{
    [mBmiddlePicUrl release];
    [mTimeLabelImage release];
    [mTimeLabel release];
    [mContentView release];
    [mUserName release];
    [mRelativeLocation release];
    [mMiddlePicView release];
    [mUserPicView release];
    
    [super dealloc];
}

#pragma mark -
#pragma mark - 事件
/**显示大图片**/
- (void)showBigImage
{
    if ( [bigImgTarget retainCount] > 0 && [bigImgTarget respondsToSelector:showBigImgAction]) {
        [bigImgTarget performSelector:showBigImgAction  withObject:mBmiddlePicUrl];
    }    
}

@end
