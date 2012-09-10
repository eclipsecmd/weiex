/*
     File: MyViewController.m 
 Abstract: The root view controller for the iPhone design of this app. 
  Version: 1.4 
  
 Disclaimer: IMPORTANT:  This Apple software is supplied to you by Apple 
 Inc. ("Apple") in consideration of your agreement to the following 
 terms, and your use, installation, modification or redistribution of 
 this Apple software constitutes acceptance of these terms.  If you do 
 not agree with these terms, please do not use, install, modify or 
 redistribute this Apple software. 
  
 In consideration of your agreement to abide by the following terms, and 
 subject to these terms, Apple grants you a personal, non-exclusive 
 license, under Apple's copyrights in this original Apple software (the 
 "Apple Software"), to use, reproduce, modify and redistribute the Apple 
 Software, with or without modifications, in source and/or binary forms; 
 provided that if you redistribute the Apple Software in its entirety and 
 without modifications, you must retain this notice and the following 
 text and disclaimers in all such redistributions of the Apple Software. 
 Neither the name, trademarks, service marks or logos of Apple Inc. may 
 be used to endorse or promote products derived from the Apple Software 
 without specific prior written permission from Apple.  Except as 
 expressly stated in this notice, no other rights or licenses, express or 
 implied, are granted by Apple herein, including but not limited to any 
 patent rights that may be infringed by your derivative works or by other 
 works in which the Apple Software may be incorporated. 
  
 The Apple Software is provided by Apple on an "AS IS" basis.  APPLE 
 MAKES NO WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION 
 THE IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS 
 FOR A PARTICULAR PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND 
 OPERATION ALONE OR IN COMBINATION WITH YOUR PRODUCTS. 
  
 IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL 
 OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF 
 SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS 
 INTERRUPTION) ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION, 
 MODIFICATION AND/OR DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED 
 AND WHETHER UNDER THEORY OF CONTRACT, TORT (INCLUDING NEGLIGENCE), 
 STRICT LIABILITY OR OTHERWISE, EVEN IF APPLE HAS BEEN ADVISED OF THE 
 POSSIBILITY OF SUCH DAMAGE. 
  
 Copyright (C) 2010 Apple Inc. All Rights Reserved. 
  
 */

#import "MyViewController.h"
//#import "UILabel+Extensions.h"


@implementation MyViewController

@synthesize numberImage;
//@synthesize numberTitle;
//@synthesize numberContent, numberDescript;
//@synthesize numberScrollView;

// load the view nib and initialize the pageNumber ivar
- (id)initWithPageNumber:(int)page
{
    self = [super init];
    if (self)
    {
        pageNumber = page;
    }
    return self;
}

- (void)dealloc
{
//    [numberTitle release];
    [numberImage release];
//    [numberContent release];
//    [numberDescript release];
    [super dealloc];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
//    numberTitle = nil;
    numberImage = nil;
//    numberContent = nil;
//    numberDescript = nil;
}

// set the label and background color when the view has finished loading
- (void)viewDidLoad
{
    [super viewDidLoad];
    
//    [self.view setBackgroundColor:[UIColor colorWithRed:255/255.f green:253/255.f blue:222/255.f alpha:1]];
    
    
    
//    numberScrollView = [[UIScrollView alloc] init];
//    CGRect viewRect = self.view.frame;
//    viewRect.origin.y -= 20;
//    numberScrollView.frame = viewRect;
//    [self.view addSubview:numberScrollView];
//    
//    numberTitle = [[UILabel alloc] init];
//    numberTitle.backgroundColor = [UIColor clearColor];
//    numberTitle.font = [UIFont fontWithName:@"Bold" size:17];
//    [numberTitle setTextColor:[UIColor colorWithRed:97/255.f green:55/255.f blue:32/255.f alpha:1]];
//    [numberScrollView addSubview:numberTitle];
//    
//    numberDescript = [[UILabel alloc] init];
//    numberDescript.font = [UIFont fontWithName:@"Arial" size:13];
//    numberDescript.backgroundColor = [UIColor clearColor];
//    [numberDescript setTextColor:[UIColor colorWithRed:97/255.f green:55/255.f blue:32/255.f alpha:1]];
//    [numberScrollView addSubview:numberDescript];
    
    numberImage = [[UIImageView alloc] init];
    [numberImage setFrame:CGRectMake(0, 0, 320, 480)];
    [self.view addSubview:numberImage];
//    [numberScrollView addSubview:numberImage];
//    
//    numberContent = [[UILabel alloc] init];
//    numberContent.backgroundColor = [UIColor clearColor];
//    numberContent.font = [UIFont fontWithName:@"Arial" size:13];
//    [numberContent setTextColor:[UIColor colorWithRed:97/255.f green:55/255.f blue:32/255.f alpha:1]];
//    [numberScrollView addSubview:numberContent];
    
}

//- (void)ReLayOut
//{
//    [numberTitle sizeToFitFixedWidth:310];
//    [numberDescript sizeToFitFixedWidth:310];
//    [numberContent sizeToFitFixedWidth:310];
//    numberTitle.frame = CGRectMake(5, 5, 310, numberTitle.frame.size.height);
//    numberDescript.frame = CGRectMake(5, numberTitle.frame.origin.y + numberTitle.frame.size.height + 5, 310, numberDescript.frame.size.height);
//    numberImage.frame = CGRectMake(5, numberDescript.frame.size.height + numberDescript.frame.origin.y + 5, 310, 479);
//    numberContent.frame = CGRectMake(5, numberImage.frame.size.height + numberImage.frame.origin.y + 5, 310, numberContent.frame.size.height);
//    
//    CGFloat totalHeight = numberTitle.frame.size.height + numberContent.frame.size.height + numberDescript.frame.size.height + numberImage.frame.size.height + 15 + 60;
//    numberScrollView.contentSize = CGSizeMake(320, totalHeight);
//    
//    
//}


/*
- (void)loadView
{
    [super loadView];
    //[self.navigationController.navigationBar setBarStyle:UIBarStyleBlackTranslucent];
}
 */



@end
