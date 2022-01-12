root = ../../../../

# Content of this library
TARGET = libPEPObjCTypeUtils
OBJECTS = $(call find-objects,..)
DEPFILES = $(call find-deps,..)
HEADERS = $(call find-headers,../PublicHeaders)

# Dependencies *within* this repo (other headers should be installed and found in $PREFIX).
# PEP_INCLUDE is the pEp/ folder (since we don't prefix headers here), PEP_SRC
# is the engine source directory, since we may use uninstalled headers.
INCLUDES = \
  -I$(PEP_INCLUDE) \
  $(call find-includes,..)


# Only for making .so libs. Libs for static linking are defined with the final binary.
LIBS = -lpEpEngine -lasn1 -lPEPObjCTypes

# Load the shared pEp ObjC Makefile.
MAKEFILE_COMMON ?= ../../../../pepgnustephelper/
include $(MAKEFILE_COMMON)/Makefile.common

print:
	echo $(OBJECTS)

# This enables proper header-dependencies based on .d files made by the compiler.
include $(DEPFILES)
