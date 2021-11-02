#
# An example GNUmakefile
#
# To Run: `make messages=yes
# Include the common variables defined by the Makefile Package
include $(GNUSTEP_MAKEFILES)/common.make
#include $(GNUSTEP_MAKEFILES)/rules.make

#######################################
# Sampel Excecutable Using PEPObjCAdapter
#######################################

TOOL_NAME = ClientOfObjcAdapter

ClientOfObjcAdapter_OBJC_FILES = main.m 


ClientOfObjcAdapter_RESOURCE_FILES =

ADDITIONAL_OBJCFLAGS += -include-pch obj/ClientOfObjcAdapter.obj/PrecompiledHeaders/ObjC/PEPObjCGNUStepOptimizations.h.gch -Winvalid-pch
ADDITIONAL_FLAGS += -fobjc-runtime=gnustep-2.0 -fobjc-arc

ADDITIONAL_OBJC_LIBS = 	-ldispatch

include $(GNUSTEP_MAKEFILES)/tool.make
