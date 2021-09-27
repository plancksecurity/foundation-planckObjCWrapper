#
# Dox: http://www.gnustep.org/resources/documentation/make_1.html
#
# To Run: `make messages=yes shared=no
#

# Include the common variables defined by the Makefile Package
include $(GNUSTEP_MAKEFILES)/common.make

# Build precompiled prefix header
#$(shell cat PEPTypes.h)
# files := $(shell echo *.h)
# needless := $(shell prepare.sh)


#echo About to make distribution


# For Excecutable
#TOOL_NAME = pEpObjCTypes
# FOr Lib
LIBRARY_NAME = pEpObjCTypes

#pEpObjCTypes_HEADER_FILES_DIR = ../PublicHeaders/
pEpObjCTypes_HEADERS = TEST.h PEPAttachment.h

pEpObjCTypes_OBJC_FILES = TEST.m PEPAttachment.m

pEpObjCTypes_RESOURCE_FILES =

# Precompiles header. But would have to be in extra rule. The ADDITIONAL_OBJCFLAGS iclude otherwize fails due to pch not buildand thus not existing yet.
# Keep it. Its great to copy the command used to prepare.sh !
#pEpObjCTypes_OBJC_PRECOMPILED_HEADERS = PEPObjCGNUStepOptimizations.h

ADDITIONAL_OBJCFLAGS += -include-pch PEPObjCGNUStepOptimizations.h.gch -Winvalid-pch

ADDITIONAL_OBJC_LIBS = -ldispatch
ADDITIONAL_FLAGS = -fobjc-runtime=gnustep-2.0 -fobjc-arc

#HEADER_FILES_INSTALL_DIR=build



# The C source files to be compiled
#libone_C_FILES = parse.c

# For lib
include $(GNUSTEP_MAKEFILES)/library.make

# For Excecutable
include $(GNUSTEP_MAKEFILES)/tool.make
