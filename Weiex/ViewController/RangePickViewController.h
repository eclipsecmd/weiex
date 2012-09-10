//
//  RangePickViewController.h
//  WeiTansuo
//
//  Created by chenyan on 11/21/11.
//  Copyright (c) 2011 Invidel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DataController.h"

@interface RangePickViewController : UIViewController <UIPickerViewDelegate, UIPickerViewDataSource> {
    
    UIPickerView *mRangeSelectView;                     //范围选取器
    NSArray *mRangeSelectTitles;                        //范围选取器选项
    
    NSArray *mTimelineTitles;
    
    UIView *mViewForRangeSelectView; 
    UIButton *mDoneButtonForRangeSelectView;
    UIButton *mCancelButtonForRangeSelectView;
    
    long long mCurrentRange;
    long long mCurrentTimeline;
    
}

@property (nonatomic,assign) id finishTarget;
@property (nonatomic,assign) SEL finishAction;

@property (nonatomic, assign) long long currentRange;
@property (nonatomic, assign) long long currentTimeline;

- (void)rangeSelect:(long long)range;

//function as the title
- (void)initPickViewDataSource;

@end
