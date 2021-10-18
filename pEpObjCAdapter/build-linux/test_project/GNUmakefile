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

TOOL_NAME = ClientOfObjcAdapter
#SHELL_RESULT := $(shell export LDFLAGS="${LDFLAGS} -ObjC")
#ALL_LDFLAGS += -ObjC
#LDFLAGS += -ObjC

ClientOfObjcAdapter_OBJC_PRECOMPILED_HEADERS = PEPObjCGNUStepOptimizations.h

PEP_OBJC_TYPES_HEADER_DIRS_PREFIXED := -I../../../Subprojects/PEPObjCTypes/PEPObjCTypes/PublicHeaders/
PEP_OBJC_TYPE_UTILS_HEADER_DIRS_PREFIXED := -I../../../Subprojects/PEPObjCTypeUtils/PEPObjCTypeUtils/PublicHeaders/
PEP_OBJC_ADAPTER_PROTOCOLS_HEADER_DIRS_PREFIXED := -I../../../Subprojects/PEPObjCAdapterProtocols/PEPObjCAdapterProtocols/PublicHeaders/
PEP_OBJC_ADAPTER_HEADER_DIRS_PREFIXED := $(shell find ../../../pEpObjCAdapter/ -type d | sed -e 's/^/-I/;')
CLIENT_OF_OBJC_ADAPTER_HEADER_DIRS_PREFIXED := $(shell find ../ -type d | sed -e 's/^/-I/;')

ClientOfObjcAdapter_INCLUDE_DIRS = ${CLIENT_OF_OBJC_ADAPTER_HEADER_DIRS_PREFIXED} ${PEP_OBJC_TYPES_HEADER_DIRS_PREFIXED} ${PEP_OBJC_TYPE_UTILS_HEADER_DIRS_PREFIXED} ${PEP_OBJC_ADAPTER_PROTOCOLS_HEADER_DIRS_PREFIXED} ${PEP_OBJC_ADAPTER_HEADER_DIRS_PREFIXED}


# Use this and comment out ADDITIONAL_OBJCFLAGS to build PCH
#ClientOfObjcAdapter_OBJC_FILES = MyClass.m
ClientOfObjcAdapter_OBJC_FILES = main.m MyClass.m StreamRunLoop.m Connector.m HTTPClient.m 
#../../../Subprojects/PEPObjCTypeUtils/PEPObjCTypeUtils/PEPIdentity+Engine.m

ClientOfObjcAdapter_RESOURCE_FILES =

ADDITIONAL_OBJCFLAGS += -include-pch obj/ClientOfObjcAdapter.obj/PrecompiledHeaders/ObjC/PEPObjCGNUStepOptimizations.h.gch -Winvalid-pch
ADDITIONAL_FLAGS += -fobjc-runtime=gnustep-2.0 -fobjc-arc

## Linking Libs - Take Care !! The Order *DOES* Matter
ADDITIONAL_OBJC_LIBS = 	-ldispatch \
-l/home/user/projects/pEp/IPS-5_ObjCAdapter/pEpObjCAdapter/pEpObjCAdapter/build-linux/obj/libpEpObjCAdapter.a\
-l/usr/GNUstep/Local/Library/Libraries/libpEpObjCAdapterProtocols.a \
-l/usr/GNUstep/Local/Library/Libraries/libpEpObjCTypeUtils.a -ObjC\
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


# Commented due to GNUstep bug. ADDITIONAL_LDFLAGS are actually used by the compiler (instead of linker) which causes the compiler to be confused (lags ignored warning results)
ADDITIONAL_LDFLAGS += -ObjC

include $(GNUSTEP_MAKEFILES)/tool.make
