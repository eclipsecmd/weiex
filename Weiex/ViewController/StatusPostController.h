//
//  StatusPostController.h
//  WeiTansuo
//
//  Created by Liu Quan on 11/2/11.
//  Copyright 2011 Invidel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Status.h"
#import "WeiboClient.h"
#import "ClickImageView.h"
#import "SoftNoticeView.h"
#import "TakePictureViewController.h"
#import <QuartzCore/QuartzCore.h>

@interface StatusPostController : UIViewController <UIImagePickerControllerDelegate>
{
    Status *                    mStatus;
    UITextView *                mPostContent;
    OAuthEngine *               mOAuthEngine;                       //转发内容 
    BOOL                        mIsPosting;                       //是否正在发
    int                         mPostState;                       //0:未发 1:发成功 2:发失败 3:发中
    SoftNoticeView *            mSoftNoticeViewLoad;                //加载框
    UIButton *                  cameraButton;                   //照相按钮提出来，使UI可变
    



}
@property (nonatomic,assign) id finishTarget;
@property (nonatomic,assign) SEL finishAction;

@property (nonatomic, retain) Status * status;
@property (nonatomic, retain) OAuthEngine * oAuthEngine;
- (void)alertForRePost:(NSString *)message;
- (void)toCamera;
- (void)showCameraPic;

@end
