
OBJECTS := $(patsubst %.m,%.o,$(wildcard ../*.m))
DEPFILES := $(wildcard ../*.d)
HEADERS := $(wildcard ../PublicHeaders/*.h)
TARGET = libpEpObjCAdapter

include ../../Makefile.common
include $(DEPFILES)
