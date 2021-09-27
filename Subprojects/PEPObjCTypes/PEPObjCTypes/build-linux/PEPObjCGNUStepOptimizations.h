#define UNSUPPORTED_NS_CLOSED_ENUM 1
#define NO_TOOLBOX 1

#ifndef PEP_OBJC_GNUSTEP_OPTIMIZATIONS_H
#define PEP_OBJC_GNUSTEP_OPTIMIZATIONS_H

/// NS_CLOSED_ENUM is too new for GNUStep ObjC. We replace it with NS_ENUM.
#ifdef UNSUPPORTED_NS_CLOSED_ENUM
#define NS_CLOSED_ENUM NS_ENUM
#endif

#endif