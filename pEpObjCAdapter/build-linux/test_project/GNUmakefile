#
# An example GNUmakefile
#

# Include the common variables defined by the Makefile Package
include $(GNUSTEP_MAKEFILES)/common.make

#######################################
# Sampel Excecutable Using PEPObjCAdapter
#######################################

TOOL_NAME = ClientOfObjcAdapter

HelloWorld_OBJC_PRECOMPILED_HEADERS = PEPObjCGNUStepOptimizations.h

PEP_OBJC_TYPES_HEADER_DIRS_PREFIXED := -I../../../Subprojects/PEPObjCTypes/PEPObjCTypes/PublicHeaders/
PEP_OBJC_TYPE_UTILS_HEADER_DIRS_PREFIXED := -I../../../Subprojects/PEPObjCTypeUtils/PEPObjCTypeUtils/PublicHeaders/
PEP_OBJC_ADAPTER_PROTOCOLS_HEADER_DIRS_PREFIXED := -I../../../Subprojects/PEPObjCAdapterProtocols/PEPObjCAdapterProtocols/PublicHeaders/
PEP_OBJC_ADAPTER_HEADER_DIRS_PREFIXED := $(shell find ../../../pEpObjCAdapter/ -type d | sed -e 's/^/-I/;')
CLIENT_OF_OBJC_ADAPTER_HEADER_DIRS_PREFIXED := $(shell find ../ -type d | sed -e 's/^/-I/;')

ClientOfObjcAdapter_INCLUDE_DIRS = ${CLIENT_OF_OBJC_ADAPTER_HEADER_DIRS_PREFIXED} ${PEP_OBJC_TYPES_HEADER_DIRS_PREFIXED} ${PEP_OBJC_TYPE_UTILS_HEADER_DIRS_PREFIXED} ${PEP_OBJC_ADAPTER_PROTOCOLS_HEADER_DIRS_PREFIXED} ${PEP_OBJC_ADAPTER_HEADER_DIRS_PREFIXED}

# Use this and comment out ADDITIONAL_OBJCFLAGS to build PCH
#ClientOfObjcAdapter_OBJC_FILES = MyClass.m
ClientOfObjcAdapter_OBJC_FILES = main.m MyClass.m StreamRunLoop.m Connector.m HTTPClient.m

ClientOfObjcAdapter_RESOURCE_FILES =

# ClientOfObjcAdapter_LDFLAGS = ../build/libpEpObjCAdapter.a
#ClientOfObjcAdapter_LDFLAGS = -l/usr/GNUstep/Local/Library/Libraries/libpEpObjCAdapter.a -l/usr/GNUstep/Local/Library/Libraries/libpEpObjCAdapterProtocols.a -l/usr/GNUstep/Local/Library/Libraries/libpEpObjCTypeUtils.a -l/usr/GNUstep/Local/Library/Libraries/libpEpObjCTypes.a

ADDITIONAL_OBJCFLAGS += -include-pch obj/HelloWorld.obj/PrecompiledHeaders/ObjC/PEPObjCGNUStepOptimizations.h.gch -Winvalid-pch

## Linking Libs - Take Care !! The Order *DOES* Matter
ADDITIONAL_OBJC_LIBS = -ldispatch \
-l/usr/GNUstep/Local/Library/Libraries/libpEpObjCAdapter.a \
-l/usr/GNUstep/Local/Library/Libraries/libpEpObjCAdapterProtocols.a \
-l/usr/GNUstep/Local/Library/Libraries/libpEpObjCTypeUtils.a \
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









ADDITIONAL_FLAGS = -fobjc-runtime=gnustep-2.0 -fobjc-arc


include $(GNUSTEP_MAKEFILES)/tool.make
