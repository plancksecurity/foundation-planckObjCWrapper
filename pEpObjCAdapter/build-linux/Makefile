root = ../../

# Content of this library
TARGET = libpEpObjCAdapter
OBJECTS := $(patsubst %.m,%.o,$(wildcard ../*.m ../*/*.m))
DEPFILES := $(wildcard ../*.d)
HEADERS := $(wildcard ../PublicHeaders/*.h)

# Dependencies *within* this repo (other headers should be installed and found in $PREFIX).
INCLUDES = \
  -I$(root)/pEpObjCAdapter/PublicHeaders \
  -I$(root)/pEpObjCAdapter/Extensions \
  -I$(root)/pEpObjCAdapter \
  -I$(root)/Subprojects/PEPObjCAdapterProtocols/PEPObjCAdapterProtocols/PublicHeaders \
  -I$(root)/Subprojects/PEPObjCTypes/PEPObjCTypes/PublicHeaders \
  -I$(root)/Subprojects/PEPObjCTypeUtils/PEPObjCTypeUtils/PublicHeaders \
  -I$(PEP_INCLUDE)

# Only for making .so libs. Libs for static linking are defined with the final binary.
LIBS = -lpEpEngine -Wl,--whole-archive -lPEPObjCTypes -lPEPObjCTypeUtils -lPEPObjCAdapterProtocols -Wl,--no-whole-archive

# Load the shared pEp ObjC Makefile.
MAKEFILE_COMMON ?= ../../../pepgnustephelper/
include $(MAKEFILE_COMMON)/Makefile.common

# This enables proper header-dependencies based on .d files made by the compiler.
include $(DEPFILES)
