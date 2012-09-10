//
//  ClickImageView.h
//  WeiTansuo
//
//  Created by chenyan on 9/5/11.
//  Copyright 2011 Invidel. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ClickImageView : UIImageView {
    UITapGestureRecognizer * mSingleTap;
}

@property (nonatomic,assign) id responseTarget;
@property (nonatomic,assign) SEL responseAction;
@property (nonatomic,retain) UITapGestureRecognizer * singleTap;

- (id)initWithImage:(UIImage *)image frame:(CGRect)frame target:(id)target action:(SEL)action;
- (id)initWithImage:(UIImage *)image frame:(CGRect)frame;
- (id)initWithFrame:(CGRect)frame;
- (void)addTarget:(id)target action:(SEL)aciton;
@end
