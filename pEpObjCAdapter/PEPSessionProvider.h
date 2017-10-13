//
//  PEPSessionProvider.h
//  pEpObjCAdapter
//
//  Created by Andreas Buff on 09.10.17.
//  Copyright © 2017 p≡p. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PEPInternalSession;

/**
 If you need a PEPInternaSession instance, PEPSessionProvider (and only PEPSessionProvider)
 provides you with one.

 Internally session provider creates a session per thread and caches it for as long as thread is not finished.
 */
@interface PEPSessionProvider : NSObject

/**
 Provides a PEPInternalSession intance.

 @return interna session instance suitable for the callers thread.
 */
+ (PEPInternalSession * _Nonnull)session;

+ (void)cleanup;

@end
