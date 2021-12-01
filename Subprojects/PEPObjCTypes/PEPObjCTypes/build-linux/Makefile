# Content of this library
TARGET = libPEPObjCTypes
OBJECTS := $(patsubst %.m,%.o,$(wildcard ../src/*.m ../src/*/*.m))
DEPFILES := $(wildcard ..src/*.d ../src/*/*.d)
HEADERS := $(wildcard ../PublicHeaders/*.h)

# Dependencies *within* this repo (other headers should be installed and found in $PREFIX).
INCLUDES = \
  -I../PublicHeaders \
  -I../src \
  -I../src/PEPEqualableTools

# Only for making .so libs. Libs for static linking are defined with the final binary.
LIBS =

# Load the shared pEp ObjC Makefile.
MAKEFILE_COMMON ?= ../../../../../pepgnustephelper/
include $(MAKEFILE_COMMON)/Makefile.common

# This enables proper header-dependencies based on .d files made by the compiler.
include $(DEPFILES)
