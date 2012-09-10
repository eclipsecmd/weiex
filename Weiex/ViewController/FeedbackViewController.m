//
//  FeedbackController.m
//  WeiTansuo
//
//  Created by Tu Jianfeng on 8/7/11.
//  Copyright 2011 Invidel. All rights reserved.
//

#import "FeedbackViewController.h"


@implementation FeedbackViewController

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)dealloc
{
    [mPicker release];
    [super dealloc];
}

#pragma mark -
#pragma mark - 视图

- (void)viewDidLoad
{
    [super viewDidLoad]; 
    
    [self setBackBarItem:@selector(back)];
    
    if (mPicker == nil) {
        mPicker = [[MFMailComposeViewController alloc] init];
        [mPicker.navigationBar setBarStyle:UIBarStyleBlack];
        mPicker.mailComposeDelegate = self;
        [mPicker setSubject:@"weiex反馈"];
        NSArray *toRecipients = [NSArray arrayWithObject:@"hello@cjnov.com"];
        [mPicker setToRecipients:toRecipients];
        NSString *emailBody = nil;
        [mPicker setMessageBody:emailBody isHTML:NO];	
    }
    
    [self showPicker];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    mPicker = nil;
    [mPicker release];
    
}


#pragma mark -
#pragma mark - 事件

- (void)showPicker
{   
	[self presentModalViewController:mPicker animated:YES]; 
}
- (void)dismissPicker
{
    [mPicker dismissModalViewControllerAnimated:YES];
}
/**回退**/
- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error 
{
	switch (result)
	{
		case MFMailComposeResultCancelled:
            [self dismissPicker];
			[self back];
			break;
		case MFMailComposeResultSaved:
            [self dismissPicker];
			[self back];
			break;
		case MFMailComposeResultSent:
            [self dismissPicker];
			[self back];
			break;
		case MFMailComposeResultFailed:
            [self dismissPicker];
			//mMsg.text = @"发送失败";
            [self back];
			break;
		default:
            [self dismissPicker];
			[self back];
			break;
	}
}
/**回退**/
-(void) back
{
    [self.navigationController popViewControllerAnimated:NO];
}

@end
