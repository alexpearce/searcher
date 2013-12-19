//
//  QBTableView.m
//  Searcher
//
//  Created by Alex Pearce on 03/12/2013.
//  Copyright (c) 2013 Alex Pearce. All rights reserved.
//

#import "QBTableView.h"

@implementation QBTableView

/*
 * Override the keyDown method to send the activateSelectedRow message if a row is selected and the return key is pressed.
 * If some other key is pressed, or if a row is not selected, the super's keyDown is called.
 */
- (void)keyDown:(NSEvent *)theEvent
{
  unsigned short keyCode = [theEvent keyCode];
  NSInteger selectedRow = [self selectedRow];
  if (keyCode == 36 && selectedRow > -1) {
    // Return, play the track the row corresponds to (if a row is selected)
    if ([[self dataSource] respondsToSelector:@selector(activateSelectedRow:)]) {
      [(id<QBTableViewDataSource>)[self dataSource] activateSelectedRow:self];
    }
  } else {
    [super keyDown:theEvent];
  }
}

@end
