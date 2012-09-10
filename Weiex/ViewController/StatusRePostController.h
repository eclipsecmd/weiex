//
//  StatusRePostController.h
//  WeiTansuo
//
//  Created by Sai Li on 8/23/11.
//  Copyright 2011 Invidel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Status.h"
#import "WeiboClient.h"
#import "ClickImageView.h"
#import "SoftNoticeView.h"
#import "myCheckBox.h"
#import "PlacesViewController.h"

@interface StatusRePostController : UIViewController {
    Status *                    mStatus;
    UITextView *                mRepostContent;
    OAuthEngine *               mOAuthEngine;                       //转发内容 
    BOOL                        mIsReposting;                       //是否正在转发
    int                         mRepostState;                       //0:未转发 1:转发成功 2:转发失败 3:转发中
    SoftNoticeView *            mSoftNoticeViewLoad;                //加载框
    UISwitch *                  mSwitchForComment;
    UISwitch *                  mSwitchForOrigialComment;
    UILabel *                   mSwitchForCommentLabel;
    UILabel *                   mSwitchForOrigialCommentLabel;
    myCheckBox *                  mCheckboxToUser;                    //是否选择评论给作者
    BOOL                        mCheckBoxSelected;
    myCheckBox *                  mCheckboxOriginalAuthor;
    BOOL                        mCheckBoxSelectedOriginalAuthor;
    
    UILabel *                   mOriginalLable;
    UIButton *                  mChoosePlace;
    NSString *                  mRepostPre;
    NSMutableString *           mRepostEnd;
    NSMutableString *           mRepostText;
    UIView *                    mBackView;    
}

@property (nonatomic,assign) id finishTarget;
@property (nonatomic,assign) SEL finishAction;

@property (nonatomic, retain) Status * status;
@property (nonatomic, retain) OAuthEngine * oAuthEngine;

- (int) getIsComment;
- (void) alertForRePost:(NSString *)message;
- (void) setChoosePlaceButtonCGRect;

@end
