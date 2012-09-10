//
//  FeedbackController.h
//  WeiTansuo
//
//  Created by Tu Jianfeng on 8/7/11.
//  Copyright 2011 Invidel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import "ClickImageView.h"
#import "UINavigationBarCategory.h"
#import "UIViewControllerCategory.h"

@interface FeedbackViewController : UIViewController<MFMailComposeViewControllerDelegate> {
    MFMailComposeViewController *mPicker;
}

- (void)showPicker;
- (void)dismissPicker;
- (void)back;

@end
