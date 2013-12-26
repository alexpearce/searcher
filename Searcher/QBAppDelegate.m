//
//  QBAppDelegate.m
//  Searcher
//
//  Created by Alex Pearce on 03/12/2013.
//  Copyright (c) 2013 Alex Pearce. All rights reserved.
//

#import "QBAppDelegate.h"
#import "QBSearchViewController.h"

@implementation QBAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
  _viewController = [[QBSearchViewController alloc] initWithNibName:@"QBSearchViewController" bundle:nil];
  _window.contentView = _viewController.view;
  // For some reason NSWindow's setInitialFirstResponder: doesn't focus the searchField on launch, so do it manually
  [_viewController.searchField becomeFirstResponder];
  
  _window.backgroundColor = [NSColor colorWithCalibratedRed:(50/255.) green:(53/255.) blue:(61/255.) alpha:1];

  // Register global hotkey
  EventHotKeyRef gMyHotKeyRef;
  EventHotKeyID gMyHotKeyID;
  EventTypeSpec gMyEventTypeSpec;
  gMyEventTypeSpec.eventClass = kEventClassKeyboard;
  gMyEventTypeSpec.eventKind = kEventHotKeyPressed;
  InstallApplicationEventHandler(&myHotKeyHandler, 1, &gMyEventTypeSpec, (void *)CFBridgingRetain(self), NULL);
  gMyHotKeyID.signature = 'htk1';
  gMyHotKeyID.id = 1;
  // cmd+shift space
  RegisterEventHotKey(49, cmdKey+shiftKey, gMyHotKeyID, GetApplicationEventTarget(), 0, &gMyHotKeyRef);
}

OSStatus myHotKeyHandler(EventHandlerCallRef nextHandler,EventRef theEvent, void *userData)
{
  QBAppDelegate *self = (__bridge QBAppDelegate *)userData;
  [self focus];
  return noErr;
}

- (void)focus
{
  [_window makeKeyAndOrderFront:nil];
  [_viewController.searchField becomeFirstResponder];
  [NSApp activateIgnoringOtherApps:YES];
}


#pragma mark - NSApplicationDelegate

- (BOOL)applicationShouldHandleReopen:(NSApplication *)sender hasVisibleWindows:(BOOL)flag
{
  [self focus];
  return YES;
}

@end
