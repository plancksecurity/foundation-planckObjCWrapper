
OBJECTS := $(patsubst %.m,%.o,$(wildcard ../*.m))
DEPFILES := $(wildcard ../*.d)
HEADERS := $(wildcard ../PublicHeaders/*.h)
TARGET = libPEPObjCTypeUtils
LIBS = -lpEpEngine -lasn1 

include ../../../../Makefile.common
include $(DEPFILES)
