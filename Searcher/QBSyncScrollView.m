//
//  QBSyncScrollView.m
//  Searcher
//
//  Created by Alex Pearce on 05/12/2013.
//  Copyright (c) 2013 Alex Pearce. All rights reserved.
//

#import "QBSyncScrollView.h"

@implementation QBSyncScrollView

- (void)setSynchronisedScrollView:(NSScrollView *)scrollView
{
  NSView *synchronisedContentView;
  
  // stop an existing scroll view synchronising
  [self stopSynchronising];
  
  // don't retain the watched view, because we assume that it will
  // be retained by the view hierarchy for as long as we're around.
  _synchronisedScrollView = scrollView;
  
  // get the content view of the
  synchronisedContentView = [_synchronisedScrollView contentView];
  
  // Make sure the watched view is sending bounds changed
  // notifications (which is probably does anyway, but calling
  // this again won't hurt).
  [synchronisedContentView setPostsBoundsChangedNotifications:YES];
  
  // a register for those notifications on the synchronised content view.
  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(synchronisedViewContentBoundsDidChange:)
                                               name:NSViewBoundsDidChangeNotification
                                             object:synchronisedContentView];
}

- (void)synchronisedViewContentBoundsDidChange:(NSNotification *)notification
{
  // get the changed content view from the notification
  NSClipView *changedContentView = [notification object];
  
  // get the origin of the NSClipView of the scroll view that
  // we're watching
  NSPoint changedBoundsOrigin = [changedContentView documentVisibleRect].origin;
  
  // get our current origin
  NSPoint curOffset = [[self contentView] bounds].origin;
  NSPoint newOffset = curOffset;
  
  // scrolling is synchronised in the vertical plane
  // so only modify the y component of the offset
  newOffset.y = changedBoundsOrigin.y;
  
  // if our synced position is different from our current
  // position, reposition our content view
  if (!NSEqualPoints(curOffset, changedBoundsOrigin)) {
    // note that a scroll view watching this one will
    // get notified here
    [[self contentView] scrollToPoint:newOffset];
    // we have to tell the NSScrollView to update its
    // scrollers
    [self reflectScrolledClipView:[self contentView]];
  }
}

- (void)stopSynchronising
{
  if (_synchronisedScrollView != nil) {
    NSView* synchronisedContentView = [_synchronisedScrollView contentView];
    
    // remove any existing notification registration
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:NSViewBoundsDidChangeNotification
                                                  object:synchronisedContentView];
    
    // set synchronisedScrollView to nil
    _synchronisedScrollView = nil;
  }
}

@end
