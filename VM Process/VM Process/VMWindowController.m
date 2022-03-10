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
 *  VMWindowController.m
 *  Created by Chen Zhen <cz.worker@gmail.com> on 2021/12/23.
 */

#import <UniformTypeIdentifiers/UniformTypeIdentifiers.h>
#import "VMWindowController.h"
#import "ProgressIndicatorPanel.h"
#import "DragAndDropInstallWindow.h"

#include "vmproc.h"
#include "skin_event.h"
#include "skin_agent.h"

@interface VMWindowController () <NSWindowDelegate, WithIndicator> {
  bool isShutting;
}
@property (strong) IBOutlet NSView *titlebar;
@property (strong) IBOutlet ProgressIndicatorPanel *progress_indicator;
@property (strong) IBOutlet DragAndDropInstallWindow *drag_and_drop_window;
@property (strong) IBOutlet NSPopover *popover_help;
@end

@implementation VMWindowController

+ (instancetype) create {
  return [[VMWindowController alloc] initWithWindowNibName:@"VMWindow"];
}

- (void)windowDidLoad {
  [super windowDidLoad];
  isShutting = NO;

  set_vm_window((__bridge void *) self.window);
  [self.progress_indicator showText: NSLocalizedString(@"start vm...", nil)];

  // titlebar
  NSTitlebarAccessoryViewController *ttb = [[NSTitlebarAccessoryViewController alloc] init];
  ttb.view = self.titlebar;
  ttb.layoutAttribute = NSLayoutAttributeRight;
  [self.window addTitlebarAccessoryViewController: ttb];
}

- (void) doShutDown {
#if 1
  // long press Power button to show action in android
  {
    dispatch_queue_t queue = dispatch_queue_create("long-press-powner-button", DISPATCH_QUEUE_CONCURRENT);
    dispatch_async(queue, ^{
      NSLog(@"[shutdown] start notify...");
      skin_forward_key_power_long();
      NSLog(@"[shutdown] done notify");
    });
  }
#else
  if (isShutting) {
    return;
  }
  isShutting = YES;
  // TODO: confirm
  [self.progress_indicator showStopVM];
  anv_emu_agent_shutdown(anv_emu_agent_get());
#endif
}

//------------------------------------------------------------------------------------------------------
// WithIndicator
//------------------------------------------------------------------------------------------------------
- (void) dismissIndicator {
  [self.progress_indicator dismiss];
}

//------------------------------------------------------------------------------------------------------
// NSWindowDelegate
//------------------------------------------------------------------------------------------------------
- (BOOL)windowShouldClose:(NSWindow *)sender {
  return YES;
}

//------------------------------------------------------------------------------------------------------
// action
//------------------------------------------------------------------------------------------------------

- (IBAction)install_apk:(id)sender {
#if 1
  [self.drag_and_drop_window show:^(NSModalResponse returnCode) {
    NSLog(@"drag-drop install panel dismiss: %ld", returnCode);
  }];
#else
  NSOpenPanel *open_panel = [NSOpenPanel openPanel];
  open_panel.prompt = NSLocalizedString(@"Install", nil);
  open_panel.message = NSLocalizedString(@"Choose APK file", nil);
  open_panel.allowedContentTypes = @[
    [UTType typeWithFilenameExtension:@"apk"],
  ];
  open_panel.allowsMultipleSelection = NO;
  [open_panel beginSheetModalForWindow:self.window completionHandler:^(NSModalResponse result) {
    if (result != NSModalResponseOK) {
      return;
    }

    [self.progress_indicator showText:NSLocalizedString(@"install...", nil)];
    NSString *apk_file = open_panel.URL.path;
    anv_emu_agent_install(anv_emu_agent_get(), apk_file.UTF8String);
  }];
#endif
}

- (IBAction) show_help:(id)sender {
  NSButton* btn = sender;
  NSRect rect = [self.popover_help.contentViewController.view bounds];
  [self.popover_help showRelativeToRect:rect ofView:btn preferredEdge:NSRectEdgeMinY];
}

- (IBAction) shutdown_vm:(id)sender {
  [[NSApplication sharedApplication] terminate:sender];
}

- (IBAction) rotate_left:(id)sender {
  skin_rotate_left();
}

- (IBAction) rotate_right:(id)sender {
  skin_rotate_right();
}

- (IBAction) volume_up:(id)sender {
  skin_volume_up();
}

- (IBAction) volume_down:(id)sender {
  skin_volume_down();
}

- (IBAction) forward_key_home:(id)sender {
  skin_forward_key_home();
}

- (IBAction) forward_key_back:(id)sender {
  skin_forward_key_back();
}

- (IBAction) forward_key_recent:(id)sender {
  skin_forward_key_recent();
}

- (IBAction) forward_key_power:(id)sender {
  skin_forward_key_power();
}

@end
