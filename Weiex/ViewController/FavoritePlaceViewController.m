//
//  FavoritePlaceViewController.m
//  WeiTansuo
//
//  Created by CMD on 12/6/11.
//  Copyright (c) 2011 Invidel. All rights reserved.
//

#import "FavoritePlaceViewController.h"

@implementation FavoritePlaceViewController

@synthesize finishAction, finishTarget;

- (id)init
{
    self = [super init];
    if (self) {
        mFavPlaceDao = [[FavPlaceDao alloc] init];
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)dealloc
{
    [mTableView release];
	[mSearchBar release];	
	[listContent release];
	[filteredListContent release];
	[savedContent release];
	[mFavPlaceDao release];
	[super dealloc];
}

#pragma mark - 
#pragma mark - View lifecycle

/*
 // Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
 - (void)viewDidLoad
 {
 [super viewDidLoad];
 }
 */

/*
 - (void)viewDidUnload
 {
 [super viewDidUnload];
 // Release any retained subviews of the main view.
 // e.g. self.myOutlet = nil;
 }
 */

- (void)viewDidLoad
{
    [super viewDidLoad];

    // create the master list
    
    [mFavPlaceDao initCoreData];    
    listContent = [mFavPlaceDao fetchObjects];
    // create our filtered list that will be the data source of our table, start its content from the master "listContent"
    filteredListContent = [[NSMutableArray alloc] initWithCapacity: [listContent count]];
    [filteredListContent addObjectsFromArray: listContent];
    
    // this stored the current list in case the user cancels the filtering
    savedContent = [[NSMutableArray alloc] initWithCapacity: [listContent count]]; 
    
    //搜索条
    mSearchBar = [[UISearchBar alloc] init];
    [mSearchBar setFrame:CGRectMake(0, 0, 320, 40)];
    mSearchBar.barStyle = UIBarStyleBlackOpaque;
    mSearchBar.delegate = self;
    mSearchBar.autocorrectionType = UITextAutocorrectionTypeNo;
    mSearchBar.autocapitalizationType = UITextAutocapitalizationTypeNone;
    mSearchBar.showsCancelButton = NO;
    [self.view addSubview:mSearchBar];
    
    //列表
    mTableView = [[UITableView alloc] init];
    [mTableView setFrame:CGRectMake(0, 44, 320, 440)];
    [mTableView setDelegate:self];
    [mTableView setDataSource:self];
    [self.view addSubview:mTableView];
}


#pragma mark - UIViewController

- (void)viewWillAppear:(BOOL)animated
{
	NSIndexPath *tableSelection = [mTableView indexPathForSelectedRow];
	[mTableView deselectRowAtIndexPath:tableSelection animated:NO]; 
}


#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return [filteredListContent count];
}

- (UITableViewCellAccessoryType)tableView:(UITableView *)tableView accessoryTypeForRowWithIndexPath:(NSIndexPath *)indexPath
{
	return UITableViewCellAccessoryNone;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellID"];
	if (cell == nil)
	{
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cellID"];
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
	}
	
    FavPlace *favplace = (FavPlace *)[filteredListContent objectAtIndex:indexPath.row];
    cell.textLabel.text = favplace.placename;
	
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];           
    if (indexPath.row < [listContent count]) {
        FavPlace *favplace = (FavPlace *)[filteredListContent objectAtIndex:indexPath.row];
        WLocation * wLocation = [[WLocation alloc] init];
        wLocation.latitude = [favplace.latitude floatValue];
        wLocation.longitude = [favplace.longtitude floatValue];
        wLocation.title = favplace.placename;
        wLocation.subtitle = favplace.placename;
        wLocation.streetAddress = @"";
        wLocation.city = @"";
        wLocation.region =@"";
        wLocation.country = @"";
        if ([finishTarget retainCount] > 0 && [finishTarget respondsToSelector:finishAction]) {
            [finishTarget performSelector:finishAction withObject:wLocation];
        }       
        [self dismissModalViewControllerAnimated:YES];
    }
}

#pragma mark UISearchBarDelegate

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
	// only show the status bar's cancel button while in edit mode
	mSearchBar.showsCancelButton = YES;
	
	// flush and save the current list content in case the user cancels the search later
	[savedContent removeAllObjects];
	[savedContent addObjectsFromArray: filteredListContent];
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar
{
	mSearchBar.showsCancelButton = NO;
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
	[filteredListContent removeAllObjects];	// clear the filtered array first
	
	// search the table content for cell titles that match "searchText"
	// if found add to the mutable array and force the table to reload
	FavPlace *cellTitle;
	for (cellTitle in listContent)
	{
		NSComparisonResult result = [cellTitle.placename compare:searchText options:NSCaseInsensitiveSearch
                                                 range:NSMakeRange(0, [searchText length])];
		if (result == NSOrderedSame)
		{
			[filteredListContent addObject:cellTitle];
		}
	}
	
	[mTableView reloadData];
}

// called when cancel button pressed
- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
	// if a valid search was entered but the user wanted to cancel, bring back the saved list content
	if (searchBar.text.length > 0)
	{
		[filteredListContent removeAllObjects];
		[filteredListContent addObjectsFromArray: savedContent];
	}
	
	[mTableView reloadData];
	
	[searchBar resignFirstResponder];
	searchBar.text = @"";
}

// called when Search (in our case "Done") button pressed
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
	[searchBar resignFirstResponder];
}

@end
