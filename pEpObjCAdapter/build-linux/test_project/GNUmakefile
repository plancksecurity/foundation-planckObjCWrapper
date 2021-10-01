#
# An example GNUmakefile
#

# Include the common variables defined by the Makefile Package
include $(GNUSTEP_MAKEFILES)/common.make

#######################################
# HelloWorld
#######################################

# Build pre-compiled prefix header
# SHELL_RESULT := $(shell ../../../Subprojects/PEPObjCTypes/PEPObjCTypes/build-linux/prepare.sh)

TOOL_NAME = HelloWorld

HelloWorld_OBJC_PRECOMPILED_HEADERS = PEPObjCGNUStepOptimizations.h

PEP_OBJC_TYPES_HEADER_DIRS_PREFIXED := -I../../../Subprojects/PEPObjCTypes/PEPObjCTypes/PublicHeaders/
PEP_OBJC_TYPE_UTILS_HEADER_DIRS_PREFIXED := -I../../../Subprojects/PEPObjCTypeUtils/PEPObjCTypeUtils/PublicHeaders/
PEP_OBJC_ADAPTER_PROTOCOLS_HEADER_DIRS_PREFIXED := -I../../../Subprojects/PEPObjCAdapterProtocols/PEPObjCAdapterProtocols/PublicHeaders/
PEP_OBJC_ADAPTER_HEADER_DIRS_PREFIXED := $(shell find ../../../pEpObjCAdapter/ -type d | sed -e 's/^/-I/;')
HELLO_WORLS_HEADER_DIRS_PREFIXED := $(shell find ../ -type d | sed -e 's/^/-I/;')

HelloWorld_INCLUDE_DIRS = ${HELLO_WORLS_HEADER_DIRS_PREFIXED} ${PEP_OBJC_TYPES_HEADER_DIRS_PREFIXED} ${PEP_OBJC_TYPE_UTILS_HEADER_DIRS_PREFIXED} ${PEP_OBJC_ADAPTER_PROTOCOLS_HEADER_DIRS_PREFIXED} ${PEP_OBJC_ADAPTER_HEADER_DIRS_PREFIXED}

#HelloWorld_HEADERS = MyClass.h StreamRunLoop.h Connector.h HTTPClient.h
HelloWorld_OBJC_FILES = main.m MyClass.m StreamRunLoop.m Connector.m HTTPClient.m
HelloWorld_RESOURCE_FILES =

HelloWorld_LDFLAGS = ../build/libpEpObjCAdapter.a

ADDITIONAL_OBJCFLAGS += -include-pch obj/HelloWorld.obj/PrecompiledHeaders/ObjC/PEPObjCGNUStepOptimizations.h.gch -Winvalid-pch
ADDITIONAL_OBJC_LIBS = -ldispatch
ADDITIONAL_FLAGS = -fobjc-runtime=gnustep-2.0 -fobjc-arc


include $(GNUSTEP_MAKEFILES)/tool.make
