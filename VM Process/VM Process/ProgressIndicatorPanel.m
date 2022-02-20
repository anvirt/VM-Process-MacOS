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
 *  ProgressIndicatorPanel.m
 *  Created by Chen Zhen <cz.worker@gmail.com> on 2022/1/27.
 */

#import "ProgressIndicatorPanel.h"

@interface ProgressIndicatorPanel()
@property (strong) IBOutlet NSProgressIndicator *indicator;
@property (strong) IBOutlet NSTextField *text;
@property (strong) IBOutlet NSWindow *host;
@property (strong) IBOutlet NSButton *force_quit;
@end

@implementation ProgressIndicatorPanel

- (void) show {
  [self.indicator startAnimation:nil];
  [self.host beginSheet:self completionHandler:nil];
}

- (void) showText:(NSString *)text {
  self.force_quit.hidden = YES;
  self.text.stringValue = text;
  [self show];
}

- (void) showStopVM {
  self.force_quit.hidden = NO;
  self.text.stringValue = NSLocalizedString(@"stop vm...", nil);
  [self show];
}

- (void) dismiss {
  [self.indicator stopAnimation:nil];
  [self.host endSheet:self];
}

- (IBAction) force_quit_vm:(id)sender {
  NSLog(@"force quit vm!");
#if 0
  exit(1);
#else
  [[NSApplication sharedApplication] replyToApplicationShouldTerminate:YES];
#endif
}

@end
