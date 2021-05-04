//
//  Logger.h
//  pEpObjCAdapter
//
//  Created by Dirk Zimmermann on 05.10.20.
//  Copyright © 2020 p≡p. All rights reserved.
//

#ifndef Logger_h
#define Logger_h

#ifdef IS_IOS_BUILD
#import <pEpIOSToolboxForExtensions/pEpIOSToolboxForExtensions-Swift.h>
#import <pEpIOSToolbox/PEPLogger.h>
#else
#import "PEPToolbox_macOS-Swift.h"
#import "PEPLogger.h"
#endif

#endif /* Logger_h */
