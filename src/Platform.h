//
//  Platform.h
//  pEpObjCAdapter
//
//  Created by Dirk Zimmermann on 15.11.22.
//  Copyright © 2022 p≡p. All rights reserved.
//

#ifndef Platform_h
#define Platform_h

#ifdef __APPLE__
#include "TargetConditionals.h"
#if TARGET_OS_IPHONE
#define IS_IOS_BUILD
#elif TARGET_IPHONE_SIMULATOR
#define IS_IOS_BUILD
#elif TARGET_OS_MAC
#undefine IS_IOS_BUILD
#else
#undefine IS_IOS_BUILD
#endif
#endif

#endif /* Platform_h */
