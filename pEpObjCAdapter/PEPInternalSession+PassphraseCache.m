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

- (PEPStatus)runWithPasswords:(PEP_STATUS (^)(PEP_SESSION session))block
{
    PEP_STATUS lastStatus = PEP_UNKNOWN_ERROR;

    NSMutableArray *passphrases = [NSMutableArray
                                   arrayWithArray:[[PEPPassphraseCache sharedInstance]
                                                   passphrases]];
    [passphrases insertObject:@"" atIndex:0];

    for (NSString *passphrase in passphrases) {
        PEP_STATUS status = config_passphrase(self.session, [passphrase UTF8String]);

        if (status != PEPStatusOK) {
            return (PEPStatus) status;
        }

        lastStatus = block(self.session);

        if (lastStatus != PEP_PASSPHRASE_REQUIRED && lastStatus != PEP_WRONG_PASSPHRASE) {
            // The passphrase worked, so reset its timeout
            [[PEPPassphraseCache sharedInstance] resetTimeoutForPassphrase:passphrase];

            return (PEPStatus) lastStatus;
        }
    }

    // If execution lands here, it means we ran out of passwords to set while
    // receiving password-related error codes.
    return (PEPStatus) lastStatus;
}

@end
