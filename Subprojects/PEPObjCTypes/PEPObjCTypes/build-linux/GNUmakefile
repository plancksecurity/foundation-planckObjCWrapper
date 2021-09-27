#
# Dox: http://www.gnustep.org/resources/documentation/make_1.html
#
# To Run: `make messages=yes shared=no
#

# Include the common variables defined by the Makefile Package
include $(GNUSTEP_MAKEFILES)/common.make

# Build pre-compiled prefix header
SHELL_RESULT := $(shell ./prepare.sh)

LIBRARY_NAME = pEpObjCTypes
# Finds all dirs in src and prefixes with "-I"
ALL_PRIVATE_HEADER_DIRS_PREFIXED := $(shell find ../src/ -type d | sed -e 's/^/-I/;')
pEpObjCTypes_INCLUDE_DIRS = -I../PublicHeaders/ ${ALL_PRIVATE_HEADER_DIRS_PREFIXED}

ALL_DOT_M_FILES := $(shell find ../src/ -type f | grep .m)
pEpObjCTypes_OBJC_FILES = ${ALL_DOT_M_FILES}
pEpObjCTypes_RESOURCE_FILES =

ADDITIONAL_OBJCFLAGS += -include-pch PEPObjCGNUStepOptimizations.h.gch -Winvalid-pch
ADDITIONAL_OBJC_LIBS = -ldispatch
ADDITIONAL_FLAGS = -fobjc-runtime=gnustep-2.0 -fobjc-arc -fPIC

HEADER_FILES_INSTALL_DIR=build

# For lib
include $(GNUSTEP_MAKEFILES)/library.make
