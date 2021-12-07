root = ../../../../

# Content of this library
TARGET = libPEPObjCTypeUtils
OBJECTS := $(patsubst %.m,%.o,$(wildcard ../*.m))
DEPFILES := $(wildcard ../*.d)
HEADERS := $(wildcard ../PublicHeaders/*.h)

# Dependencies *within* this repo (other headers should be installed and found in $PREFIX).
# PEP_INCLUDE is the pEp/ folder (since we don't prefix headers here), PEP_SRC
# is the engine source directory, since we may use uninstalled headers.
INCLUDES = \
  -I../ \
  -I../PublicHeaders \
  -I$(PEP_INCLUDE) \


# Only for making .so libs. Libs for static linking are defined with the final binary.
LIBS = -lpEpEngine -lasn1 -lPEPObjCTypes

# Load the shared pEp ObjC Makefile.
MAKEFILE_COMMON ?= ../../../../../pepgnustephelper/
include $(MAKEFILE_COMMON)/Makefile.common

# This enables proper header-dependencies based on .d files made by the compiler.
include $(DEPFILES)
