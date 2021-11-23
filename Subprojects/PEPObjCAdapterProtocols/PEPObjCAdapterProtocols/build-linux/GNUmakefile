#
# Dox: http://www.gnustep.org/resources/documentation/make_1.html
#
# To Run: `make install messages=yes shared=no debug=yes
#

# Include the common variables defined by the Makefile Package
include $(GNUSTEP_MAKEFILES)/common.make

LIBRARY_NAME = pEpObjCAdapterProtocols

# Build pre-compiled prefix header
GNUSTEPHELPER_DIR=../../../../../pepgnustephelper
FLAGS_FOR_PRECOMPILED_HEADER_DEBUG="-MMD -MP -DGNUSTEP -DGNUSTEP_BASE_LIBRARY=1 -DGNU_GUI_LIBRARY=1 -DGNUSTEP_RUNTIME=1 -D_NONFRAGILE_ABI=1 -DGNUSTEP_BASE_LIBRARY=1 -I./obj/pEpObjCTypes.obj/PrecompiledHeaders/ObjC -fno-strict-aliasing -fexceptions -fobjc-exceptions -D_NATIVE_OBJC_EXCEPTIONS -fobjc-runtime=gnustep-2.0 -fobjc-arc -fPIC -g -fblocks -fobjc-runtime=gnustep-2.0 -fblocks -fconstant-string-class=NSConstantString -I../PublicHeaders/ -I../src/ -I../src/PEPEqualableTools -I. -I/home/user/GNUstep/Library/Headers -I/usr/GNUstep/Local/Library/Headers -I/usr/GNUstep/System/Library/Headers -I/usr/GNUstep/Local/Library/Headers -I/usr/GNUstep/Local/Library/Headers -I/usr/GNUstep/System/Library/Headers -I/usr/GNUstep/System/Library/Headers -fblocks -x objective-c -I/usr/include/libxml2 -I/usr/include/libxml2 -I/usr/include/p11-kit-1"
FLAGS_FOR_PRECOMPILED_HEADER_RELEASE="-MMD -MP -DGNUSTEP -DGNUSTEP_BASE_LIBRARY=1 -DGNU_GUI_LIBRARY=1 -DGNUSTEP_RUNTIME=1 -D_NONFRAGILE_ABI=1 -DGNUSTEP_BASE_LIBRARY=1 -I./obj/pEpObjCTypes.obj/PrecompiledHeaders/ObjC -fno-strict-aliasing -fexceptions -fobjc-exceptions -D_NATIVE_OBJC_EXCEPTIONS -fobjc-runtime=gnustep-2.0 -fobjc-arc -fPIC -g -O2 -fblocks -fobjc-runtime=gnustep-2.0 -fblocks -fconstant-string-class=NSConstantString -I../PublicHeaders/ -I../src/ -I../src/PEPEqualableTools -I. -I/home/user/GNUstep/Library/Headers -I/usr/GNUstep/Local/Library/Headers -I/usr/GNUstep/System/Library/Headers -I/usr/GNUstep/Local/Library/Headers -I/usr/GNUstep/Local/Library/Headers -I/usr/GNUstep/System/Library/Headers -I/usr/GNUstep/System/Library/Headers -fblocks -x objective-c -I/usr/include/libxml2 -I/usr/include/libxml2 -I/usr/include/p11-kit-1"
ifeq ($(debug), yes)
    FLAGS_FOR_PRECOMPILED_HEADER = ${FLAGS_FOR_PRECOMPILED_HEADER_DEBUG}
else
    FLAGS_FOR_PRECOMPILED_HEADER = ${FLAGS_FOR_PRECOMPILED_HEADER_RELEASE}
endif
SHELL_RESULT := $(shell ${GNUSTEPHELPER_DIR}/build-precompiled-header.sh ${FLAGS_FOR_PRECOMPILED_HEADER})

# Header Search Paths
PEP_OBJC_TYPES_HEADER_DIRS_PREFIXED := -I../../../PEPObjCTypes/PEPObjCTypes/PublicHeaders/
pEpObjCAdapterProtocols_INCLUDE_DIRS = -I../PublicHeaders/ ${PEP_OBJC_TYPES_HEADER_DIRS_PREFIXED}

# SRC Files
ALL_DOT_M_FILES := $(shell find ../ -type f -name "*.m")
pEpObjCAdapterProtocols_OBJC_FILES = ${ALL_DOT_M_FILES}
pEpObjCAdapterProtocols_RESOURCE_FILES =

# Build Settings
ADDITIONAL_OBJCFLAGS += -include-pch PEPObjCGNUStepOptimizations.h.gch -Winvalid-pch
ADDITIONAL_OBJC_LIBS = -ldispatch
ADDITIONAL_FLAGS = -fobjc-runtime=gnustep-2.0 -fobjc-arc -fPIC

pEpObjCAdapterProtocols_HEADER_FILES_INSTALL_DIR = build/include

# For lib
include $(GNUSTEP_MAKEFILES)/library.make

# Copy Artefacts
SHELL_RESULT := $(shell mkdir -p build)
SHELL_RESULT := $(shell cp obj/*.a build/)
