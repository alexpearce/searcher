//
//  QBSearchWindowController.m
//  Searcher
//
//  Created by Alex Pearce on 04/12/2013.
//  Copyright (c) 2013 Alex Pearce. All rights reserved.
//

#import "QBSearchWindowController.h"
#import "QBSyncScrollView.h"
#import "QBTableCellView.h"
#import "QBTracksController.h"
#import "QBTrack.h"

@implementation QBSearchWindowController

- (id)initWithWindow:(NSWindow *)window
{
  if (self = [super initWithWindow:window]) {
    _tracksController = [[QBTracksController alloc] init];
  }
  return self;
}

- (void)windowDidLoad
{
  [super windowDidLoad];

  [_itemTableView setTarget:self];
  [_itemTableView setDoubleAction:@selector(activateSelectedRow:)];
  
  [_groupScrollView setSynchronisedScrollView:_itemScrollView];
  [_itemScrollView setSynchronisedScrollView:_groupScrollView];
}

- (void)focus
{
  [self.window makeKeyAndOrderFront:nil];
  [NSApp activateIgnoringOtherApps:YES];
}

- (void)activateAtIndex:(NSUInteger)index
{
  QBTrack *track = [_tracksController trackAtIndex:index];
  [track play];
  [self.window close];
  [_searchField setStringValue:@""];
  // Searching with an empty string to clears the tracksController and reloads the table
  [self submitSearch:_searchField];
  [_searchField becomeFirstResponder];
}

- (BOOL)rowInTableView:(NSTableView *) tableView IsDummy:(NSUInteger)row
{
  if (tableView == _itemTableView) {
    NSUInteger groupItemsCount;
    NSUInteger totalRowsCount = 0;
    for (NSDictionary *group in [_tracksController groups]) {
      groupItemsCount = [group[@"count"] unsignedIntegerValue];
      totalRowsCount += groupItemsCount;
      if (totalRowsCount > row) {
        return NO;
      }
      if (groupItemsCount < GROUP_ROW_HEIGHT) {
        totalRowsCount += GROUP_ROW_HEIGHT - groupItemsCount;
      }
      // If, after we add the dummy rows to the total count, we're over the row count, we're on a dummy row
      if (totalRowsCount > row) {
        return YES;
      }
    }
  }
  return YES;
}

#pragma mark - IBAction

- (IBAction)submitSearch:(id)sender
{
  [_tracksController searchWithString:[sender stringValue]];
  [_groupTableView reloadData];
  [_itemTableView reloadData];
}

#pragma mark - NSTableViewDelegate

- (CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row
{
  if (tableView == _groupTableView) {
    NSInteger numTracksForProperty = [_tracksController propertyAtIndexTrackCount:row];
    if (numTracksForProperty < GROUP_ROW_HEIGHT) {
      numTracksForProperty = GROUP_ROW_HEIGHT;
    }
    return numTracksForProperty*(ITEM_ROW_HEIGHT + ITEM_ROW_PADDING);
  } else {
    return ITEM_ROW_HEIGHT;
  }
}

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
  NSString *columnIdentifier = tableColumn.identifier;
  if ([columnIdentifier isEqualToString:@"group"]) {
    QBTableCellView *cellView = [tableView makeViewWithIdentifier:columnIdentifier owner:self];
    NSDictionary *group = [_tracksController groupAtIndex:row];
    cellView.imageView.image = group[@"image"];
    cellView.textField.stringValue = group[@"artist"];
    cellView.albumField.stringValue = group[@"album"];
    return cellView;
  } else if ([columnIdentifier isEqualToString:@"title"]) {
    // No need for views in dummy cells
    if ([self rowInTableView:tableView IsDummy:row]) {
      return nil;
    }
    NSString *cellViewStringValue;
    NSUInteger groupItemsCount;
    NSUInteger dummyRowsCount = 0;
    NSUInteger totalRowsCount = 0;
    NSUInteger trackNum;
    for (NSDictionary *group in [_tracksController groups]) {
      groupItemsCount = [group[@"count"] unsignedIntegerValue];
      totalRowsCount += groupItemsCount;
      if (totalRowsCount > row) {
        trackNum = row - dummyRowsCount;
        QBTrack *track = [_tracksController trackAtIndex:trackNum];
        cellViewStringValue = [track valueForKey:[tableColumn identifier]];
        break;
      }
      if (groupItemsCount < GROUP_ROW_HEIGHT) {
        totalRowsCount += GROUP_ROW_HEIGHT - groupItemsCount;
        dummyRowsCount += GROUP_ROW_HEIGHT - groupItemsCount;
      }
    }
    NSTableCellView *cellView = [tableView makeViewWithIdentifier:columnIdentifier owner:self];
    cellView.textField.stringValue = cellViewStringValue;
    return cellView;
  }
  return nil;
}

- (BOOL)tableView:(NSTableView *)tableView shouldSelectRow:(NSInteger)row
{
  return ![self rowInTableView:tableView IsDummy:row];
}

#pragma mark - NSTableViewDataSource

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
  if (tableView == _groupTableView) {
    return [_tracksController groupCount];
  } else {
    NSUInteger sumCount = 0;
    NSUInteger groupItemCount;
    for (NSDictionary *group in [_tracksController groups]) {
      groupItemCount = [group[@"count"] unsignedIntegerValue];
      sumCount += groupItemCount;
      if (groupItemCount < GROUP_ROW_HEIGHT) {
        sumCount += GROUP_ROW_HEIGHT  - groupItemCount;
      }
    }
    return sumCount;
  }
}

#pragma mark - QBTableViewDataSource

- (void)activateSelectedRow:(NSTableView *)tableView
{
  // TODO we need to subtract dummy rows from this
  [self activateAtIndex:[tableView selectedRow]];
}

@end
