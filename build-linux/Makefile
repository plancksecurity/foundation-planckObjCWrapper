root = ..

# Content of this library
TARGET = libpEpObjCAdapter
OBJECTS = $(patsubst %.m,%.o,$(wildcard ../*.m ../*/*.m))
DEPFILES = $(call find-deps,..)
HEADERS = $(call find-headers,../PublicHeaders/)

# Dependencies *within* this repo (other headers should be installed and found in $PREFIX).
INCLUDES = \
  -I$(root)/PublicHeaders \
  -I$(root)/src/Extensions \
  -I$(root)/src/TKA \
  -I$(root)/src \
  -I$(root)/Subprojects/PEPObjCAdapterProtocols/PublicHeaders \
  -I$(root)/Subprojects/PEPObjCTypes/PublicHeaders \
  -I$(root)/Subprojects/PEPObjCTypeUtils/PublicHeaders \
  -I$(PEP_INCLUDE)

# Only for making .so libs. Libs for static linking are defined with the final binary.
LIBS = -lpEpEngine -Wl,--whole-archive -lPEPObjCTypes -lPEPObjCTypeUtils -lPEPObjCAdapterProtocols -Wl,--no-whole-archive

# Load the shared pEp ObjC Makefile.
MAKEFILE_COMMON ?= ../../pepgnustephelper
include $(MAKEFILE_COMMON)/Makefile.common

# This enables proper header-dependencies based on .d files made by the compiler.
include $(DEPFILES)
