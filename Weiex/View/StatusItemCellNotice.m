//
//  StatusItemCellNotice.m
//  WeiTansuo
//
//  Created by CMD on 10/19/11.
//  Copyright 2011 Invidel. All rights reserved.
//

#import "StatusItemCellNotice.h"
#import <QuartzCore/QuartzCore.h>

#define MAX_MIDDLEPIC_WIDTH  260
#define MIN_MIDDLEPIC_WIDTH  40
#define MAX_MIDDLEPIC_HEIGHT  80

@implementation StatusItemCellNotice

@synthesize userName = mUserName;
@synthesize contentLabel = mContentLabel;
@synthesize timeLabel = mTimeLabel;
@synthesize oriContentLabel = mOriContentLabel;
@synthesize userPicView = mUserPicView;
@synthesize replayButton = mReplyButton;
@synthesize oriContentUserLabel = mOriContentUserLabel;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        //用户头像
        mUserPicView = [[UrlImageView alloc] initWithFrame:CGRectMake(5, 5, 40, 40)];        
        mUserPicView.highlighted = YES;
        mUserPicView.layer.masksToBounds = YES;
        mUserPicView.layer.cornerRadius = 5.0;
        [self addSubview:mUserPicView];
        
        //用户名
        mUserName = [[UILabel alloc] initWithFrame:CGRectMake(55, 5, 150, 16)];
        [mUserName setFont:[UIFont fontWithName:@"TrebuchetMS-Bold" size:15]];
        [mUserName setBackgroundColor:[UIColor clearColor]];
        [self addSubview:mUserName];
        
        //时间图标
        mTimeLabelImage = [[UIImageView alloc] initWithFrame:CGRectMake(5, 5, 12, 12)];
        mTimeLabelImage.image = [UIImage imageNamed:@"clock15px.png"];
        //发表时间
        mTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(mTimeLabelImage.frame.size.width + mTimeLabelImage.frame.origin.x + 2, 1, 0, 12.f)];
        mTimeLabel.font = [UIFont fontWithName:@"Arial" size:11];
        mTimeLabel.textColor = [UIColor grayColor];
        mTimeLabel.backgroundColor = [UIColor clearColor];
        
        [self addSubview:mTimeLabel];
        [self addSubview:mTimeLabelImage];
        
        //
        //详细内容
        mContentLabel = [[UILabel alloc] initWithFrame:CGRectMake(55, 25, 265, 0)];
        mContentLabel.font = [UIFont systemFontOfSize:13];
        [mContentLabel setNumberOfLines:0];
        mContentLabel.lineBreakMode = UILineBreakModeWordWrap;
        [self addSubview:mContentLabel]; 
        
        
        //background is much big than content,alomst 5pix.
        mOriContentView = [[UIView alloc] initWithFrame:CGRectMake(55, 30, 265, 0)];
        [mOriContentView setBackgroundColor:[UIColor colorWithRed:220/255.f green:220/255.f blue:220/255.f alpha:1]];
        
        
        mOriContentUserLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 5, 200, 14)];
        [mOriContentUserLabel setBackgroundColor:[UIColor clearColor]];
        [mOriContentUserLabel setFont:[UIFont systemFontOfSize:14]];
        [mOriContentUserLabel setBackgroundColor:[UIColor clearColor]];
        [mOriContentView addSubview:mOriContentUserLabel];
        
        mOriContentView.layer.cornerRadius = 5.f;
        mOriContentLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 13, 255, 0)];
        [mOriContentLabel setFont:[UIFont systemFontOfSize:12]];
        [mOriContentLabel setNumberOfLines:0];
        [mOriContentLabel setBackgroundColor:[UIColor clearColor]];
        [mOriContentLabel setLineBreakMode:UILineBreakModeCharacterWrap];
        [mOriContentView addSubview:mOriContentLabel];    
        
        
        [self addSubview:mOriContentView];        
    }
    return self;
}

/**根据内容调整控件高度**/
-(void) sizeToFit
{
    [super sizeToFit];
    
    [mTimeLabel sizeToFit];
    [mTimeLabel setFrame:CGRectMake(315 - mTimeLabel.frame.size.width, 7, mTimeLabel.frame.size.width, mTimeLabel.frame.size.height)];
    [mTimeLabelImage setFrame:CGRectMake(mTimeLabel.frame.origin.x - 12 - 2, 7, 12, 12)];
    
    //调整内容部分大小
    CGSize contentViewSize = [mContentLabel.text sizeWithFont:[UIFont fontWithName:@"Arial" size:14] 
                                           constrainedToSize:CGSizeMake(260,300)  
                                               lineBreakMode:UILineBreakModeWordWrap];    
    CGRect contentViewFrame = mContentLabel.frame;
    [mContentLabel setFrame:CGRectMake(contentViewFrame.origin.x, contentViewFrame.origin.y, 
                                      contentViewSize.width, contentViewSize.height)];
    //[mOriContentLabel sizeToFit];
    if ([mOriContentLabel.text length] > 0) {
       [mOriContentView removeFromSuperview];
        [self addSubview:mOriContentView];
        
        CGSize oriContentViewSize = [mOriContentLabel.text sizeWithFont:[UIFont fontWithName:@"Arial" size:13]
                                                      constrainedToSize:CGSizeMake(250, 300)
                                                          lineBreakMode:UILineBreakModeCharacterWrap];
        CGRect oriContentViewFrame = mOriContentLabel.frame;
        [mOriContentLabel setFrame:CGRectMake(oriContentViewFrame.origin.x, contentViewFrame.origin.y - 5, oriContentViewSize.width, oriContentViewSize.height)];
        
        [mOriContentView setFrame:CGRectMake(55, mContentLabel.frame.size.height + mContentLabel.frame.origin.y + 5, 258, mOriContentLabel.frame.size.height + 30)];
        [self addSubview:mOriContentView];
    }
    else {
        [mOriContentView removeFromSuperview];
    }
    
    
}
/**获取cell高度**/
- (CGFloat) getCellHeight
{
    CGFloat height = 4.f;
    height += mContentLabel.frame.size.height + 20 + 10;
    if ([mOriContentLabel.text length] > 0) {
        height += mOriContentView.frame.size.height + 10;
    }
    return height;
}

- (void)pleaseComment
{
    
}
- (void)seeUserProfile
{
    
}
- (void)seeOriStatus
{
    
}


- (void)dealloc
{
    [mUserName release];
    [mContentLabel release];
    [mTimeLabel release];
    [mOriContentView release];
    [mOriContentLabel release];
    [mUserPicView release];
    [mTimeLabelImage release];
    [mReplyButton release];
    [super dealloc];
}



@end
