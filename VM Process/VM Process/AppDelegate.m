/*
 *  VM Process MacOS
 *  Copyright (C) 2021 AnVirt
 *
 *  This program is free software; you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation; either version 2 of the License, or
 *  (at your option) any later version.
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public
 *  License along with this library; if not, see <http://www.gnu.org/licenses/>.
 *
 *  AppDelegate.m
 *  Created by Chen Zhen <cz.worker@gmail.com> on 2021/12/19.
 */

#import "VMWindowController.h"
#import "AppDelegate.h"
#include "vmproc.h"
#include "skin_event.h"
#include "skin_agent.h"

@interface AppDelegate ()
@property (strong) VMWindowController *vm_window_controller;
@end

@implementation AppDelegate

- (instancetype)init {
  self = [super init];
  self.vm_window_controller = [VMWindowController create];
  [self.vm_window_controller.window makeKeyAndOrderFront:self];
  return self;
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {

}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
  anv_vmproc_on_exit();
}

- (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)sender {
//  anv_skin_event_queue(anv_skin_event_new(kEventQuit));
  if (gAgentStatus == AgentStatusQuit) {
    return NSTerminateNow;
  }

  gAgentStatus = AgentStatusWaitingExit;
  [self.vm_window_controller doShutDown];
  return NSTerminateLater;
}

- (BOOL)applicationSupportsSecureRestorableState:(NSApplication *)app {
  return YES;
}

- (BOOL)applicationShouldHandleReopen:(NSApplication *)sender hasVisibleWindows:(BOOL)flag {
  [self.vm_window_controller showWindow:self];
  return TRUE;
}

@end
