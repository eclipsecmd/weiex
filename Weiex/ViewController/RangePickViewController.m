//
//  RangePickViewController.m
//  WeiTansuo
//
//  Created by chenyan on 11/21/11.
//  Copyright (c) 2011 Invidel. All rights reserved.
//

#import "RangePickViewController.h"


@implementation RangePickViewController

@synthesize finishTarget,finishAction,currentRange = mCurrentRange,currentTimeline = mCurrentTimeline;


- (id)init
{
    self = [super init];
    if (self) {
        // Custom initialization
        mRangeSelectTitles = [[NSArray alloc] initWithObjects:@"500",@"1000",@"1500",@"2000",@"2500",@"3000", nil];
       
        mTimelineTitles = [[NSArray alloc] initWithObjects:@"最新" ,@"1小时", @"3小时", @"4小时", @"5小时", @"6小时", @"1天前", @"2天前", @"3天前", @"4天前", @"5天前", nil];
        
        [self.view setBackgroundColor:[UIColor clearColor]];
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle


// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
 
    if (!mCancelButtonForRangeSelectView) {
        mDoneButtonForRangeSelectView = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [mDoneButtonForRangeSelectView setFrame:CGRectMake(20, 10, 120, 30)];
        [mDoneButtonForRangeSelectView setTitle:@"取消" forState:UIControlStateNormal];

    }
    if (!mDoneButtonForRangeSelectView) {
        mDoneButtonForRangeSelectView = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [mDoneButtonForRangeSelectView setFrame:CGRectMake(180, 10, 120, 30)];
        [mDoneButtonForRangeSelectView setTitle:@"确定" forState:UIControlStateNormal];
    }
    
    if (!mRangeSelectView) {
        mRangeSelectView = [[UIPickerView alloc] init];
        [mRangeSelectView setFrame:CGRectMake(0, 50, 320, 216)];
        [mRangeSelectView setDelegate:self];
        [mRangeSelectView setBackgroundColor:[UIColor clearColor]];
        [mRangeSelectView setShowsSelectionIndicator:YES];
        [mRangeSelectView setAutoresizingMask:UIViewAutoresizingFlexibleWidth];

        [self initPickViewDataSource];
        
    }
    
    //end of anyothers element alloc
    if (!mViewForRangeSelectView) {
        mViewForRangeSelectView = [[UIView alloc] init];
        [mViewForRangeSelectView setFrame:CGRectMake(0, 170, 320, 200)];
        [mViewForRangeSelectView setBackgroundColor:[UIColor colorWithRed:100/255.f green:100/255.f blue:100/255.f alpha:0.8f]];        
        [mViewForRangeSelectView addSubview:mCancelButtonForRangeSelectView];
        [mViewForRangeSelectView addSubview:mDoneButtonForRangeSelectView];
        [mViewForRangeSelectView addSubview:mRangeSelectView];
        [self.view addSubview:mViewForRangeSelectView];
        
    }
}


- (void)initPickViewDataSource
{
    
    
    [mRangeSelectView selectRow:0 inComponent:0 animated:YES];
    [mRangeSelectView selectRow:0 inComponent:1 animated:YES];
}


/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
}
*/

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}



#pragma mark -
#pragma mark - 范围选取器
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView 
{
    return 2;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    switch (component) {
        case 0:
            return [mRangeSelectTitles count]; 
            break;
        case 1:
            return [mTimelineTitles count];
        default:
            return 0;
            break;
    }
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    switch (component) {
        case 0:
            return [mRangeSelectTitles objectAtIndex:row]; 
            break;
        case 1:
            return [mTimelineTitles objectAtIndex:row];
        default:
            return 0;
            break;
    }
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    
    switch (component) {
        case 0:
            [mRangeSelectView removeFromSuperview];
            if (row == 0) {
                return;
            }
            NSString * titlerange = [mRangeSelectTitles objectAtIndex:row];
            [self rangeSelect:[titlerange intValue]];
            break;
        case 1:
            [mRangeSelectView removeFromSuperview];
            if (row == 0) {
                return;
            }
            NSString * titletime = [mRangeSelectTitles objectAtIndex:row];
            [self rangeSelect:[titletime intValue]];
        default:
            break;
    }
}


- (void)rangeSelect:(long long)range
{
    NSLog(@"pick didselectrow just happen");
    //[DataController setKLocateSelfDistence:range];
    [self dismissModalViewControllerAnimated:YES];
    if ([finishTarget retainCount] > 0 && [finishTarget respondsToSelector:finishAction]) {
        [finishTarget performSelector:finishAction  withObject:@"range"];
    }
}


- (void)didChangeValueForKey:(NSString *)key{
    NSLog(@"!!!!%@",key);
}

@end
