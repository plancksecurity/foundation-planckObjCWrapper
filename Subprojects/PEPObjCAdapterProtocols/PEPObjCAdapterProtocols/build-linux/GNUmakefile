#
# Dox: http://www.gnustep.org/resources/documentation/make_1.html
#
# To Run: `make messages=yes shared=no
#

# Include the common variables defined by the Makefile Package
include $(GNUSTEP_MAKEFILES)/common.make

# Build PEPObjCTypes
SHELL_RESULT := $(shell ../../../PEPObjCTypeUtils/PEPObjCTypeUtils/build-linux/buildPEPObjCTypes.sh)

# Build pre-compiled prefix header
SHELL_RESULT := $(shell ../../../PEPObjCTypes/PEPObjCTypes/build-linux/prepare.sh)

LIBRARY_NAME = pEpObjCAdapterProtocols

PEP_OBJC_TYPES_HEADER_DIRS_PREFIXED := -I../../../PEPObjCTypes/PEPObjCTypes/PublicHeaders/
pEpObjCAdapterProtocols_INCLUDE_DIRS = -I../PublicHeaders/ ${PEP_OBJC_TYPES_HEADER_DIRS_PREFIXED}

ALL_DOT_M_FILES := $(shell find ../ -maxdepth 1 -type f -name "*.m")
pEpObjCAdapterProtocols_OBJC_FILES = ${ALL_DOT_M_FILES}
pEpObjCAdapterProtocols_RESOURCE_FILES =

ADDITIONAL_OBJCFLAGS += -include-pch PEPObjCGNUStepOptimizations.h.gch -Winvalid-pch
ADDITIONAL_OBJC_LIBS = -ldispatch
ADDITIONAL_FLAGS = -fobjc-runtime=gnustep-2.0 -fobjc-arc -fPIC

HEADER_FILES_INSTALL_DIR = build

# For lib
include $(GNUSTEP_MAKEFILES)/library.make

# Copy Artefacts
SHELL_RESULT := $(shell mkdir -p build)
SHELL_RESULT := $(shell cp obj/*.a build/)
