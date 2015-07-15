//
//  pEpiOSAdapter.h
//  pEpiOSAdapter
//
//  Created by Volker Birk on 28.04.15.
//  Copyright (c) 2015 p≡p. All rights reserved.
//

#import <Foundation/Foundation.h>
#include "pEpEngine.h"

@interface PEPiOSAdapter : NSObject

// start or stop keyserver lookup
// there is only one keyserver lookup thread

+ (void)startKeyserverLookup;
+ (void)stopKeyserverLookup;

// this message is for internal use only

+ (void)registerExamineFunction:(PEP_SESSION)session;

@end
