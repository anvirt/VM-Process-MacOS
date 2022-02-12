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
 *  skin_agent.h
 *  Created by Chen Zhen <cz.worker@gmail.com> on 2022/1/11.
 */

#ifndef skin_agent_h
#define skin_agent_h

#include <stdio.h>
#include <android/skin/agent/agent.h>

__BEGIN_DECLS

void set_vm_window(void *window); // NSWindow *

typedef int (*ui_main_loop_fn)(anv_emu_agent_t *agt);
void setup_agent(ui_main_loop_fn main_loop);
int agent_main(void);

typedef enum agent_status {
  AgentStatusIdle = 1,
  AgentStatusWaitingExit = 2,
  AgentStatusQuit = 3,
} agent_status_t;

extern agent_status_t gAgentStatus;

__END_DECLS

#endif /* skin_agent_h */
