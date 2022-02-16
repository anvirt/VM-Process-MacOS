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
 *  main.m
 *  Created by Chen Zhen <cz.worker@gmail.com> on 2021/12/19.
 */

#import <Cocoa/Cocoa.h>
#import "AppDelegate.h"

#define ANV_LOG_TAG "main"
#include <base/log.h>
#include "vmproc.h"
#include "skin_agent.h"

static int ui_main_loop(anv_emu_agent_t *agt) {
  NSApplication *app = [NSApplication sharedApplication];
  [app run];
  return 0;
}

int main(int argc, const char * argv[]) {
  NSString *launcher_dir = [[[NSBundle mainBundle] executablePath] stringByDeletingLastPathComponent];
  setenv("ANDROID_EMULATOR_LAUNCHER_DIR", launcher_dir.UTF8String, 1);
  NSString *resource_dir = [NSBundle mainBundle].resourcePath;
  setenv("ANVIRT_EMU_BUNDLE_DATA_PATH", resource_dir.UTF8String, 1);

  NSApplication *app = [NSApplication sharedApplication];
  id<NSApplicationDelegate> delegate = [[AppDelegate alloc] init];
  app.delegate = delegate;

  setup_agent(ui_main_loop);
  NSLog(@"start vm process...");
  return anv_vmproc_main(agent_main, QemuMain);
}
