# Content of this library
TARGET = libPEPObjCTypes
OBJECTS = $(call find-objects,../src)
DEPFILES = $(call find-deps,../src)
HEADERS = $(call find-headers,../PublicHeaders/)

# Dependencies *within* this repo (other headers should be installed and found in $PREFIX).
INCLUDES = \
  $(call find-includes,..)

# Load the shared pEp ObjC Makefile.
MAKEFILE_COMMON ?= ../../../../pepgnustephelper/
include $(MAKEFILE_COMMON)/Makefile.common

# This enables proper header-dependencies based on .d files made by the compiler.
include $(DEPFILES)
