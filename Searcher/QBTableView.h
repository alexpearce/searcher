//
//  QBTableView.h
//  Searcher
//
//  Created by Alex Pearce on 03/12/2013.
//  Copyright (c) 2013 Alex Pearce. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface QBTableView : NSTableView

@end

@protocol QBTableViewDataSource <NSTableViewDataSource>

@optional
/**
 * Tell the datasource to "activate" the object represented by the selected row.
 * This message will only be sent if a row is actually selected.
 * It is, of course, up to the data source delegate what "activating" the object means.
 */
- (void)activateSelectedRow:(NSTableView *)tableView;

@end
