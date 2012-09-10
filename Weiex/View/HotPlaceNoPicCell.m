//
//  HotPlaceNoPicCell.m
//  WeiTansuo
//
//  Created by Yuqing Huang on 11/19/11.
//  Copyright (c) 2011 Invidel. All rights reserved.
//

#import "HotPlaceNoPicCell.h"

@implementation HotPlaceNoPicCell

@synthesize infoArea  = mInfoArea;
@synthesize placeInfo = mPlaceInfo;
@synthesize placeDescription = mPlaceDescription;
@synthesize starImage  = mStarImage;
@synthesize starAmount = mStarAmount;
@synthesize viewImage  = mViewImage;
@synthesize viewAmount = mViewAmount;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        //信息区域
        mInfoArea = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320.f, 55.f)];
        [mInfoArea setBackgroundColor:[UIColor colorWithRed:153/255 green:204/255 blue:225/255 alpha:0.8]];
        
        //1 信息——热点描述
        mPlaceDescription = [[UILabel alloc] initWithFrame:CGRectMake(10.f, 6.f, 300.f, 20.f)];
        mPlaceDescription.font = [UIFont systemFontOfSize:14];
        [mPlaceDescription setTextColor:[UIColor whiteColor]];
        [mPlaceDescription setBackgroundColor:[UIColor clearColor]];
        [mPlaceDescription setNumberOfLines:0];
        mPlaceDescription.lineBreakMode = UILineBreakModeWordWrap;
        [mInfoArea addSubview:mPlaceDescription];
        
        //2 信息——热点位置
        mPlaceInfo = [[UILabel alloc] initWithFrame:CGRectMake(10.f,28.f, 170.f, 25.f)];
        mPlaceInfo.font = [UIFont systemFontOfSize:16];
        [mPlaceInfo setTextColor:[UIColor whiteColor]];
        [mPlaceInfo setBackgroundColor:[UIColor clearColor]];
        [mPlaceInfo setNumberOfLines:0];
        mPlaceInfo.lineBreakMode = UILineBreakModeWordWrap;
        [mInfoArea addSubview:mPlaceInfo];
        
        //3 信息——加星 和 浏览数
        //加星显示
        mStarImage = [[UIImageView alloc] initWithFrame:CGRectMake(184.f, 30.f, 18.f, 18.f)];
        mStarImage.image = [UIImage imageNamed:@"hot2.png"];
        mStarImage.backgroundColor = [UIColor clearColor];
        [mInfoArea addSubview:mStarImage];
        
        mStarAmount = [[UILabel alloc] initWithFrame:CGRectMake(207.f, 30.f, 40.f, 18.f)];        
        mStarAmount.font = [UIFont systemFontOfSize:14];
        mStarAmount.textColor = [UIColor whiteColor]; 
        [mStarAmount setBackgroundColor:[UIColor clearColor]];
        [mInfoArea addSubview:mStarAmount];
        //浏览显示
        mViewImage = [[UIImageView alloc] initWithFrame:CGRectMake(252.f, 30.f, 18.f, 18.f)];
        mViewImage.image = [UIImage imageNamed:@"hot2.png"];
        mViewImage.backgroundColor = [UIColor clearColor];
        [mInfoArea addSubview:mViewImage];
        
        mViewAmount = [[UILabel alloc] initWithFrame:CGRectMake(275.f, 30.f, 40.f, 18.f)];        
        mViewAmount.font = [UIFont systemFontOfSize:14];
        mViewAmount.textColor = [UIColor whiteColor]; 
        [mViewAmount setBackgroundColor:[UIColor clearColor]];
        [mInfoArea addSubview:mViewAmount];
        [self addSubview:mInfoArea];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

-(void)dealloc{
    [mInfoArea release];
    [mPlaceDescription release];
    [mPlaceInfo release];
    [mStarImage release];
    [mStarAmount release];
    [mViewImage release];
    [mViewAmount release];
    
    [super dealloc];
}

/**根据内容调整控件高度**/
-(void) sizeToFit
{
    [super sizeToFit];
}
/**获取cell高度**/
- (CGFloat) getCellHeight
{
    //CGFloat height = mUserName.frame.size.height + mContentView.frame.size.height + 25.f + mBtmRightCornerView.frame.size.height + 5.f;
    CGFloat height = 120.f;
    return height;
}

@end
