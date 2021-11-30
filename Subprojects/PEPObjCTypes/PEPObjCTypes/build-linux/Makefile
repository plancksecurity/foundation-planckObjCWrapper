
OBJECTS := $(patsubst %.m,%.o,$(wildcard ../src/*.m))
DEPFILES := $(wildcard ../src/*.d)
HEADERS := $(wildcard ../PublicHeaders/*.h)
TARGET = libPEPObjCTypes

include ../../../../Makefile.common
include $(DEPFILES)
