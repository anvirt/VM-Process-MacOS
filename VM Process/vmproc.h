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
 *  vmproc.h
 *  Created by Chen Zhen <cz.worker@gmail.com> on 2021/12/23.
 */

#ifndef vmproc_h
#define vmproc_h

#include <vmproc/vmproc.h>

extern int anvirt_qemu_main(int argc, char** argv);
#define QemuMain anvirt_qemu_main

#define _STR(_expr) _handle_native_cstring(_expr)

static inline NSString *_handle_native_cstring(char *cstr) {
  NSString *str = [NSString stringWithUTF8String:cstr];
  SAFE_FREE(cstr);
  return str;
}

#endif /* vmproc_h */
