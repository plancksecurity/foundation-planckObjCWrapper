# Build precompiled prefix header 

SCRIPT_DIR=$(dirname "$0")
CURRENT_DIR=$(pwd)
cd ${SCRIPT_DIR}
SCRIPT_DIR=$(pwd)
cd ${CURRENT_DIR}


clang -x objective-c-header ${SCRIPT_DIR}/PEPObjCGNUStepOptimizations.h -c -fPIC -MMD -MP -DGNUSTEP -DGNUSTEP_BASE_LIBRARY=1 -DGNU_GUI_LIBRARY=1 -DGNUSTEP_RUNTIME=1 -D_NONFRAGILE_ABI=1 -DGNUSTEP_BASE_LIBRARY=1 -I./obj/pEpObjCTypes.obj/PrecompiledHeaders/ObjC -fno-strict-aliasing -fexceptions -fobjc-exceptions -D_NATIVE_OBJC_EXCEPTIONS -fobjc-runtime=gnustep-2.0 -fobjc-arc -g -O2 -fblocks -fobjc-runtime=gnustep-2.0 -fblocks -fconstant-string-class=NSConstantString -I. -I/home/user/GNUstep/Library/Headers -I/usr/GNUstep/Local/Library/Headers -I/usr/GNUstep/System/Library/Headers -I/usr/GNUstep/Local/Library/Headers -I/usr/GNUstep/Local/Library/Headers -I/usr/GNUstep/System/Library/Headers -I/usr/GNUstep/System/Library/Headers -fblocks -x objective-c -I/usr/include/libxml2 -I/usr/include/libxml2 -I/usr/include/p11-kit-1 -o PEPObjCGNUStepOptimizations.h.gch