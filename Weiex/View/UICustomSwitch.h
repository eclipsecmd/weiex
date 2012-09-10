//
//  UICustomSwitch.h
//  UICatalog
//
//  Created by aish on 09-2-25.
//  Copyright 2009  .. All rights reserved.
//

#import <UIKit/UIKit.h>

// 该方法时SDK文档中没有的， 添加一个category
@interface UISwitch (extended)
- (void) setAlternateColors:(BOOL) boolean;
@end
// 自定义Slider 类
@interface _UISwitchSlider : UIView
@end


@interface UICustomSwitch : UISwitch {

}
- (void) setLeftLabelText:(NSString *)labelText
                     font:(UIFont*)labelFont
                    color: (UIColor *)labelColor;
- (void) setRightLabelText:(NSString *)labelText
                      font:(UIFont*)labelFont
                     color:(UIColor *)labelColor;
- (UILabel*) createLabelWithText:(NSString*)labelText
                            font:(UIFont*)labelFont
                           color:(UIColor*)labelColor;

@end