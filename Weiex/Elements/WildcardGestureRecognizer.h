//
//  WildcardGestureRecognizer.h
//  WeiTansuo
//
//  Created by CMD on 11/25/11.
//  Copyright (c) 2011 Invidel. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^TouchesEventBlock)(NSSet * touches, UIEvent * event);

@interface WildcardGestureRecognizer : UIGestureRecognizer {
    TouchesEventBlock touchesBeganCallback;
}
@property(copy) TouchesEventBlock touchesBeganCallback;

@end
