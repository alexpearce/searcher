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
  } else if (keyCode == 126 && selectedRow == 0) {
    // If we're on the first row and it's an up arrow key, cycle to the next first responder
    [[self window] selectNextKeyView:self];
  } else {
    [super keyDown:theEvent];
  }
}

@end
