/*
 *  VM Process MacOS
 *  Copyright (C) 2020 AnVirt
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
 *  keymap.h
 *  Created by Chen Zhen <cz.worker@gmail.com> on 2020/12/15.
 */

#ifndef anvirt_keymap_h
#define anvirt_keymap_h

#include <stdio.h>

#ifdef __cplusplus
extern "C" {
#endif

// map mac key code to linux keycode
int map_key(uint16_t in_key, uint16_t *out_key);

#ifdef __cplusplus
}
#endif


#endif /* anvirt_keymap_h */
