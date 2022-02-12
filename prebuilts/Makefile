#
#  VM Process MacOS
#  Copyright (C) 2021 AnVirt
#
#  This program is free software; you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation; either version 2 of the License, or
#  (at your option) any later version.
#
#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
#
#  You should have received a copy of the GNU General Public
#  License along with this library; if not, see <http://www.gnu.org/licenses/>.
#

.PHONY: debug
debug: deps

PROJECT_TOP := $(shell dirname `pwd`)
OUT_LIB := ${PROJECT_TOP}/output/lib

HOST_ARCH := $(shell uname -m)
QEMU_LIB_ARCH := Unknown
ifeq (${HOST_ARCH},arm64)
QEMU_LIB_ARCH := aarch64
else
QEMU_LIB_ARCH := ${HOST_ARCH}
endif


# set QEMU_OUT or link qemu out dir to qemu_out
QEMU_OUT ?= qemu_out
# set QEMU_PROJECT or link qemu project path to qemu_project
QEMU_PROJECT ?= qemu_project

QEMU_LOCAL := qemu

QEMU_DEPS := \
	${QEMU_LOCAL}/bin64/e2fsck \
	${QEMU_LOCAL}/bin64/resize2fs \
	${QEMU_LOCAL}/lib/pc-bios/bios-256k.bin \
	${QEMU_LOCAL}/lib/pc-bios/efi-virtio.rom \
	${QEMU_LOCAL}/lib64/libOpenglRender.dylib \
	${QEMU_LOCAL}/lib64/libemugl_common.dylib \
	${QEMU_LOCAL}/lib64/libshadertranslator.dylib \
	${QEMU_LOCAL}/lib64/vulkan/libvulkan.dylib \
	${QEMU_LOCAL}/lib64/libqemu-system-anvirt-emu.dylib

QEMU_HEADERS := \
	${QEMU_LOCAL}/android/android-emu-base/android/base/synchronization/Lock.h \
	${QEMU_LOCAL}/android/android-emu-base/android/base/system/System.h \
	${QEMU_LOCAL}/android/android-emu-base/android/base/Debug.h \
	${QEMU_LOCAL}/android/android-emu-base/android/base/CpuTime.h \
	${QEMU_LOCAL}/android/android-emu-base/android/base/EnumFlags.h \
	${QEMU_LOCAL}/android/android-emu-base/android/base/Optional.h \
	${QEMU_LOCAL}/android/android-emu-base/android/base/Log.h \
	${QEMU_LOCAL}/android/android-emu-base/android/base/TypeTraits.h \
	${QEMU_LOCAL}/android/android-emu-base/android/base/Compiler.h \
	${QEMU_LOCAL}/android/android-emu-base/android/base/StringView.h \
	${QEMU_LOCAL}/android/android-emu-base/android/utils/compiler.h \
	${QEMU_LOCAL}/android/android-emu-base/android/utils/log_severity.h \
	${QEMU_LOCAL}/android/android-emu-base/android/utils/debug.h \
	${QEMU_LOCAL}/android/android-emu/android/skin/rect.h \
	${QEMU_LOCAL}/android/android-emu/android/skin/keycode.h \
	${QEMU_LOCAL}/android/android-emu/android/skin/android_keycodes.h \
	${QEMU_LOCAL}/android/android-emu/android/skin/linux_keycodes.h \
	${QEMU_LOCAL}/android/android-emu/android/skin/event.h \
	${QEMU_LOCAL}/android/android-emu/android/skin/agent/def.h \
	${QEMU_LOCAL}/android/android-emu/android/skin/agent/version.h \
	${QEMU_LOCAL}/android/android-emu/android/skin/agent/agent.h

# bin
${QEMU_LOCAL}/bin64/%:
	@mkdir -p `dirname $@`
	@cp ${QEMU_OUT}/bin64/$* $@

# qemu lib
${QEMU_LOCAL}/lib64/libqemu-system-anvirt-emu.dylib:
	@mkdir -p `dirname $@`
	@cp ${QEMU_OUT}/lib64/libqemu-system-${QEMU_LIB_ARCH}-anvirt-emu.dylib $@
	@install_name_tool -id @rpath/$(shell basename $@) $@

# qemu other libs
${QEMU_LOCAL}/lib64/%:
	@mkdir -p `dirname $@`
	@cp ${QEMU_OUT}/lib64/$* $@

${QEMU_LOCAL}/lib/pc-bios/%:
	@mkdir -p `dirname $@`
	@cp ${QEMU_PROJECT}/pc-bios/$* $@

${QEMU_LOCAL}/android/%:
	@mkdir -p `dirname $@`
	@cp ${QEMU_PROJECT}/android/$* $@

.PHONY: deps
deps: ${QEMU_DEPS} ${QEMU_HEADERS}

.PHONY: clean_deps
clean_deps:
	@rm -rf ${QEMU_LOCAL}
