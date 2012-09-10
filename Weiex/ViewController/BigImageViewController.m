//
//  BigImageViewController.m
//  WeiTansuo
//
//  Created by HYQ on 10/5/11.
//  Copyright 2011 Invidel. All rights reserved.
//

#import "BigImageViewController.h"

@implementation BigImageViewController

@synthesize bigImgTarget;
@synthesize removeBigImageAction;


- (id)initWithImageUrl:(NSString *) imageUrl
{
    self = [super init];
    if (self) {
        mImageUrl = [imageUrl copy];
    }
    return self;
}

- (void)dealloc
{
    [mBigImageView release];
    [mImageUrl release];
    [super dealloc];
}

#pragma mark -
#pragma mark - 视图



- (void)viewDidLoad
{
    [super viewDidLoad];
    //图片
    mBigImageView = [[BigImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 460)];
    [self.view addSubview:mBigImageView];
    mBigImageView.imageUrl = mImageUrl; 
    [mBigImageView.imageView addTarget:bigImgTarget action:removeBigImageAction];
    [mBigImageView showBigImage];
    
    //保存按钮
    UIButton * saveImageButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [saveImageButton setFrame:CGRectMake(240, 410, 50, 25)];
    [saveImageButton setBackgroundColor:[UIColor clearColor]];
    [saveImageButton setImage:[UIImage imageNamed:@"imagesavebutton.png"] forState:UIControlStateNormal];
    [saveImageButton setImage:[UIImage imageNamed:@"imagesavebutton2.png"] forState:UIControlStateHighlighted];
    [saveImageButton setBackgroundColor:[UIColor clearColor]];
    [saveImageButton addTarget:self action:@selector(saveImage) forControlEvents:UIControlEventTouchDown];
    [self.view addSubview:saveImageButton];
}


- (void)viewDidUnload
{
    [super viewDidUnload];
}

#pragma mark -
#pragma mark - 事件
/**保存图片**/
- (void)saveImage
{
    if (mIsSaving) {
        return;
    }
    mIsSaving = YES;
    UIImageWriteToSavedPhotosAlbum(mBigImageView.imageView.image, nil, nil, nil);
    [self alert:@"保存成功"];
}


/**提示框**/
- (void)alert:(NSString *)message
{
    mIsAlert = YES;
    mBigImageView.imageView.responseTarget = nil;
    SoftNoticeView * msgBox = [[SoftNoticeView alloc] initWithFrame:CGRectMake(90, 130, 140, 140)];
    [msgBox setMessage:message];
    [msgBox setActivityindicatorHidden:YES];
    [self.view addSubview:msgBox];
    [msgBox start];
    [self performSelector:@selector(closeAlert:) withObject:msgBox afterDelay:2];
    
}
- (void)closeAlert:(SoftNoticeView *)msgBox
{
    [msgBox stop];
    [msgBox removeFromSuperview];
    [msgBox release];
    mBigImageView.imageView.responseTarget = bigImgTarget;
    mIsSaving = NO;
    mIsAlert = NO;
}
@end
