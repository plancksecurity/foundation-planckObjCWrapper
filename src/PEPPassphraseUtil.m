//
//  PEPPassphraseUtil.m
//  pEpObjCAdapterTests
//
//  Created by Dirk Zimmermann on 06.08.20.
//  Copyright © 2020 p≡p. All rights reserved.
//

#import "PEPPassphraseUtil.h"

#import "pEpEngine.h"

#import "PEPPassphraseCache.h"
#import "PEPObjCAdapter+ReadConfig.h"
#import "NSString+NormalizePassphrase.h"

@implementation PEPPassphraseUtil

+ (PEPStatus)runWithPasswordsSession:(PEP_SESSION)session
                               block:(PEP_STATUS (^)(PEP_SESSION session))block
{
    PEP_STATUS lastStatus = PEP_UNKNOWN_ERROR;

    NSMutableArray *passphrases = [NSMutableArray
                                   arrayWithArray:[[PEPPassphraseCache sharedInstance] passphrases]];
    [passphrases insertObject:@"" atIndex:0];

    if ([[PEPPassphraseCache sharedInstance] storedPassphrase]) {
        [passphrases insertObject:[[PEPPassphraseCache sharedInstance] storedPassphrase] atIndex:1];
    }

    for (NSString *passphrase in passphrases) {
        PEP_STATUS status = config_passphrase(session, [passphrase UTF8String]);

        if (status != PEPStatusOK) {
            return (PEPStatus) status;
        }

        lastStatus = block(session);

        if (lastStatus != PEP_PASSPHRASE_REQUIRED && lastStatus != PEP_WRONG_PASSPHRASE) {
            // The passphrase worked, so reset its timeout
            [[PEPPassphraseCache sharedInstance] resetTimeoutForPassphrase:passphrase];

            return (PEPStatus) lastStatus;
        }
    }

    // If execution lands here, it means we ran out of passwords to set while
    // receiving password-related error codes.
    return [self tryPassphraseProviderSession:session
                                   lastStatus:lastStatus
                                        block:block];
}

#pragma mark - Private

/// Invokes the given block while setting passphrases requested from the
/// passphrase provider, if set.
+ (PEPStatus)tryPassphraseProviderSession:(PEP_SESSION)session
                               lastStatus:(PEP_STATUS)lastStatus
                                    block:(PEP_STATUS (^)(PEP_SESSION session))block
{
    id<PEPPassphraseProviderProtocol> passphraseProvider = [PEPObjCAdapter passphraseProvider];
    if (passphraseProvider) {
        dispatch_group_t group = dispatch_group_create();

        __block PEP_STATUS lastPassphraseProviderStatus = lastStatus;
        __block NSString *lastPassphrase = nil;

        PEPPassphraseProviderCallback passphraseCallback = ^(NSString * _Nullable passphrase) {
            lastPassphrase = passphrase;
            dispatch_group_leave(group);
        };

        while (YES) {
            if (lastPassphraseProviderStatus == PEP_PASSPHRASE_REQUIRED) {
                dispatch_group_enter(group);
                [passphraseProvider passphraseRequired:passphraseCallback];
                dispatch_group_wait(group, DISPATCH_TIME_FOREVER);
            } else if (lastPassphraseProviderStatus == PEP_WRONG_PASSPHRASE) {
                dispatch_group_enter(group);
                [passphraseProvider wrongPassphrase:passphraseCallback];
                dispatch_group_wait(group, DISPATCH_TIME_FOREVER);
            }

            if (lastPassphrase == nil) {
                return (PEPStatus) lastPassphraseProviderStatus;
            }

            NSString *normalizedPassphrase = [lastPassphrase normalizedPassphraseWithError:nil];

            //Add the new passphrase to our cache to not having to bother the client again.
            [[PEPPassphraseCache sharedInstance] addPassphrase:normalizedPassphrase];

            if (normalizedPassphrase == nil) {
                // Assume excessively long passphrase means PEP_WRONG_PASSPHRASE
                lastPassphraseProviderStatus = PEP_WRONG_PASSPHRASE;

                dispatch_group_enter(group);
                [passphraseProvider passphraseTooLong:passphraseCallback];
                dispatch_group_wait(group, DISPATCH_TIME_FOREVER);
                continue;
            }

            lastPassphraseProviderStatus = config_passphrase(session,
                                                             [lastPassphrase UTF8String]);
            if (lastPassphraseProviderStatus != PEPStatusOK) {
                return (PEPStatus) lastPassphraseProviderStatus;
            }

            lastPassphraseProviderStatus = block(session);

            if (lastPassphraseProviderStatus != PEP_PASSPHRASE_REQUIRED &&
                lastPassphraseProviderStatus != PEP_WRONG_PASSPHRASE) {
                // The passphrase worked, so reset its timeout
                [[PEPPassphraseCache sharedInstance] resetTimeoutForPassphrase:lastPassphrase];

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
