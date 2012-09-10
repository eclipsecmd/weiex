//
//  HotPlaceNewCell.m
//  WeiTansuo
//
//  Created by Yuqing Huang on 11/22/11.
//  Copyright (c) 2011 Invidel. All rights reserved.
//

#import "HotPlaceNewCell.h"

@implementation HotPlaceNewCell

@synthesize infoArea   = mInfoArea;
@synthesize userImage  = mUserImage;
@synthesize userName   = mUserName;  
@synthesize placeinfo  = mPlaceinfo;
@synthesize starImage  = mStarImage;
@synthesize starView   = mStarView;
@synthesize starAmount = mStarAmount;
@synthesize starComment= mStarComment;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        //信息显示区
        //mInfoArea = [[UIView alloc] initWithFrame:CGRectMake(0.f,0.f,288.f,60.f)];
        //        //设置阴影
        //        [[mInfoArea layer] setShadowOffset:CGSizeMake(1, 1)];
        //        [[mInfoArea layer] setShadowRadius:5];
        //        [[mInfoArea layer] setShadowOpacity:1];
        //        [[mInfoArea layer] setShadowColor:[UIColor blackColor].CGColor];
        //设置边框
//        [[mInfoArea layer] setCornerRadius:5];
//        [[mInfoArea layer] setBorderWidth:2];
//        [[mInfoArea layer] setBorderColor:[UIColor blackColor].CGColor];
        
        //热点地区位置
        mPlaceinfo = [[UILabel alloc] initWithFrame:CGRectMake(20.f,20.f, 120.f, 20.f)];
        mPlaceinfo.font = [UIFont fontWithName:@"TrebuchetMS-Bold" size:18];
        [mPlaceinfo setTextColor:[UIColor grayColor]];
        [mPlaceinfo setBackgroundColor:[UIColor clearColor]];
        [mPlaceinfo setNumberOfLines:0];
        mPlaceinfo.lineBreakMode = UILineBreakModeWordWrap;
        [self addSubview:mPlaceinfo];
        
        //加星显示View
        mStarView = [[UIImageView alloc]initWithFrame:CGRectMake(210.f, 15.f, 76.f, 30.f)];
        [mStarView setImage:[UIImage imageNamed:@"Favorites_button.png"]];
//        mStarView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Favorites_button.png"]];
//        [mStarView setBounds:CGRectMake(200.f, 16.f, 76.f, 30.f)];
       
        //        [[mStarView layer] setShadowOffset:CGSizeMake(1, 1)];
        //        [[mStarView layer] setShadowRadius:5];
        //        [[mStarView layer] setShadowOpacity:2];
        //        [[mStarView layer] setShadowColor:[UIColor blackColor].CGColor];
        
        
        
        //加星数
        mStarAmount = [[UILabel alloc] initWithFrame:CGRectMake(36.f,0, 30.f, 30.f)];        
        mStarAmount.font = [UIFont fontWithName:@"TrebuchetMS-Bold" size:18];
        mStarAmount.textAlignment = UITextAlignmentCenter;
//        mStarAmount.textColor = [UIColor colorWithRed:0.092 green:0.474 blue:0.910 alpha:1];
            mStarAmount.textColor = [UIColor colorWithRed:0.1 green:0.5 blue:0.910 alpha:1];
        [mStarAmount setBackgroundColor:[UIColor clearColor]];
        [mStarView addSubview:mStarAmount];
          [self addSubview:mStarView];
       // [self addSubview:mInfoArea];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

-(void)dealloc{
    [mInfoArea release];
    [mInfoArea release];
    [mUserImage release];
    [mUserName release];  
    [mPlaceinfo release];
    [mStarImage release];
    [mStarView release];
    [mStarAmount release];
    [mStarComment release];
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
    CGFloat height = 85.f;
    return height;
}

@end
