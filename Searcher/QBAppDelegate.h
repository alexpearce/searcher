//
//  QBAppDelegate.h
//  Searcher
//
//  Created by Alex Pearce on 03/12/2013.
//  Copyright (c) 2013 Alex Pearce. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Carbon/Carbon.h>

@class QBSearchViewController;

@interface QBAppDelegate : NSObject <NSApplicationDelegate>

@property (weak) IBOutlet NSWindow *window;

@property (strong) QBSearchViewController *viewController;

/**
 * Focus the window in front of any other open apps, moving to its space if required.
 */
- (void)focus;

@end
