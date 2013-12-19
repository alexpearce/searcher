//
//  QBAppDelegate.h
//  Searcher
//
//  Created by Alex Pearce on 03/12/2013.
//  Copyright (c) 2013 Alex Pearce. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Carbon/Carbon.h>

@class QBSearchWindowController;

@interface QBAppDelegate : NSObject <NSApplicationDelegate>

@property (strong) QBSearchWindowController *windowController;

@end
