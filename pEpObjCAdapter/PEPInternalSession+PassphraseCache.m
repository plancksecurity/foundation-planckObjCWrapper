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
#import "PEPObjCAdapter+Internal.h"
#import "NSString+NormalizePassphrase.h"

@implementation PEPInternalSession (PassphraseCache)

- (PEPStatus)runWithPasswords:(PEP_STATUS (^)(PEP_SESSION session))block
{
    PEP_STATUS lastStatus = PEP_UNKNOWN_ERROR;

    NSMutableArray *passphrases = [NSMutableArray
                                   arrayWithArray:[self.passphraseCache passphrases]];
    [passphrases insertObject:@"" atIndex:0];

    if (self.passphraseCache.storedPassphrase) {
        [passphrases insertObject:self.passphraseCache.storedPassphrase atIndex:1];
    }

    for (NSString *passphrase in passphrases) {
        PEP_STATUS status = config_passphrase(self.session, [passphrase UTF8String]);

        if (status != PEPStatusOK) {
            return (PEPStatus) status;
        }

        lastStatus = block(self.session);

        if (lastStatus != PEP_PASSPHRASE_REQUIRED && lastStatus != PEP_WRONG_PASSPHRASE) {
            // The passphrase worked, so reset its timeout
            [self.passphraseCache resetTimeoutForPassphrase:passphrase];

            return (PEPStatus) lastStatus;
        }
    }

    // If execution lands here, it means we ran out of passwords to set while
    // receiving password-related error codes.

    id<PEPPassphraseProviderProtocol> passphraseProvider = [PEPObjCAdapter passphraseProvider];
    if (passphraseProvider) {
        dispatch_group_t group;

        __block PEP_STATUS lastPassphraseProviderStatus = lastStatus;
        __block NSString *lastPassphrase = nil;

        PEPPassphraseProviderCallback passPhraseCallback = ^(NSString * _Nullable passphrase) {
            lastPassphrase = passphrase;
            dispatch_group_leave(group);
        };

        while (YES) {
            if (lastPassphraseProviderStatus == PEP_PASSPHRASE_REQUIRED) {
                dispatch_group_enter(group);
                [passphraseProvider passphraseRequiredCompletion:passPhraseCallback];
                dispatch_group_wait(group, DISPATCH_TIME_FOREVER);
            } else if (lastPassphraseProviderStatus == PEP_WRONG_PASSPHRASE) {
                dispatch_group_enter(group);
                [passphraseProvider wrongPassphraseCompletion:passPhraseCallback];
                dispatch_group_wait(group, DISPATCH_TIME_FOREVER);
            }

            if (lastPassphrase == nil) {
                return (PEPStatus) lastPassphraseProviderStatus;
            }

            NSError *passphraseError = nil;
            NSString *normalizedPassphrase = [lastPassphrase
                                              normalizedPassphraseWithError:&passphraseError];

            if (normalizedPassphrase == nil) {
                dispatch_group_enter(group);
                [passphraseProvider passphraseTooLong:passPhraseCallback];
                dispatch_group_wait(group, DISPATCH_TIME_FOREVER);
                continue;
            }

            lastPassphraseProviderStatus = config_passphrase(self.session,
                                                             [lastPassphrase UTF8String]);
            if (lastPassphraseProviderStatus != PEPStatusOK) {
                return (PEPStatus) lastPassphraseProviderStatus;
            }

            lastPassphraseProviderStatus = block(self.session);

            if (lastPassphraseProviderStatus != PEP_PASSPHRASE_REQUIRED &&
                lastPassphraseProviderStatus != PEP_WRONG_PASSPHRASE) {
                // The passphrase worked, so reset its timeout
                [self.passphraseCache resetTimeoutForPassphrase:lastPassphrase];

                return (PEPStatus) lastPassphraseProviderStatus;
            }
        }

        return (PEPStatus) lastPassphraseProviderStatus;
    } else {
        // no passphrase provider
        return (PEPStatus) lastStatus;
    }
}

@end
