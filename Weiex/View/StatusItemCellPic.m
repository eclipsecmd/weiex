//
//  StatusItemCellPic.m
//  WeiTansuo
//
//  Created by Yuqing Huang on 10/29/11.
//  Copyright 2011 Invidel. All rights reserved.
//

#import "StatusItemCellPic.h"

@implementation StatusItemCellPic

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {

        //微博图片区域
        mImgArea = [[UIView alloc] initWithFrame:CGRectMake(0.f, 0.f, 308.f, 104.f)];
        [self addSubview:mImgArea];

        //图片一
        mStatusImgOne = [[UrlImageView alloc] initWithFrame:CGRectMake(2, 2.f, 100.f,100.f)];  
        mStatusImgOne.highlighted = YES;
        mStatusImgOne.layer.masksToBounds = YES;
        mStatusImgOne.layer.cornerRadius = 5.0;
        [mImgArea addSubview:mStatusImgOne];

        //图片二
        mStatusImgTwo = [[UrlImageView alloc] initWithFrame:CGRectMake(104, 2.f, 100.f, 100.f)];        
        mStatusImgTwo.highlighted = YES;
        mStatusImgTwo.layer.masksToBounds = YES;
        mStatusImgTwo.layer.cornerRadius = 5.0;
        [mImgArea addSubview:mStatusImgTwo];

        //图片三
        mStatusImgThree = [[UrlImageView alloc] initWithFrame:CGRectMake(206, 2.f, 100.f, 100.f)];        
        mStatusImgThree.highlighted = YES;
        mStatusImgThree.layer.masksToBounds = YES;
        mStatusImgThree.layer.cornerRadius = 5.0;
        [mImgArea addSubview:mStatusImgThree];

    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

-(void)dealloc{
    [mImgArea release];
    [mStatusImgOne release];
    [mStatusImgTwo release];
    [mStatusImgThree release];
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
    CGFloat height = 104;
    return height;
}

@end
