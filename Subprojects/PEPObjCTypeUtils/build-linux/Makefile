# Content of this library
TARGET = libPEPObjCTypeUtils
OBJECTS = $(call find-objects,../src)
DEPFILES = $(call find-deps,../src)
HEADERS = $(call find-headers,../PublicHeaders)

# Dependencies *within* this repo (other headers should be installed and found in $PREFIX).
# PEP_INCLUDE is the pEp/ folder (since we don't prefix headers here), PEP_SRC
# is the engine source directory, since we may use uninstalled headers.
INCLUDES = \
  -I$(PEP_INCLUDE) \
  $(call find-includes,..)

# Load the shared pEp ObjC Makefile.
MAKEFILE_COMMON ?= ../../../../pepgnustephelper/
include $(MAKEFILE_COMMON)/Makefile.common

# This enables proper header-dependencies based on .d files made by the compiler.
include $(DEPFILES)
