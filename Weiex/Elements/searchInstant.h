//
//  searchInstant.h
//  WeiTansuo
//
//  Created by CMD on 11/30/11.
//  Copyright (c) 2011 Invidel. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol PassValueDelegate;

@interface searchInstant : UITableViewController {
    NSString		*_searchText;
	NSString		*_selectedText;
	NSMutableArray	*_resultList;
	id <PassValueDelegate>	_delegate;
}

@property (nonatomic, copy)NSString		*_searchText;
@property (nonatomic, copy)NSString		*_selectedText;
@property (nonatomic, retain)NSMutableArray	*_resultList;
@property (assign) id <PassValueDelegate> _delegate;

- (void)updateData;

@end
