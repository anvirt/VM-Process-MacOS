/*
 *  VM Process MacOS
 *  Copyright (C) 2022 AnVirt
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
 *  DragAndDropInstallWindow.m
 *  Created by Chen Zhen <cz.worker@gmail.com> on 2022/2/9.
 */

#import <Carbon/Carbon.h>
#import "DragAndDropInstallWindow.h"
#include "skin_agent.h"

@interface DragAndDropInstallWindow () <NSDraggingDestination>
@property (weak) IBOutlet NSWindow *parent;

@property (strong) IBOutlet NSTextField *tip;
@property (strong) IBOutlet NSTextField *status;
@property (strong) IBOutlet NSProgressIndicator *indicator;
@end

@implementation DragAndDropInstallWindow

- (void)awakeFromNib {
  // drag and drop
  [self registerForDraggedTypes:@[NSPasteboardTypeFileURL]];
}

- (void)dealloc {
    [self unregisterDraggedTypes];
}

-(void)show:(void (^ _Nullable)(NSModalResponse returnCode))handler {
  [self.indicator stopAnimation:nil];
  [self idle];
  [self.parent beginSheet:self completionHandler:handler];
  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(onInstallFinish:)
                                               name:@"install-finish"
                                             object:nil];
}

-(void)dismiss {
  [self.parent endSheet:self returnCode:NSModalResponseCancel];
  [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)keyUp:(NSEvent *)event {
  if (event.keyCode == kVK_Escape) {
    [self dismiss];
  }
}

- (void) idle {
  [self tip_text:NSLocalizedString(@"Drag APK to install", nil)];
  [self status_text:NSLocalizedString(@"Press ESC to exit", nil)];
}

- (void) tip_text:(NSString *)text {
  self.tip.stringValue = text;
}

- (void) status_text:(NSString *)text {
  self.status.stringValue = text;
}

- (BOOL)do_install:(NSString *)path {
  if (![path hasSuffix:@".apk"]) {
    return NO;
  }
  [self.indicator startAnimation:nil];
  anv_emu_agent_install(anv_emu_agent_get(), path.UTF8String);
  return YES;
}

- (NSString *)findAPKFromPasteBoard:(NSPasteboard *)pb {
  if (pb.pasteboardItems.count == 1) {
    NSURL *url = [NSURL URLFromPasteboard:pb];
    if ([url.path hasSuffix:@".apk"]) {
      return url.path;
    }
  } else if (pb.pasteboardItems.count > 1) {
    NSArray *list = [pb readObjectsForClasses:@[[NSURL class]] options:nil];
    for (NSURL *url in list) {
      if ([url.path hasSuffix:@".apk"]) {
        return url.path;
      }
    }
  }
  return nil;
}

#pragma mark - NSDraggingDestination

- (NSDragOperation)draggingEntered:(id <NSDraggingInfo>)sender {
  NSString *path = [self findAPKFromPasteBoard:sender.draggingPasteboard];
  if (path == nil) {
    return NSDragOperationNone;
  }
  [self status_text:[NSString stringWithFormat:NSLocalizedString(@"Install %@", nil), path.lastPathComponent]];
  [self tip_text:@""];
  return NSDragOperationCopy;
}

- (void)draggingExited:(nullable id <NSDraggingInfo>)sender {
  [self idle];
}

- (BOOL)prepareForDragOperation:(id <NSDraggingInfo>)sender {
  return [self findAPKFromPasteBoard:sender.draggingPasteboard] != nil;
}

- (BOOL)performDragOperation:(id <NSDraggingInfo>)sender {
  NSString *path = [self findAPKFromPasteBoard:sender.draggingPasteboard];
  NSLog(@"[install] %@", path);
  return [self do_install:path];
}

#pragma mark - install event
-(void)onInstallFinish:(NSNotification *)notification {
  [self.indicator stopAnimation:nil];
  [self idle];
  [self tip_text:NSLocalizedString(@"install finish", nil)];
}

@end
