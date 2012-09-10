//
//  UINavigationBarCategory.h
//  WeiTansuo
//
//  Created by Sai Li on 9/2/11.
//  Copyright 2011 Invidel. All rights reserved.
//

#import <Foundation/Foundation.h>

UIImageView *backgroundView;

@interface UINavigationBar (UINavigationBarCategory)
-(void)setBackgroundImage: (UIImage *)image;
-(void)insertSubview:(UIView *)view atIndex:(NSInteger)index;
@end
