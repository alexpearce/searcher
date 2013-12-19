//
//  QBSyncScrollView.h
//  Searcher
//
//  Created by Alex Pearce on 05/12/2013.
//  Copyright (c) 2013 Alex Pearce. All rights reserved.
//

#import <Cocoa/Cocoa.h>

/**
 * A scroll view whose scrolling in the vertical plane can be synchronised with a sibling class.
 * @see https://developer.apple.com/library/mac/documentation/Cocoa/Conceptual/NSScrollViewGuide/Articles/SynchroScroll.html
 * @see http://stackoverflow.com/a/12364544/596068
 */
@interface QBSyncScrollView : NSScrollView

@property (weak, readonly) NSScrollView *synchronisedScrollView;

/**
 * Set the scroll view for to synchronise with.
 * Generally one will also call this on the other scroll view, too.
 * @param scrollView The scroll view to synchronise with. Not retained here, so must be somewhere.
 */
- (void)setSynchronisedScrollView:(NSScrollView*)scrollView;

/**
 * Unbined the synchronised scroll view.
 * Generally one will also call this on the other scroll view, too.
 */
- (void)stopSynchronising;

/**
 * Sent by synchronised scroll view when scrolled.
 */
- (void)synchronisedViewContentBoundsDidChange:(NSNotification *)notification;

@end
