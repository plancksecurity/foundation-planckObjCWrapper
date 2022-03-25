# Content of this library
TARGET = libpEpObjCAdapter
OBJECTS = $(call find-objects,../src/)
DEPFILES = $(call find-deps,..)
HEADERS = $(call find-headers,../PublicHeaders/)

# Dependencies *within* this repo (other headers should be installed and found in $PREFIX).
INCLUDES = \
  $(call find-includes,../PublicHeaders) \
  $(call find-includes,../src) \
  -I$(PEP_INCLUDE)

# Load the shared pEp ObjC Makefile.
MAKEFILE_COMMON ?= ../../pepgnustephelper
include $(MAKEFILE_COMMON)/Makefile.common

# This enables proper header-dependencies based on .d files made by the compiler.
include $(DEPFILES)
