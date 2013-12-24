//
//  QBTableRowView.m
//  Searcher
//
//  Created by Alex Pearce on 23/12/2013.
//  Copyright (c) 2013 Alex Pearce. All rights reserved.
//

#import "QBTableRowView.h"

@interface QBTableRowView () {
  // Private vars for storing start/stop gradient colours for row highlighting
  NSColor *_startingColor;
  NSColor *_endingColor;
}

@end

@implementation QBTableRowView

- (instancetype) init
{
  if (self = [super init]) {
    _startingColor = [NSColor colorWithCalibratedRed:(56/255.) green:(93/255.) blue:(244/255.) alpha:1];
    _endingColor = [NSColor colorWithCalibratedRed:(6/255.) green:(48/255.) blue:(241/255.) alpha:1];
  }
  return self;
}

- (void)drawSelectionInRect:(NSRect)dirtyRect
{
  if (self.selectionHighlightStyle != NSTableViewSelectionHighlightStyleNone) {
    NSGradient *gradient = [[NSGradient alloc] initWithStartingColor:_startingColor endingColor:_endingColor];
    // 90 degree gradient, startingColor to endingColor from top to bottom
    [gradient drawInRect:dirtyRect angle:90];
  }
}

@end
