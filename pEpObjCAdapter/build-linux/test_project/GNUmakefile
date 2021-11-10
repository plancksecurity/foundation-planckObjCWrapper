#
# An example GNUmakefile
#
# To Run: `make messages=yes
# Include the common variables defined by the Makefile Package
include $(GNUSTEP_MAKEFILES)/common.make
#include $(GNUSTEP_MAKEFILES)/rules.make

#######################################
# Sampel Excecutable Using PEPObjCAdapter
#######################################

# Build Dependencies
SHELL_RESULT := $(shell ./build-dependencies.sh)

TOOL_NAME = ClientOfObjcAdapter

# Build pre-compiled prefix header
GNUSTEPHELPER_DIR=../../../../pepgnustephelper
FLAGS_FOR_PRECOMPILED_HEADER_DEBUG="-pthread -MMD -MP -DGNUSTEP -DGNUSTEP_BASE_LIBRARY=1 -DGNU_GUI_LIBRARY=1 -DGNUSTEP_RUNTIME=1 -D_NONFRAGILE_ABI=1 -DGNUSTEP_BASE_LIBRARY=1 -I./obj/pEpObjCTypes.obj/PrecompiledHeaders/ObjC -fno-strict-aliasing -fexceptions -fobjc-exceptions -D_NATIVE_OBJC_EXCEPTIONS -fobjc-runtime=gnustep-2.0 -fobjc-arc -fPIC -g -fblocks -fobjc-runtime=gnustep-2.0 -fblocks -fconstant-string-class=NSConstantString -I../PublicHeaders/ -I../src/ -I../src/PEPEqualableTools -I. -I/home/user/GNUstep/Library/Headers -I/usr/GNUstep/Local/Library/Headers -I/usr/GNUstep/System/Library/Headers -I/usr/GNUstep/Local/Library/Headers -I/usr/GNUstep/Local/Library/Headers -I/usr/GNUstep/System/Library/Headers -I/usr/GNUstep/System/Library/Headers -fblocks -x objective-c -I/usr/include/libxml2 -I/usr/include/libxml2 -I/usr/include/p11-kit-1"
FLAGS_FOR_PRECOMPILED_HEADER_RELEASE="-pthread -MMD -MP -DGNUSTEP -DGNUSTEP_BASE_LIBRARY=1 -DGNU_GUI_LIBRARY=1 -DGNUSTEP_RUNTIME=1 -D_NONFRAGILE_ABI=1 -DGNUSTEP_BASE_LIBRARY=1 -I./obj/pEpObjCTypes.obj/PrecompiledHeaders/ObjC -fno-strict-aliasing -fexceptions -fobjc-exceptions -D_NATIVE_OBJC_EXCEPTIONS -fobjc-runtime=gnustep-2.0 -fobjc-arc -fPIC -g -O2 -fblocks -fobjc-runtime=gnustep-2.0 -fblocks -fconstant-string-class=NSConstantString -I../PublicHeaders/ -I../src/ -I../src/PEPEqualableTools -I. -I/home/user/GNUstep/Library/Headers -I/usr/GNUstep/Local/Library/Headers -I/usr/GNUstep/System/Library/Headers -I/usr/GNUstep/Local/Library/Headers -I/usr/GNUstep/Local/Library/Headers -I/usr/GNUstep/System/Library/Headers -I/usr/GNUstep/System/Library/Headers -fblocks -x objective-c -I/usr/include/libxml2 -I/usr/include/libxml2 -I/usr/include/p11-kit-1"
ifeq ($(debug), yes)
    FLAGS_FOR_PRECOMPILED_HEADER = ${FLAGS_FOR_PRECOMPILED_HEADER_DEBUG}
else
    FLAGS_FOR_PRECOMPILED_HEADER = ${FLAGS_FOR_PRECOMPILED_HEADER_RELEASE}
endif
SHELL_RESULT := $(shell ${GNUSTEPHELPER_DIR}/build-precompiled-header.sh ${FLAGS_FOR_PRECOMPILED_HEADER})
# Keep. Useful to manually figure out flags for precompiled header.
#pEpObjCAdapter_OBJC_PRECOMPILED_HEADERS = ${GNUSTEPHELPER_DIR}/PEPObjCGNUStepOptimizations.h

# Header Search Paths
PEP_OBJC_TYPES_HEADER_DIRS_PREFIXED := -I../../../Subprojects/PEPObjCTypes/PEPObjCTypes/PublicHeaders/
PEP_OBJC_TYPE_UTILS_HEADER_DIRS_PREFIXED := -I../../../Subprojects/PEPObjCTypeUtils/PEPObjCTypeUtils/PublicHeaders/
PEP_OBJC_ADAPTER_PROTOCOLS_HEADER_DIRS_PREFIXED := -I../../../Subprojects/PEPObjCAdapterProtocols/PEPObjCAdapterProtocols/PublicHeaders/
PEP_OBJC_ADAPTER_HEADER_DIRS_PREFIXED := $(shell find ../../../pEpObjCAdapter/ -type d | sed -e 's/^/-I/;')
CLIENT_OF_OBJC_ADAPTER_HEADER_DIRS_PREFIXED := $(shell find ../ -type d | sed -e 's/^/-I/;')

ClientOfObjcAdapter_INCLUDE_DIRS = ${CLIENT_OF_OBJC_ADAPTER_HEADER_DIRS_PREFIXED} ${PEP_OBJC_TYPES_HEADER_DIRS_PREFIXED} ${PEP_OBJC_TYPE_UTILS_HEADER_DIRS_PREFIXED} ${PEP_OBJC_ADAPTER_PROTOCOLS_HEADER_DIRS_PREFIXED} ${PEP_OBJC_ADAPTER_HEADER_DIRS_PREFIXED}

# SRC Files
ALL_DOT_M_FILES := $(shell find . -type f -name "*.m")
ClientOfObjcAdapter_OBJC_FILES = main.m

ClientOfObjcAdapter_RESOURCE_FILES =

ADDITIONAL_OBJCFLAGS += -include-pch PEPObjCGNUStepOptimizations.h.gch -Winvalid-pch
ADDITIONAL_FLAGS += -fobjc-runtime=gnustep-2.0 -fobjc-arc

## Linking Libs - Take Care !! The Order *DOES* Matter
ADDITIONAL_OBJC_LIBS = 	-ldispatch \
-l/usr/GNUstep/Local/Library/Libraries/libpEpObjCAdapter.so \
-l/usr/GNUstep/Local/Library/Libraries/libpEpObjCAdapterProtocols.a \
-l/usr/GNUstep/Local/Library/Libraries/libpEpObjCTypeUtils.a\
-l/usr/GNUstep/Local/Library/Libraries/libpEpObjCTypes.a \
-l${HOME}/local/lib/libpEpEngine.a \
-luuid \
-lz \
-l${HOME}/local/lib/libetpan.a \
-l${HOME}/local/lib/libasn1.a \
-l${HOME}/local/lib/libsqlite3.a \
-lpthread \
-ldl \
-l${HOME}/local/lib/libsequoia_openpgp_ffi.a \
-l${HOME}/local/lib/libhogweed.a \
-l${HOME}/local/lib/libnettle.a \
-l${HOME}/local/lib/libgmp.a

# -l/usr/GNUstep/Local/Library/Libraries/libpEpObjCAdapter.a\

ADDITIONAL_LDFLAGS += -L/usr/GNUstep/Local/Library/Libraries

include $(GNUSTEP_MAKEFILES)/tool.make
