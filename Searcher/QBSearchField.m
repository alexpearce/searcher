//
//  QBSearchField.m
//  Searcher
//
//  Created by Alex Pearce on 21/12/2013.
//  Copyright (c) 2013 Alex Pearce. All rights reserved.
//

#import "QBSearchField.h"

@implementation QBSearchField

- (void)keyUp:(NSEvent *)theEvent
{
  unsigned short keyCode = [theEvent keyCode];
  // Down arrow
  if (keyCode == 125) {
    // For some reason NSWindow's selectNextKeyView: doesn't change the first responder
    [[self window] makeFirstResponder:[self nextValidKeyView]];
  } else {
    [super keyUp:theEvent];
  }
}

@end
