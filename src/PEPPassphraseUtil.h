//
//  PEPPassphraseUtil.h
//  pEpObjCAdapterTests
//
//  Created by Dirk Zimmermann on 06.08.20.
//  Copyright © 2020 p≡p. All rights reserved.
//

#import <Foundation/Foundation.h>

@import PEPObjCTypes_iOS;

#import "pEpEngine.h"

NS_ASSUME_NONNULL_BEGIN

@interface PEPPassphraseUtil : NSObject

/// Gets the currently cached passwords,
/// and executes the given block after setting each password in turn
/// until it returns something else other than PEP_PASSPHRASE_REQUIRED
/// or PEP_WRONG_PASSPHRASE, or there are no passwords anymore.
/// @param block The status-returning block to execute against different passwords
+ (PEPStatus)runWithPasswordsSession:(PEP_SESSION)session
                               block:(PEP_STATUS (^)(PEP_SESSION session))block;
@end

NS_ASSUME_NONNULL_END
