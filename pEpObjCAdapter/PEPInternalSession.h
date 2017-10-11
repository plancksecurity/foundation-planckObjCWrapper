//
//  PEPSession.h
//  pEpiOSAdapter
//
//  Created by Volker Birk on 08.07.15.
//  Copyright (c) 2015 p≡p. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 N threads <-> N sessions, with the constraint that a session is never used
 in a pEpEngine call more than once at the same time.
 */
@interface PEPInternalSession : NSObject
// We do not want the client to use a PEPSession. The client is supposed to use PEPObjCAdapter() only.
// Find everything in PEPSession+Internal.h
@end
