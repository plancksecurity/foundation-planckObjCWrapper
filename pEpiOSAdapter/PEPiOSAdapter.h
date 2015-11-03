//
//  pEpiOSAdapter.h
//  pEpiOSAdapter
//
//  Created by Volker Birk on 28.04.15.
//  Copyright (c) 2015 p≡p. All rights reserved.
//

#import <Foundation/Foundation.h>
#include "message_api.h"

@interface PEPiOSAdapter : NSObject

// start or stop keyserver lookup
// there is only one keyserver lookup thread

+ (void)startKeyserverLookup;
+ (void)stopKeyserverLookup;
+ (void)setupTrustWordsDB;
+ (void)setupTrustWordsDB:(NSBundle *)rootBundle;

// this message is for internal use only; do not call

+ (void)registerExamineFunction:(PEP_SESSION)session;

@end
