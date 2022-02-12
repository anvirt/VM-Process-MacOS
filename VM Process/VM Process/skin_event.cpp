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
 *  skin_event.cpp
 *  Created by Chen Zhen <cz.worker@gmail.com> on 2022/1/11.
 */

#include <string.h>
#include "android/base/synchronization/Lock.h"
#include "skin_event.h"

//--------------------------------------------------------------------------------------------------------------
// simple event queue
//--------------------------------------------------------------------------------------------------------------

typedef struct skin_event_item skin_event_item_t;
struct skin_event_item {
  SkinEvent *data;
  skin_event_item_t *next;
};

typedef struct skin_event_queue {
  skin_event_item_t *head, *tail;
  int n;
} skin_event_queue_t;

static void skin_event_queue_enqueue(skin_event_queue_t *q, SkinEvent *event) {
  if (!q) return;

  skin_event_item_t *item = new skin_event_item_t;
  item->data = event;
  item->next = NULL;
  if (q->tail) {
    q->tail->next = item;
    q->tail = item;
  } else {
    q->head = q->tail = item;
  }
  q->n++;
  // fprintf(stderr, "[event-trace] %s() 2 [%03d] head-%p, next->%p, tail-%p\n", __func__, q->n, q->head, q->head ? q->head->next:NULL, q->tail); fflush(stderr);
}

static SkinEvent * skin_event_queue_dequeue(skin_event_queue_t *q) {
  if (!q) return NULL;
  if (q->n == 0) {
    return NULL;
  } else {
    // fprintf(stderr, "[event-trace] %s() 2 [%03d] head-%p, next->%p, tail-%p\n", __func__, q->n, q->head, q->head ? q->head->next:NULL, q->tail); fflush(stderr);
    skin_event_item_t *item = q->head;
    q->head = item->next;
    q->n--;
    SkinEvent *data = item->data;
    delete item;
    
    if (q->n == 0) {
      q->tail = NULL;
    }
    return data;
  }
}

static SkinEvent * skin_event_queue_at(skin_event_queue_t *q, int pos) {
  if (!q) return NULL;
  if (!q->n) return NULL;
  if (pos == q->n - 1) return q->tail->data;
  skin_event_item_t *item = q->head;
  while (item && pos > 0) {
    item = item->next;
    pos--;
  }
  return item ? item->data : NULL;
}

// replace data at pos, old data should be handle before replace
static void skin_event_queue_replace(skin_event_queue_t *q, int pos, SkinEvent *event) {
  if (!q) return;
  if (!q->n) return;
  if (pos == q->n - 1) q->tail->data = event;
  
  skin_event_item_t *item = q->head;
  while (item && pos > 0) {
    item = item->next;
    pos--;
  }
  
  if (item) {
    item->data = event;
  }
}

static skin_event_queue_t g_queue;
static android::base::Lock g_queue_lock;

//--------------------------------------------------------------------------------------------------------------
// API
//--------------------------------------------------------------------------------------------------------------

ANV_VMPROC_API void anv_skin_event_init(void) {
  memset(&g_queue, 0x0, sizeof(skin_event_queue_t));
}

ANV_VMPROC_API int anv_skin_event_poll(SkinEvent *event, int *has_event) {
  android::base::AutoLock lock(g_queue_lock);
  SkinEvent *dequeue = skin_event_queue_dequeue(&g_queue);
  if (dequeue) {
    *has_event = 1;
    memcpy(event, dequeue, sizeof(SkinEvent));
    delete dequeue;
  } else {
    *has_event = 0;
  }
  return 0;
}

ANV_VMPROC_API int anv_skin_event_queue(SkinEvent *event) {
  android::base::AutoLock lock(g_queue_lock);

  // For the following events, only the "last" example of said event
  // matters, so ensure that there is only one of them in the queue at a
  // time. Additionaly the screen changed event processing is very slow,
  // so let's not generate too many of them.
  bool replaced = false;
  const auto type = event->type;
  if (type == kEventScrollBarChanged ||
      type == kEventZoomedWindowResized ||
      type == kEventScreenChanged) {
    for (int i = 0; i < g_queue.n; i++) {
      SkinEvent *at = skin_event_queue_at(&g_queue, i);
      if (at->type == type) {
        skin_event_queue_replace(&g_queue, i, event);
        delete at;
        replaced = true;
        break;
      }
    }
  }

  if (!replaced) {
    skin_event_queue_enqueue(&g_queue, event);
  }
  return 0;
}

ANV_VMPROC_API SkinEvent * anv_skin_event_new(SkinEventType event_type) {
  SkinEvent *event = new SkinEvent;
  event->type = event_type;
  return event;
}

static SkinRotation gRot = SKIN_ROTATION_0;
static inline void do_rotate(SkinRotation rot) {
  SkinEvent *event = anv_skin_event_new(kEventLayoutRotate);
  event->u.layout_rotation.rotation = rot;
  anv_skin_event_queue(event);

  // To fix issues when resizing + linking against macos sdk 11.
  anv_skin_event_queue(anv_skin_event_new(kEventScreenChanged));
}

ANV_VMPROC_API void skin_rotate_left(void) {
  switch (gRot) {
    case SKIN_ROTATION_0:   gRot = SKIN_ROTATION_270; break;
    case SKIN_ROTATION_90:  gRot = SKIN_ROTATION_0; break;
    case SKIN_ROTATION_180: gRot = SKIN_ROTATION_90; break;
    case SKIN_ROTATION_270: gRot = SKIN_ROTATION_180; break;
  }
  do_rotate(gRot);
}

ANV_VMPROC_API void skin_rotate_right(void) {
  switch (gRot) {
    case SKIN_ROTATION_0:   gRot = SKIN_ROTATION_90; break;
    case SKIN_ROTATION_90:  gRot = SKIN_ROTATION_180; break;
    case SKIN_ROTATION_180: gRot = SKIN_ROTATION_270; break;
    case SKIN_ROTATION_270: gRot = SKIN_ROTATION_0; break;
  }
  do_rotate(gRot);
}

static inline void forward_keyevent(uint16_t key, int down) {
  SkinEvent* skin_event = anv_skin_event_new(down ? kEventKeyDown : kEventKeyUp);
  skin_event->u.key.keycode = key;
  skin_event->u.key.mod = 0;
  anv_skin_event_queue(skin_event);
}

ANV_VMPROC_API void skin_volume_up(void) {
  forward_keyevent(LINUX_KEY_VOLUMEUP, 1);
  forward_keyevent(LINUX_KEY_VOLUMEUP, 0);
}

ANV_VMPROC_API void skin_volume_down(void) {
  forward_keyevent(LINUX_KEY_VOLUMEDOWN, 1);
  forward_keyevent(LINUX_KEY_VOLUMEDOWN, 0);
}

ANV_VMPROC_API void skin_forward_key_home(void) {
  forward_keyevent(LINUX_KEY_HOME, 1);
  forward_keyevent(LINUX_KEY_HOME, 0);
}

ANV_VMPROC_API void skin_forward_key_back(void) {
  forward_keyevent(LINUX_KEY_BACK, 1);
  forward_keyevent(LINUX_KEY_BACK, 0);
}

ANV_VMPROC_API void skin_forward_key_recent(void) {
  forward_keyevent(KEY_APPSWITCH, 1);
  forward_keyevent(KEY_APPSWITCH, 0);
}

ANV_VMPROC_API void skin_forward_key_power(void) {
  forward_keyevent(LINUX_KEY_POWER, 1);
  forward_keyevent(LINUX_KEY_POWER, 0);
}
