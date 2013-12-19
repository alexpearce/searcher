//
//  QBAppDelegate.m
//  Searcher
//
//  Created by Alex Pearce on 03/12/2013.
//  Copyright (c) 2013 Alex Pearce. All rights reserved.
//

#import "QBAppDelegate.h"
#import "QBSearchWindowController.h"

@implementation QBAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
  _windowController = [[QBSearchWindowController alloc] initWithWindowNibName:@"QBSearchWindowController"];
  [_windowController showWindow:self];

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
  [self.windowController focus];
  return noErr;
}

#pragma mark - NSApplicationDelegate

- (BOOL)applicationShouldHandleReopen:(NSApplication *)sender hasVisibleWindows:(BOOL)flag
{
  [_windowController focus];
  return YES;
}
@end
