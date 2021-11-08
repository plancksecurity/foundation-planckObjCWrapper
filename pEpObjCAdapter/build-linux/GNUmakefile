#
# Dox: http://www.gnustep.org/resources/documentation/make_1.html
#
# To Run: `make messages=yes shared=no debug=yes
#

# Include the common variables defined by the Makefile Package
include $(GNUSTEP_MAKEFILES)/common.make

# Build PEPObjCTypeUtils
SHELL_RESULT := $(shell ./buildPEPObjCTypeUtils.sh)
SHELL_RESULT := $(shell ./buildPEPObjCAdapterProtocols.sh)

LIBRARY_NAME = pEpObjCAdapter

pEpObjCAdapter_OBJC_PRECOMPILED_HEADERS = PEPObjCGNUStepOptimizations.h

#Finds all dirs containing headers and prefixes with "-I"
ALL_LOCAL_INCLUDE_HEADER_DIRS_PREFIXED := $(shell find ~/local/include/ -type d | sed -e 's/^/-I/;')
PEP_OBJC_TYPES_HEADER_DIRS_PREFIXED := -I../../Subprojects/PEPObjCTypes/PEPObjCTypes/PublicHeaders/
PEP_OBJC_TYPE_UTILS_HEADER_DIRS_PREFIXED := -I../../Subprojects/PEPObjCTypeUtils/PEPObjCTypeUtils/PublicHeaders/
PEP_OBJC_ADAPTER_PROTOCOLS_HEADER_DIRS_PREFIXED := -I../../Subprojects/PEPObjCAdapterProtocols/PEPObjCAdapterProtocols/PublicHeaders/

PEP_OBJC_ADAPTER_HEADER_DIRS_PREFIXED := $(shell find ../../pEpObjCAdapter/ -type d | sed -e 's/^/-I/;')
$(shell echo "PEP_OBJC_ADAPTER_HEADER_DIRS_PREFIXED: $PEP_OBJC_ADAPTER_HEADER_DIRS_PREFIXED")

pEpObjCAdapter_INCLUDE_DIRS = ${PEP_OBJC_ADAPTER_HEADER_DIRS_PREFIXED} ${ALL_LOCAL_INCLUDE_HEADER_DIRS_PREFIXED} ${PEP_OBJC_TYPES_HEADER_DIRS_PREFIXED} ${PEP_OBJC_TYPE_UTILS_HEADER_DIRS_PREFIXED} ${PEP_OBJC_ADAPTER_PROTOCOLS_HEADER_DIRS_PREFIXED}
ALL_DOT_M_FILES := $(shell find ../ -type f -name "*.m")
pEpObjCAdapter_OBJC_FILES = ${ALL_DOT_M_FILES}
pEpObjCAdapter_RESOURCE_FILES =

pEpObjCAdapter_LDFLAGS = -objc -ObjC ../../Subprojects/PEPObjCTypes/PEPObjCTypes/build-linux/build/libpEpObjCTypes.a ../../Subprojects/PEPObjCTypeUtils/PEPObjCTypeUtils/build-linux/build/libpEpObjCTypeUtils.a ../../Subprojects/PEPObjCAdapterProtocols/PEPObjCAdapterProtocols/build-linux/build/libpEpObjCAdapterProtocols.a

ADDITIONAL_OBJCFLAGS += -include-pch obj/pEpObjCAdapter.obj/PrecompiledHeaders/ObjC/PEPObjCGNUStepOptimizations.h.gch -Winvalid-pch
ADDITIONAL_OBJC_LIBS = -ldispatch
ADDITIONAL_FLAGS = -fobjc-runtime=gnustep-2.0 -fobjc-arc -fPIC -g -O0

HEADER_FILES_INSTALL_DIR = build

# For lib
include $(GNUSTEP_MAKEFILES)/library.make

# Copy Artefacts
SHELL_RESULT := $(shell mkdir -p build)
SHELL_RESULT := $(shell cp obj/*.a build/)
