#
# An example GNUmakefile
#

# Include the common variables defined by the Makefile Package
include $(GNUSTEP_MAKEFILES)/common.make

TOOL_NAME = HelloWorld
HelloWorld_HEADERS = MyClass.h StreamRunLoop.h Connector.h HTTPClient.h
HelloWorld_OBJC_FILES = main.m MyClass.m StreamRunLoop.m Connector.m HTTPClient.m
HelloWorld_RESOURCE_FILES =

HelloWorld_LDFLAGS = 

ADDITIONAL_OBJC_LIBS = -ldispatch
ADDITIONAL_FLAGS = -fobjc-runtime=gnustep-2.0 -fobjc-arc

include $(GNUSTEP_MAKEFILES)/tool.make
