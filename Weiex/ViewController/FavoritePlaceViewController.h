//
//  FavoritePlaceViewController.h
//  WeiTansuo
//
//  Created by CMD on 12/6/11.
//  Copyright (c) 2011 Invidel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FavPlaceDao.h"
#import "WLocation.h"

@interface FavoritePlaceViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate>
{
    UITableView		*mTableView;
    UISearchBar		*mSearchBar;
	
	NSArray			*mlistContent;			// the master content
	NSMutableArray	*mfilteredListContent;	// the filtered content as a result of the search
	NSMutableArray	*msavedContent;			// the saved content in case the user cancels a search
    FavPlaceDao     *mFavPlaceDao;

    NSArray *listContent;
    NSMutableArray *filteredListContent;
    NSMutableArray *savedContent;
}

@property (nonatomic, assign) id finishTarget;
@property (nonatomic, assign) SEL finishAction;

@end
