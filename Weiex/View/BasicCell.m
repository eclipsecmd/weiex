//
//  BasicCell.m
//  WeiTansuo
//
//  Created by hyq on 10/29/11.
//  Copyright 2011 Invidel. All rights reserved.
//

#import "BasicCell.h"

@implementation BasicCell

@synthesize bigImgTarget;
@synthesize showBigImgAction;
@synthesize timeLabel = mTimeLabel;
@synthesize userName = mUserName;
@synthesize cellContentView = mContentView;
@synthesize relativeLocation = mRelativeLocation;
@synthesize userPicView = mUserPicView;
@synthesize middlePicView = mMiddlePicView;
@synthesize btmRightCornerView = mBtmRightCornerView;
@synthesize bmiddlePicUrl = mBmiddlePicUrl;
//add by max
@synthesize statusImgOne   = mStatusImgOne;
@synthesize statusImgTwo   = mStatusImgTwo;
@synthesize statusImgThree = mStatusImgThree;

@synthesize starOptImage   = mStarOptImage;
@synthesize starAmount     = mStarAmount;
//@synthesize viewHisImage   = mViewHisImage;
//@synthesize viewAmount     = mViewAmount;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

/**根据内容调整控件高度**/
- (void) sizeToFit
{
    [super sizeToFit];
}
/**获取cell高度**/
- (CGFloat) getCellHeight
{
    CGFloat height = 110.f;//随意
    return height;
}

@end
