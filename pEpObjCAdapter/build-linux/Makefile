
OBJECTS := $(patsubst %.m,%.o,$(wildcard ../*.m))
DEPFILES := $(wildcard ../*.d)
HEADERS := $(wildcard ../PublicHeaders/*.h)
TARGET = libpEpObjCAdapter
LIBS = -lpEpEngine -Wl,--whole-archive -lPEPObjCTypes -lPEPObjCTypeUtils -lPEPObjCAdapterProtocols -Wl,--no-whole-archive


include ../../Makefile.common
include $(DEPFILES)
