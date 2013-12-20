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
  NSInteger numTracksForProperty = [_tracksController propertyAtIndexTrackCount:row];
  if (numTracksForProperty < GROUP_ROW_HEIGHT) {
    numTracksForProperty = GROUP_ROW_HEIGHT;
  }
  CGFloat rowHeight = numTracksForProperty*[_itemTableView rectOfRow:0].size.height;
  return rowHeight - [_itemTableView intercellSpacing].height;
}

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
  // Let's make sure it's the group column, otherwise return nil
  if ([[tableColumn identifier] isEqualToString:@"GroupColumn"]) {
    QBTableCellView *cellView = [tableView makeViewWithIdentifier:@"GroupCell" owner:self];
    NSDictionary *group = [_tracksController groupAtIndex:row];
    [cellView.imageView setImage:group[@"image"]];
    [cellView.textField setStringValue:group[@"artist"]];
    [cellView.albumField setStringValue:group[@"album"]];
    return cellView;
  }
  return nil;
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

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
  if (tableView == _groupTableView) {
    return [_tracksController groupAtIndex:row];
  } else {
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
        return [track valueForKey:[tableColumn identifier]];
      }
      if (groupItemsCount < GROUP_ROW_HEIGHT) {
        totalRowsCount += GROUP_ROW_HEIGHT - groupItemsCount;
        dummyRowsCount += GROUP_ROW_HEIGHT - groupItemsCount;
      }
      // If, after we add the dummy rows to the total count, we're over the row count, we're on a dummy row
      if (totalRowsCount > row) {
        return @"";
      }
    }
  }
  // We shouldn't reach here
  return @"";
}

#pragma mark - QBTableViewDataSource

- (void)activateSelectedRow:(NSTableView *)tableView
{
  [self activateAtIndex:[tableView selectedRow]];
}

@end
