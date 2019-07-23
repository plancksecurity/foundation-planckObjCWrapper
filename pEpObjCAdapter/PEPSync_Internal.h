//
//  PEPSync_Internal.h
//  pEpObjCAdapter
//
//  Created by Dirk Zimmermann on 20.05.19.
//  Copyright © 2019 p≡p. All rights reserved.
//

#ifndef PEPSync_Internal_h
#define PEPSync_Internal_h

#import "PEPSync.h"

/**
 Internal methods of PEPSync.
 */
@interface PEPSync (Internal)
/**
 Creates an engine session.
 */
+ (PEP_SESSION _Nullable)createSession:(NSError * _Nullable * _Nullable)error;

@end

#endif /* PEPSync_Internal_h */
