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
 *  skin_agent.m
 *  Created by Chen Zhen <cz.worker@gmail.com> on 2022/1/11.
 */

#include <pthread.h>

#import <Cocoa/Cocoa.h>
#import "ProgressIndicatorPanel.h"

#include "vmproc.h"
#include "skin_event.h"
#include "skin_agent.h"

static void *window_handle = NULL;
static pthread_t ui_thread;
agent_status_t gAgentStatus = AgentStatusIdle;

static void agent_request_close(anv_emu_agent_t *agt) {
  if (gAgentStatus == AgentStatusWaitingExit) {
    [[NSApplication sharedApplication] replyToApplicationShouldTerminate:YES];
  } else {
    gAgentStatus = AgentStatusQuit;
    [[NSApplication sharedApplication] terminate:nil];
  }
}

typedef struct agent_spawn_thread_context {
  anv_emu_start_fn f;
  int argc;
  char **argv;
} agent_spawn_thread_context_t;

static void *agent_spawn_thread_func(void *ptr) {
  agent_spawn_thread_context_t *ctx = (agent_spawn_thread_context_t *) ptr;
  ctx->f(ctx->argc, ctx->argv);
  SAFE_FREE(ctx);
  
  // qemu thread exit, so we request close vm (main ui thread)
  agent_request_close(anv_emu_agent_get());
  return NULL;
}

static int agent_get_win_id(anv_emu_agent_t *agt, void **pwid) {
  *pwid = window_handle;
  return 0;
}

static int agent_set_window_pos(anv_emu_agent_t *agt, int x, int y) {
  dispatch_sync(dispatch_get_main_queue(), ^{
    NSWindow *window = (__bridge NSWindow *) window_handle;
    [window setFrameOrigin:NSPointFromCGPoint(CGPointMake(x, y))];
    [window center]; // TODO: 临时做法
  });
  return 0;
}

static int agent_set_window_size(anv_emu_agent_t *agt, int w, int h) {
  dispatch_sync(dispatch_get_main_queue(), ^{
    NSWindow *window = (__bridge NSWindow *) window_handle;
    NSRect frame_with_titlebar = [window frameRectForContentRect:NSRectFromCGRect(CGRectMake(0, 0, w, h))];
    NSRect f = window.frame;
    f.size = frame_with_titlebar.size;
    [window setFrame:f display:YES];
    [window center]; // TODO: 临时做法
  });
  return 0;
}

static int agent_poll_event(anv_emu_agent_t *agt, SkinEvent *event, int *has_event) {
  return anv_skin_event_poll(event, has_event);
}

static int agent_spawn_thread(anv_emu_agent_t *agt, anv_emu_start_fn f, int argc, char **argv) {
  agent_spawn_thread_context_t *ctx = TALLOC(agent_spawn_thread_context_t);
  ctx->f = f;
  ctx->argc = argc;
  ctx->argv = argv;
  pthread_t thr; // TODO: how to join thr
  pthread_create(&thr, NULL, agent_spawn_thread_func, ctx);
  return 0;
}

static int agent_run_on_ui_thread(anv_emu_agent_t *agt, anv_emu_ui_thread_fn f, void *data, int wait) {
  if (wait) {
    if (pthread_self() == ui_thread) {
      f(data);
    } else {
      dispatch_sync_f(dispatch_get_main_queue(), data, f);
    }
  } else {
    dispatch_async_f(dispatch_get_main_queue(), data, f);
  }
  return 0;
}

static void agent_boot_complete(anv_emu_agent_t *agt) {
  NSWindow *window = (__bridge NSWindow *) window_handle;
  id delegate = window.delegate;
  if ([delegate conformsToProtocol:@protocol(WithIndicator)]) {
    dispatch_sync(dispatch_get_main_queue(), ^{
      [delegate dismissIndicator];
    });
  } else {
    NSLog(@"boot complete!");
  }
}

static void agent_install_progress(anv_emu_agent_t *agt, double progress, int done) {
  if (!done) return;

#if 1
  dispatch_sync(dispatch_get_main_queue(), ^{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"install-finish" object:nil];
  });
#else
  NSWindow *window = (__bridge NSWindow *) window_handle;
  id delegate = window.delegate;
  if ([delegate conformsToProtocol:@protocol(WithIndicator)]) {
    dispatch_sync(dispatch_get_main_queue(), ^{
      [delegate dismissIndicator];
    });
  }
#endif
}

static void proc_request_close(void) {
  if (gAgentStatus == AgentStatusIdle) {
    [[NSApplication sharedApplication] terminate:nil];
  }
}

static void * run_qemu(void *data) {
  if (anv_vmproc_check_ready()) {
    // lost connect of vmm
    exit(1);
  }

  anv_emu_agent_t *agt = anv_emu_agent_get();
  agt->win_id = agent_get_win_id;
  agt->spawn_thread = agent_spawn_thread;
  agt->run_on_ui_thread = agent_run_on_ui_thread;
  agt->request_close = agent_request_close;
  agt->set_window_pos = agent_set_window_pos;
  agt->set_window_size = agent_set_window_size;
  agt->poll_event = agent_poll_event;
  agt->boot_complete = agent_boot_complete;
  agt->install_progress = agent_install_progress;

  if (anv_vmproc_start_vm(proc_request_close)) {
    // start vm failed
    exit(2);
  }
  SAFE_FREE_AGENT(agt);
  return NULL;
}


void set_vm_window(void *window) {
  window_handle = window;
}

void setup_agent(ui_main_loop_fn main_loop) {
  anv_emu_agent_get()->run_main_loop = main_loop;
  anv_skin_event_init();
}

int agent_main() {
  ui_thread = pthread_self();
  run_qemu(NULL);
  return 0;
}
