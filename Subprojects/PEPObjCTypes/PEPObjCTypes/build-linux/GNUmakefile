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

#pEpObjCTypes_HEADER_FILES_DIR = ../PublicHeaders/
pEpObjCTypes_HEADERS = TEST.h PEPAttachment.h

pEpObjCTypes_OBJC_FILES = TEST.m PEPAttachment.m

pEpObjCTypes_RESOURCE_FILES =

ADDITIONAL_OBJCFLAGS += -include-pch PEPObjCGNUStepOptimizations.h.gch -Winvalid-pch

ADDITIONAL_OBJC_LIBS = -ldispatch
ADDITIONAL_FLAGS = -fobjc-runtime=gnustep-2.0 -fobjc-arc

#HEADER_FILES_INSTALL_DIR=build

# For lib
include $(GNUSTEP_MAKEFILES)/library.make
