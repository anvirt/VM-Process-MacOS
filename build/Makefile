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

.PHONY: all
all: build

PROJECT_TOP := $(shell dirname `pwd`)
OUT_LIB := ${PROJECT_TOP}/output/lib

TAGS := ""
ifeq (${DEBUG},1)
	TAGS := "${TAGS} debug trace"
endif

${OUT_LIB}:
	@mkdir -p ${OUT_LIB}

TARGET_ARCHS := x86_64 arm64
HOST_ARCH := $(shell uname -m)
CROSS_ARCHS := $(filter-out ${TARGET_ARCHS},${HOST_ARCH}) 

${OUT_LIB}/libvm-process.${HOST_ARCH}.a: ${OUT_LIB}
	@echo "build $(shell basename $@) (native)..."
	@go clean -cache
	@cd ${PROJECT_TOP}/core; \
		go build -a \
		-tags ${TAGS} \
		-buildmode=c-archive \
		-o $@ \
		.

${CROSS_ARCHS:%=${OUT_LIB}/libvm-process.%.a}: ${OUT_LIB}
	$(error "build $(shell basename $@) and put $@")

.PHONY: build_universal
build_universal: ${TARGET_ARCHS:%=${OUT_LIB}/libvm-process.%.a}
	@rm -f ${OUT_LIB}/libvm-process.a
	@echo "make universal..."
	@lipo -create $^ -output ${OUT_LIB}/libvm-process.a
	@echo "done!"

.PHONY: build
build: ${OUT_LIB}/libvm-process.${HOST_ARCH}.a

.PHONY: clean
clean:
	@rm -rf ${OUT_LIB}

.PHONY: prebuilts
prebuilts:
	@make -C ${PROJECT_TOP}/prebuilts/ debug
