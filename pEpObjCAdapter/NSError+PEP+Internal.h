//
//  NSError+PEP+Internal.h
//  pEpObjCAdapter
//
//  Created by Dirk Zimmermann on 28.02.19.
//  Copyright © 2019 p≡p. All rights reserved.
//

#ifndef NSError_PEP_Internal_h
#define NSError_PEP_Internal_h

#import "PEPEngineTypes.h"

/**
 Extension for creating `NSError`s from `PEP_STATUS`
 */
@interface NSError (Internal)

+ (NSError * _Nullable)errorWithPEPStatus:(PEPStatus)status;

+ (NSError * _Nullable)errorWithPEPStatusInternal:(PEP_STATUS)status;

/**
 If the given status indicates an error, tries to set the given error accordingly.
 @return YES if the given status indicates an error condition, NO otherwise.
 */
+ (BOOL)setError:(NSError * _Nullable * _Nullable)error fromPEPStatus:(PEPStatus)status;

@end

#endif /* NSError_PEP_Internal_h */
