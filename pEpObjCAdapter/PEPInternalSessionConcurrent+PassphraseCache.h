//
//  PEPInternalSession+PassphraseCache.h
//  PEPObjCAdapterFramework
//
//  Created by Dirk Zimmermann on 26.06.20.
//  Copyright © 2020 p≡p. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "PEPInternalSessionConcurrent.h"

#import "pEpEngine.h"

NS_ASSUME_NONNULL_BEGIN

@interface PEPInternalSessionConcurrent (PassphraseCache)

/// Gets the currently cached passwords,
/// and executes the given block after setting each password in turn
/// until it returns something else other than PEP_PASSPHRASE_REQUIRED
/// or PEP_WRONG_PASSPHRASE, or there are no passwords anymore.
/// @param block The status-returning block to execute against different passwords
- (PEPStatus)runWithPasswords:(PEP_STATUS (^)(PEP_SESSION session))block;

@end

NS_ASSUME_NONNULL_END
