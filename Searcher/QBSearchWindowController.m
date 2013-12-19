//
//  QBSearchWindowController.m
//  Searcher
//
//  Created by Alex Pearce on 04/12/2013.
//  Copyright (c) 2013 Alex Pearce. All rights reserved.
//

#import "QBSearchWindowController.h"
#import "QBSyncScrollView.h"
#import "QBTracksController.h"
#import "QBTrack.h"
#import "iTunes.h"

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
  CGFloat rowHeight = numTracksForProperty*[_itemTableView rectOfRow:0].size.height;
  return rowHeight - [_itemTableView intercellSpacing].height;
}

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
  // Let's make sure it's the group column, otherwise return nil
  if ([[tableColumn identifier] isEqualToString:@"GroupColumn"]) {
    NSTableCellView *cellView = [tableView makeViewWithIdentifier:@"GroupCell" owner:self];
    NSDictionary *group = [_tracksController groupAtIndex:row];
    [cellView.imageView setImage:group[@"image"]];
    [cellView.textField setStringValue:group[@"artist"]];
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
    return [_tracksController trackCount];
  }
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
  if (tableView == _groupTableView) {
    return [_tracksController groupAtIndex:row];
  } else {
    QBTrack *track = [_tracksController trackAtIndex:row];
    return [track valueForKey:[tableColumn identifier]];
  }
}

#pragma mark - QBTableViewDataSource

- (void)activateSelectedRow:(NSTableView *)tableView
{
  [self activateAtIndex:[tableView selectedRow]];
}

@end
