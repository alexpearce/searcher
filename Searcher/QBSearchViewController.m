//
//  QBSearchViewController.m
//  Searcher
//
//  Created by Alex Pearce on 23/12/2013.
//  Copyright (c) 2013 Alex Pearce. All rights reserved.
//

#import "QBSearchViewController.h"
#import "QBSyncScrollView.h"
#import "QBTableRowView.h"
#import "QBTableCellView.h"
#import "QBiTunesController.h"
#import "QBTrackGroup.h"
#import "QBTrack.h"

// Minimum number of item rows each group row should occupy
static NSUInteger kGroupRowHeight = 5;
// Spacing, in item rows, between adjacent groups that are equal to or greater than kGroupRowHeight high
static NSUInteger kGroupRowSpacing = 1;
// Height of item row
static CGFloat kItemRowHeight = 17.;
// Vertical padding of item row
static CGFloat kItemRowPadding = 2.;

// Private properties and methods.
@interface QBSearchViewController ()
/**
 * Row indicies containing dummy rows.
 */
@property (strong) NSIndexSet *dummyRows;
/**
 * Row indicies containing "true" items.
 */
@property (strong) NSIndexSet *itemRows;

/**
 * Fills dummyRows and itemRows with their respective indices.
 */
- (void)populateIndexSets;
@end

@implementation QBSearchViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
  self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
  if (self) {
    // Initialise the source controllers and set the default to iTunes
    self.sourceControllers = @[@{
                                 @"name": @"iTunes",
                                 @"controller": [[QBiTunesController alloc] init]
                               }
                               ];
    self.selectedSource = [self.sourceControllers firstObject][@"controller"];
  }
  return self;
}

- (void)awakeFromNib
{
  [super awakeFromNib];
  
  self.itemTableView.target = self;
  self.itemTableView.doubleAction = @selector(activateSelectedRow:);
  
  [self.groupScrollView setSynchronisedScrollView:self.itemScrollView];
  [self.itemScrollView setSynchronisedScrollView:self.groupScrollView];
}

- (NSUInteger)itemIndexForRow:(NSUInteger)row
{
  __block NSUInteger itemIndex = 0;
  [self.itemRows enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
    if (idx == row) {
      *stop = YES;
    } else {
      itemIndex += 1;
    }
  }];
  return itemIndex;
}

- (void)activateAtRow:(NSUInteger)row
{
  [self.selectedSource playTrackAtTrackIndex:[self itemIndexForRow:row]];
  
  [self.view.window close];
  // Searching with an empty string clears the selected controller and reloads the table
  self.searchField.stringValue = @"";
  [self submitSearch:self.searchField];
}

- (BOOL)rowInTableView:(NSTableView *) tableView IsDummy:(NSUInteger)row
{
  if (tableView == self.itemTableView) {
    return [self.dummyRows containsIndex:row];
  }
  return YES;
}

- (void) populateIndexSets
{
  NSMutableIndexSet *tempDummyRows = [[NSMutableIndexSet alloc] init];
  NSMutableIndexSet *tempItemRows = [[NSMutableIndexSet alloc] init];
  NSUInteger rowCount = 0;
  NSUInteger groupItemsCount;
  NSUInteger dummyRowCount;
  for (QBTrackGroup *group in [self.selectedSource groupsArray]) {
    groupItemsCount = group.trackCount;
    [tempItemRows addIndexesInRange:NSMakeRange(rowCount, groupItemsCount)];
    rowCount += groupItemsCount;
    // Pad out groups with too few rows (smaller than the minimum group height),
    // or add a blank end row to groups big enough
    if (groupItemsCount < kGroupRowHeight) {
      dummyRowCount = kGroupRowHeight - groupItemsCount;
      [tempDummyRows addIndexesInRange:NSMakeRange(rowCount, dummyRowCount)];
      rowCount += dummyRowCount;
    } else {
      [tempDummyRows addIndexesInRange:NSMakeRange(rowCount, kGroupRowSpacing)];
      rowCount += kGroupRowSpacing;
    }
  }
  self.dummyRows = [[NSIndexSet alloc] initWithIndexSet:tempDummyRows];
  self.itemRows = [[NSIndexSet alloc] initWithIndexSet:tempItemRows];
}

