# Content of this library
TARGET = libpEpObjCAdapter
# Can't use find-objects here since that would search the entire repo.
OBJECTS = $(patsubst %.m,%.o,$(wildcard ../*.m ../*/*.m))
DEPFILES = $(call find-deps,..)
HEADERS = $(call find-headers,../PublicHeaders/)

# Dependencies *within* this repo (other headers should be installed and found in $PREFIX).
INCLUDES = \
  $(call find-includes,../PublicHeaders) \
  $(call find-includes,../src) \
  -I$(PEP_INCLUDE)

# Only for making .so libs. Libs for static linking are defined with the final binary.
LIBS = -lpEpEngine -Wl,--whole-archive -lPEPObjCTypes -lPEPObjCTypeUtils -lPEPObjCAdapterProtocols -Wl,--no-whole-archive

# Load the shared pEp ObjC Makefile.
MAKEFILE_COMMON ?= ../../pepgnustephelper
include $(MAKEFILE_COMMON)/Makefile.common

# This enables proper header-dependencies based on .d files made by the compiler.
include $(DEPFILES)
