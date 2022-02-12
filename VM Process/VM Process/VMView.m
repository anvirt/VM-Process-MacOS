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
 *  VMView.m
 *  Created by Chen Zhen <cz.worker@gmail.com> on 2022/1/10.
 */

#import "VMView.h"
#include "skin_event.h"
#include "keymap.h"

static int prev_mouse_x = 0;
static int prev_mouse_y = 0;

static inline void handle_mouse_event(SkinEventType event_type, SkinMouseButtonType button_type, int lx, int ly, int gx, int gy) {
  if (event_type == kEventMouseButtonDown) {
    // mToolWindow->reportMouseButtonDown();
  }

  SkinEvent* skin_event = anv_skin_event_new(event_type);
  skin_event->u.mouse.button = button_type;
  skin_event->u.mouse.skip_sync = false;
  skin_event->u.mouse.x = lx;
  skin_event->u.mouse.y = ly;
  skin_event->u.mouse.x_global = gx;
  skin_event->u.mouse.y_global = gy;

  skin_event->u.mouse.xrel = lx - prev_mouse_x;
  skin_event->u.mouse.yrel = ly - prev_mouse_y;
  prev_mouse_x = lx;
  prev_mouse_y = ly;

  anv_skin_event_queue(skin_event);
}

static inline void handle_key_event(SkinEventType event_type, uint16_t key, NSEventModifierFlags mod, const char *text) {
  uint16_t lkey;
  if (map_key(key, &lkey)) {
    return;
  }

  SkinEvent* skin_event = anv_skin_event_new(event_type);
  skin_event->u.key.keycode = lkey;
  skin_event->u.key.mod = 0;
  if (mod & NSEventModifierFlagShift)
    skin_event->u.key.mod |= kKeyModLShift;
  if (mod & NSEventModifierFlagControl)
    skin_event->u.key.mod |= kKeyModLCtrl;
  if (mod & NSEventModifierFlagOption)
    skin_event->u.key.mod |= kKeyModLAlt;

  anv_skin_event_queue(skin_event);

  if (event_type == kEventKeyDown && (text && text[0])) {
    mod &= NSEventModifierFlagDeviceIndependentFlagsMask & ~(NSEventModifierFlagShift | NSEventModifierFlagNumericPad);
    if (mod == 0) {
      // The key event generated text without Ctrl, Alt, etc.
      // Send an additional TextInput event to the emulator.
      SkinEvent* skin_event = anv_skin_event_new(kEventTextInput);
      skin_event->u.text.down = false;
      strlcpy((void *) skin_event->u.text.text, text, sizeof(skin_event->u.text.text));
      anv_skin_event_queue(skin_event);
    }
  }
}

@implementation VMView

//-------------------------------------------------------------------------------------
// 输入（键盘&鼠标）
//-------------------------------------------------------------------------------------

// 响应键盘事件处理
- (BOOL)acceptsFirstResponder {
  return YES;
}

#define DISABLE_HANDLE_KEY (1)

// 键盘事件处理
- (void)keyDown:(NSEvent *)event {
#if DISABLE_HANDLE_KEY && 0
  NSLog(@"key down: %@", event);
#else
  handle_key_event(kEventKeyDown, event.keyCode, event.modifierFlags, event.characters.UTF8String);
#endif
}

- (void)keyUp:(NSEvent *)event {
#if DISABLE_HANDLE_KEY && 0
  NSLog(@"key up: %@", event);
#else
  handle_key_event(kEventKeyUp, event.keyCode, event.modifierFlags, event.characters.UTF8String);
#endif
}

- (void)flagsChanged:(NSEvent *)event {
#if DISABLE_HANDLE_KEY && 0
  NSLog(@"key flags changed: %@, %d", event, (event.modifierFlags & NSEventModifierFlagShift) != 0);
#else
  // TODO: 处理控制按钮的切换状态
  // handle_key_event(kEventKeyDown, event.keyCode, event.modifierFlags);
#endif
}

#define LOC_COORD_TRANS(_pos) do { (_pos).y = self.frame.size.height - (_pos).y; } while (0);
// TODO: global localtion translate ???

- (void)mouseDown:(NSEvent *)event {
#if DISABLE_HANDLE_KEY && 0
  NSLog(@"mouse down: %@", event);
#else
  NSPoint gpos = [NSEvent mouseLocation];
  NSPoint lpos = event.locationInWindow;
  LOC_COORD_TRANS(lpos);
  switch (event.type) {
    case NSEventTypeLeftMouseDown:
      handle_mouse_event(kEventMouseButtonDown, kMouseButtonLeft, lpos.x, lpos.y, gpos.x, gpos.y);
      break;
    case NSEventTypeRightMouseDown:
      handle_mouse_event(kEventMouseButtonDown, kMouseButtonRight, lpos.x, lpos.y, gpos.x, gpos.y);
      break;
    default: break;
  }
#endif
}

- (void)mouseUp:(NSEvent *)event {
#if DISABLE_HANDLE_KEY && 0
  NSLog(@"mouse up: %@", event);
#else
  NSPoint gpos = [NSEvent mouseLocation];
  NSPoint lpos = event.locationInWindow;
  LOC_COORD_TRANS(lpos);
  switch (event.type) {
    case NSEventTypeLeftMouseUp:
      handle_mouse_event(kEventMouseButtonUp, kMouseButtonLeft, lpos.x, lpos.y, gpos.x, gpos.y);
      break;
    case NSEventTypeRightMouseUp:
      handle_mouse_event(kEventMouseButtonUp, kMouseButtonRight, lpos.x, lpos.y, gpos.x, gpos.y);
      break;
    default: break;
  }
#endif
}

- (void)mouseDragged:(NSEvent *)event {
#if DISABLE_HANDLE_KEY && 0
  NSLog(@"mouse dragged: %@", event);
#else
  NSPoint gpos = [NSEvent mouseLocation];
  NSPoint lpos = event.locationInWindow;
  LOC_COORD_TRANS(lpos);
  switch (event.type) {
    case NSEventTypeLeftMouseDragged:
      handle_mouse_event(kEventMouseMotion, kMouseButtonLeft, lpos.x, lpos.y, gpos.x, gpos.y);
      break;
    case NSEventTypeRightMouseDragged:
      handle_mouse_event(kEventMouseMotion, kMouseButtonRight, lpos.x, lpos.y, gpos.x, gpos.y);
      break;
    default: break;
  }
#endif
}

// 忽略右键事件
- (void)rightMouseDown:(NSEvent *)event {}
- (void)rightMouseUp:(NSEvent *)event {}
- (void)rightMouseDragged:(NSEvent *)event {}

- (void)scrollWheel:(NSEvent *)event {
#if DISABLE_HANDLE_KEY && 0
  NSLog(@"scroll: %@", event);
#elif 0 // test and enable later
  // start
  anv_skin_event_queue(anv_skin_event_new(kEventMouseStartTracking));

  // scroll
  int dx = event.scrollingDeltaX;
  int dy = event.scrollingDeltaY;
  SkinEvent* skin_event = anv_skin_event_new(kEventMouseWheel);
  skin_event->u.wheel.x_delta = dx;
  skin_event->u.wheel.y_delta = dy;
  anv_skin_event_queue(skin_event);

  // stop
  anv_skin_event_queue(anv_skin_event_new(kEventMouseStopTracking));
#endif
}

@end
