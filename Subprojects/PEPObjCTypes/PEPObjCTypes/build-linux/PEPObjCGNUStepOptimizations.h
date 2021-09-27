#define UNSUPPORTED_NS_CLOSED_ENUM 1
#define NO_TOOLBOX 1
#define NO_MAC_TYPES 1

#ifndef PEP_OBJC_GNUSTEP_OPTIMIZATIONS_H
#define PEP_OBJC_GNUSTEP_OPTIMIZATIONS_H

// NS_CLOSED_ENUM is too new for GNUStep ObjC. We replace it with NS_ENUM.
#ifdef UNSUPPORTED_NS_CLOSED_ENUM
#define NS_CLOSED_ENUM NS_ENUM
#endif

#endif

// Missing types originally defined in MacTypes.h
#ifndef PEP_OBJC_GNUSTEP_OPTIMIZATIONS_MAC_TYPES_H
#define PEP_OBJC_GNUSTEP_OPTIMIZATIONS_MAC_TYPES_H

#ifdef NO_MAC_TYPES
typedef long 						Size;
typedef unsigned short 				UInt16;
#endif

#endif