#pragma mark - IBAction

- (IBAction)submitSearch:(id)sender
{
  // Start the spinner, perform the search, reload the data, stop the spinner, scroll to top
  [self.progressIndicator startAnimation:nil];
  [self.selectedSource searchWithString:[sender stringValue]];
  [self populateIndexSets];
  [self.groupTableView reloadData];
  [self.itemTableView reloadData];
  [self.progressIndicator stopAnimation:nil];
  [[self.itemScrollView contentView] scrollToPoint:NSZeroPoint];
}

#pragma mark - NSTextFieldDelegate

- (BOOL)control:(NSControl *)control textView:(NSTextView *)textView doCommandBySelector:(SEL)commandSelector
{
  if (commandSelector == @selector(moveDown:)) {
    // For some reason NSWindow's selectNextKeyView: fails to change the first responder here
    [self.view.window selectKeyViewFollowingView:control];
    return YES;
  } else if (commandSelector == @selector(insertNewline:)) {
    // On return, activate the first row
    [self activateAtRow:0];
    return YES;
  }
  return NO;
}

#pragma mark - NSTableViewDelegate

- (CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row
{
  // Group cells are an integer number of item cells high, which are kItemRowHeight high.
  // If the group contains fewer items than kGroupRowHeight, the group cell is kGroupRowHeight item cells high.
  // If the group contains some higher number of items, the group cell is that number of item cells high.
  if (tableView == self.groupTableView) {
    NSInteger numTracksForProperty = [self.selectedSource groupAtGroupIndex:row].trackCount;
    if (numTracksForProperty < kGroupRowHeight) {
      numTracksForProperty = kGroupRowHeight;
    } else {
      numTracksForProperty += kGroupRowSpacing;
    }
    return numTracksForProperty*(kItemRowHeight + kItemRowPadding);
  } else {
    return kItemRowHeight;
  }
}

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
  // We need to return the appropriate view for the column, filled with data.
  // If it's for the group column, fetch the group and fill the group cell.
  // If it's for the item column and the row is a dummy row, return nil as no view is needed.
  // If it's for the item column and the row is an item, fetch the item and fill the item cell.
  NSString *columnIdentifier = tableColumn.identifier;
  
  if ([columnIdentifier isEqualToString:@"group"]) {
    QBTableCellView *cellView = [tableView makeViewWithIdentifier:columnIdentifier owner:self];
    QBTrackGroup *group = [self.selectedSource groupAtGroupIndex:row];
    cellView.imageView.image = group.artwork;
    cellView.textField.stringValue = group.artist;
    cellView.albumField.stringValue = group.album;
    return cellView;
  } else if ([columnIdentifier isEqualToString:@"title"]) {
    if ([self rowInTableView:tableView IsDummy:row]) {
      return nil;
    }
    NSTableCellView *cellView = [tableView makeViewWithIdentifier:columnIdentifier owner:self];
    QBTrack *track = [self.selectedSource trackAtTrackIndex:[self itemIndexForRow:row]];
    cellView.textField.stringValue = [track valueForKey:[tableColumn identifier]];
    return cellView;
  }
  return nil;
}

- (NSTableRowView *)tableView:(NSTableView *)tableView rowViewForRow:(NSInteger)row
{
  // Returning a custom row view allows us to change its features, like highlight colour
  return [[QBTableRowView alloc] init];
}

- (BOOL)tableView:(NSTableView *)tableView shouldSelectRow:(NSInteger)row
{
  // We can select a cell if it's not a dummy row.
  return ![self rowInTableView:tableView IsDummy:row];
}

#pragma mark - NSTableViewDataSource

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
  if (tableView == self.groupTableView) {
    return [self.selectedSource groupCount];
  } else {
    return [self.dummyRows count] + [self.itemRows count];
  }
}

#pragma mark - QBTableViewDelegate

- (void)activateSelectedRow:(NSTableView *)tableView
{
  [self activateAtRow:[tableView selectedRow]];
}

@end
