root = ../../../

# Content of this library
TARGET_EXE = test_project
OBJECTS = $(call find-objects,.)
DEPFILES = $(call find-deps,.)
HEADERS =

# Dependencies *within* this repo (other headers should be installed and found in $PREFIX).
INCLUDES = \
  -I$(root)/pEpObjCAdapter/PublicHeaders

# Since we link an excecuatble here, these options matter a lot. We also need
# to list all transitive dependincies if we want to link statically.
# ObjC stuff needs to be linked with --whole-archive to mae Extensions work.
# Otherwise, we link "our" dependencies with -Bstatic to perfer static linking,
# but allow dynamic linking in the end for system stuff.
LIBS = \
  -Wl,-Bstatic \
    -Wl,--whole-archive \
      -lpEpObjCAdapter \
      -lPEPObjCTypes \
      -lPEPObjCTypeUtils \
      -lPEPObjCAdapterProtocols \
    -Wl,--no-whole-archive \
    -lpEpEngine -lasn1 -lsqlite3 -letpan -liconv -luuid \
    -lsequoia_openpgp_ffi -lhogweed -lnettle -lgmp -lbz2 \
  -Wl,-Bdynamic \
  -ldl # dlsym is needed by some rust thing in sequoia.

# Default rule, to build the executable instead of libraries.
all: $(TARGET_EXE)

# Load the shared pEp ObjC Makefile.
MAKEFILE_COMMON ?= ../../../../pepgnustephelper/
include $(MAKEFILE_COMMON)/Makefile.common

# This enables proper header-dependencies based on .d files made by the compiler.
include $(DEPFILES)
