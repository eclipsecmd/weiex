//
//  UINavigationBarCategory.m
//  WeiTansuo
//
//  Created by Sai Li on 9/2/11.
//  Copyright 2011 Invidel. All rights reserved.
//

#import "UINavigationBarCategory.h"


@implementation UINavigationBar (UINavigationBarCategory)

-(void)setBackgroundImage:(UIImage *)image
{
    if (image == nil) {
        [backgroundView removeFromSuperview];
    }
    else {
        backgroundView = [[UIImageView alloc] initWithImage:image];
        backgroundView.frame = CGRectMake(0.f, 0.f, self.frame.size.width, self.frame.size.height);
        backgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self addSubview:backgroundView];
        [self sendSubviewToBack:backgroundView];
        [backgroundView release];
    }
}


//for other views  
- (void)insertSubview:(UIView *)view atIndex:(NSInteger)index  
{  
    [super insertSubview:view atIndex:index];  
    [self sendSubviewToBack:backgroundView];  
}  


@end
