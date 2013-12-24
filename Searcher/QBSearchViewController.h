//
//  QBSearchViewController.h
//  Searcher
//
//  Created by Alex Pearce on 23/12/2013.
//  Copyright (c) 2013 Alex Pearce. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "QBTableView.h"

@class QBTracksController;
@class QBSyncScrollView;

/**
 * Controller for the main search view, with a search field and results table.
 * It is the data source and delegate for both group and item view-based tables.
 */
@interface QBSearchViewController : NSViewController <NSTextFieldDelegate, QBTableViewDataSource, NSTableViewDelegate>

@property (weak) IBOutlet NSSearchField *searchField;
@property (weak) IBOutlet NSProgressIndicator *progressIndicator;
@property (weak) IBOutlet QBSyncScrollView *groupScrollView;
@property (weak) IBOutlet QBSyncScrollView *itemScrollView;
@property (weak) IBOutlet NSTableView *groupTableView;
@property (weak) IBOutlet QBTableView *itemTableView;

@property (strong) QBTracksController *tracksController;

/**
 * Return the index of the item in the tracks controller for the row in the table.
 */
- (NSUInteger)itemIndexForRow:(NSUInteger)row;

/**
 * Play the track at the indexed row, close the window, clear the table and search field,
 * restore focus to the search field.
 *
 * @param index Index of the row to be activated
 */
- (void)activateAtRow:(NSUInteger)row;

/**
 * Is the row at index row in tableView a dummy row?
 */
- (BOOL)rowInTableView:(NSTableView *) tableView IsDummy:(NSUInteger)row;

/**
 * Fill the table with tracks matching the search string, if any.
 */
- (IBAction)submitSearch:(id)sender;

@end
