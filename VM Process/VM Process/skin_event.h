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
 *  skin_event.h
 *  Created by Chen Zhen <cz.worker@gmail.com> on 2022/1/11.
 */

#ifndef skin_event_h
#define skin_event_h

#include <android/skin/event.h>
#include <android/skin/keycode.h>
#include <vmproc/vmproc.h>

__BEGIN_DECLS

ANV_VMPROC_API void anv_skin_event_init(void);
ANV_VMPROC_API int anv_skin_event_poll(SkinEvent *event, int *has_event);
ANV_VMPROC_API int anv_skin_event_queue(SkinEvent *event);

ANV_VMPROC_API SkinEvent * anv_skin_event_new(SkinEventType event_type);

ANV_VMPROC_API void skin_rotate_left(void);
ANV_VMPROC_API void skin_rotate_right(void);
ANV_VMPROC_API void skin_volume_up(void);
ANV_VMPROC_API void skin_volume_down(void);
ANV_VMPROC_API void skin_forward_key_home(void);
ANV_VMPROC_API void skin_forward_key_back(void);
ANV_VMPROC_API void skin_forward_key_recent(void);
ANV_VMPROC_API void skin_forward_key_power(void);
ANV_VMPROC_API void skin_forward_key_power_long(void);

__END_DECLS

#endif /* skin_event_h */
