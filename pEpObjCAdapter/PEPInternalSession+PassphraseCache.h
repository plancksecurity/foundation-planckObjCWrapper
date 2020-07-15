//
//  PEPInternalSession+PassphraseCache.h
//  PEPObjCAdapterFramework
//
//  Created by Dirk Zimmermann on 26.06.20.
//  Copyright © 2020 p≡p. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "PEPInternalSession.h"

#import "pEpEngine.h"

NS_ASSUME_NONNULL_BEGIN

@interface PEPInternalSession (PassphraseCache)

/// Gets the currently cached passwords,
/// and executes the given block after setting each password in turn
/// until it returns something else other than PEP_PASSPHRASE_REQUIRED
/// or PEP_WRONG_PASSPHRASE, or there are no passwords anymore.
/// @param block The status-returning block to execute against different passwords
- (PEPStatus)runWithPasswords:(PEP_STATUS (^)(PEP_SESSION session))block;

/// Used for passphrase handling on the main thread.
- (void)exitCurrentRunLoopAndTryPassphraseDummy;

@end

NS_ASSUME_NONNULL_END
