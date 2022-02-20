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
 *  ProgressIndicatorPanel.h
 *  Created by Chen Zhen <cz.worker@gmail.com> on 2022/1/27.
 */

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@protocol WithIndicator
- (void) dismissIndicator;
@end

@interface ProgressIndicatorPanel : NSWindow
- (void) show;
- (void) showText:(NSString *)text;
- (void) showStopVM;
- (void) dismiss;
@end

NS_ASSUME_NONNULL_END
