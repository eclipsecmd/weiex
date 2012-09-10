//
//  myCheckBox.h
//  WeiTansuo
//
//  Created by Sai Li on 9/3/11.
//  Copyright 2011 Invidel. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface myCheckBox : UIView {
    UIButton *mButton;
    BOOL mCheckedSelected;
    UILabel *mRightTitle;
}

@property (nonatomic, assign) BOOL checkSelected;


-(void)setRightContent:(NSString *)rightContent;
-(void)ischeck:(id)sender;
-(id)initWithFrame:(CGRect)frame rightTitle:(NSString *)rightTitle;
- (void)justfiyFrame:(CGRect )frame;

@end
