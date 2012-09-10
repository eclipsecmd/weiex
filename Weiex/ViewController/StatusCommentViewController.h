//
//  StatusCommentViewController.h
//  WeiTansuo
//
//  Created by CMD on 10/9/11.
//  Copyright 2011 Invidel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Status.h"
#import "WeiboClient.h"
#import "ClickImageView.h"
#import "SoftNoticeView.h"
#import "myCheckBox.h"
#import "PlacesViewController.h"

@interface StatusCommentViewController : UIViewController
{
    Status *                    mStatus;
    UITextView *                mCommentContent;
    OAuthEngine *               mOAuthEngine;                       //转发内容 
    BOOL                        mIsReposting;                       //是否正在转发
    int                         mCommentState;                       //0:未转发 1:转发成功 2:转发失败 3:转发中
    SoftNoticeView *            mSoftNoticeViewLoad;                //加载框
    UISwitch *                  mSwitchForComment;
    UISwitch *                  mSwitchForOrigialComment;
    UILabel *                   mSwitchForCommentLabel;
    UILabel *                   mSwitchForOrigialCommentLabel;
    myCheckBox *                mCheckboxToUser;                    //是否选择评论给作者

    UILabel *                   mOriginalLable;
    UIButton *                  mChoosePlace;
    NSString *                  mRepostPre;
    NSMutableString *           mRepostEnd;
    NSMutableString *           mRepostText;
}

@property (nonatomic,assign) id finishTarget;
@property (nonatomic,assign) SEL finishAction;

@property (nonatomic, retain) Status * status;
@property (nonatomic, retain) OAuthEngine * oAuthEngine;

- (void)alertForComment:(NSString *)message;

@end
