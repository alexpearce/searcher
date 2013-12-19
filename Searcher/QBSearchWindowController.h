//
//  QBSearchWindowController.h
//  Searcher
//
//  Created by Alex Pearce on 04/12/2013.
//  Copyright (c) 2013 Alex Pearce. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "QBTableView.h"

@class QBTracksController;
@class QBSyncScrollView;

/**
 * Controller for the main search window, with a search field and results table.
 * Also the data source for the results table.
 * It is the delegate for the group table view, but not for the track table view.
 * If this class is also the track table view delegate, because we implement tableView:viewForTableColumn:row: it would become a view-based table, but it is cell-based.
 */
@interface QBSearchWindowController : NSWindowController <QBTableViewDataSource, NSTableViewDelegate>

@property (weak) IBOutlet NSSearchField *searchField;
@property (weak) IBOutlet QBSyncScrollView *groupScrollView;
@property (weak) IBOutlet QBSyncScrollView *itemScrollView;
@property (weak) IBOutlet NSTableView *groupTableView;
@property (weak) IBOutlet QBTableView *itemTableView;

@property (strong) QBTracksController *tracksController;

/**
 * Focus the window in front of any other open apps, moving to its space if required.
 */
- (void)focus;

/**
 * Play the track at the indexed row, close the window, clear the table and search field,
 * restore focus to the search field.
 *
 * @param index Index of the row to be activated
 */
- (void)activateAtIndex:(NSUInteger)index;

/**
 * Fill the table with tracks matching the search string, if any.
 */
- (IBAction)submitSearch:(id)sender;

@end
