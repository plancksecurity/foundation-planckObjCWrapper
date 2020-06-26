//
//  PEPInternalSession+PassphraseCache.m
//  PEPObjCAdapterFramework
//
//  Created by Dirk Zimmermann on 26.06.20.
//  Copyright © 2020 p≡p. All rights reserved.
//

#import "PEPInternalSession+PassphraseCache.h"

#import "pEpEngine.h"

#import "PEPPassphraseCache.h"

@implementation PEPInternalSession (PassphraseCache)

- (PEP_STATUS)runWithPasswords:(PEP_STATUS (^)(void))block
{
    PEP_STATUS lastStatus = PEPStatusUnknownError;

    NSArray *passphrases = [[PEPPassphraseCache sharedInstance] passphrases];
    for (NSString *passphrase in passphrases) {
        PEP_STATUS status = config_passphrase(self.session, [passphrase UTF8String])

        if (status != PEPStatusOK) {
            return status;
        }

        lastStatus = block();

        if (lastStatus != PEP_PASSPHRASE_REQUIRED && lastStatus != PEP_WRONG_PASSPHRASE) {
            return lastStatus;
        }
    }

    // If execution lands here, it means we ran out of passwords to set while
    // receiving password-related error codes.
    return lastStatus;
}

@end
