#
# Dox: http://www.gnustep.org/resources/documentation/make_1.html
#
# To Run: `make install messages=yes shared=no debug=yes
#

# Include the common variables defined by the Makefile Package
include $(GNUSTEP_MAKEFILES)/common.make

# Build Dependencies ...
SHELL_RESULT := $(shell ./build-PEPObjCTypes.sh)
SHELL_RESULT := $(shell ./build-gmp.sh)
SHELL_RESULT := $(shell ./build-nettle.sh)

# Build pre-compiled prefix header
#SHELL_RESULT := $(shell ../../../PEPObjCTypes/PEPObjCTypes/build-linux/prepare.sh)

# Finds all dirs containing headers and prefixes with "-I"
ALL_LOCAL_INCLUDE_HEADER_DIRS_PREFIXED := $(shell find ~/local/include/ -type d | sed -e 's/^/-I/;')
PEP_OBJC_TYPES_HEADER_DIRS_PREFIXED := $(shell find ../../../PEPObjCTypes/PEPObjCTypes/PublicHeaders/ -type d | sed -e 's/^/-I/;')
LIBRARY_NAME = pEpObjCTypeUtils
pEpObjCTypeUtils_INCLUDE_DIRS = -I../PublicHeaders/ ${ALL_LOCAL_INCLUDE_HEADER_DIRS_PREFIXED} ${PEP_OBJC_TYPES_HEADER_DIRS_PREFIXED}

ALL_DOT_M_FILES := $(shell find ../ -maxdepth 1 -type f -name "*.m")
pEpObjCTypeUtils_OBJC_FILES = ${ALL_DOT_M_FILES}
pEpObjCTypeUtils_RESOURCE_FILES =

ADDITIONAL_OBJCFLAGS += -include-pch PEPObjCGNUStepOptimizations.h.gch -Winvalid-pch
ADDITIONAL_OBJC_LIBS = -ldispatch
ADDITIONAL_FLAGS = -fobjc-runtime=gnustep-2.0 -fobjc-arc -fPIC

HEADER_FILES_INSTALL_DIR = build

# For lib
include $(GNUSTEP_MAKEFILES)/library.make

# Copy Artefacts
SHELL_RESULT := $(shell mkdir -p build)
SHELL_RESULT := $(shell cp obj/*.a build/)
