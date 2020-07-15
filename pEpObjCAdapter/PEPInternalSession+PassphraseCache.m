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
    if ([NSThread currentThread] == [NSThread mainThread]) {
        return [self tryPassphraseProviderLastStatus:lastStatus block:block];
    } else {
        return [self tryPassphraseProviderAsyncLastStatus:lastStatus block:block];
    }
}

#pragma mark - Private

/// Calling this via `- [NSObject performSelectorOnMainThread]` should
/// exit the current `CFRunLoopRunInMode` call with `kCFRunLoopRunHandledSource`.
- (void)triggerRunLoopRunHandledSource
{
    NSLog(@"*** triggerRunLoopRunHandledSource called");
}

/// Invokes the given block while setting passphrases requested from the
/// passphrase provider, if set, taking care of the main run loop.
- (PEPStatus)tryPassphraseProviderLastStatus:(PEP_STATUS)lastStatus
                                       block:(PEP_STATUS (^)(PEP_SESSION session))block
{
    id<PEPPassphraseProviderProtocol> passphraseProvider = [PEPObjCAdapter passphraseProvider];
    if (passphraseProvider) {
        NSRunLoop *mainRunLoop = [NSRunLoop currentRunLoop];

        __block NSString *lastPassphrase = nil;
        __block BOOL done = NO;
        __block BOOL tryNextPassphrase = NO;

        PEPPassphraseProviderCallback passphraseCallback = ^(NSString * _Nullable passphrase) {
            lastPassphrase = passphrase;
            tryNextPassphrase = YES;
            [self performSelectorOnMainThread:@selector(triggerRunLoopRunHandledSource)
                                   withObject:nil
                                waitUntilDone:NO];
        };

        [passphraseProvider passphraseRequired:passphraseCallback];

        while (!done) {
            SInt32 result = CFRunLoopRunInMode(kCFRunLoopDefaultMode, 10, YES);
            if (result == kCFRunLoopRunHandledSource) {
                if (tryNextPassphrase) {
                    NSLog(@"*** try again with latest passphrase");
                    tryNextPassphrase = NO;
                } else {
                    NSLog(@"*** source was handled, but no passphrase");
                }
            } else if ((result == kCFRunLoopRunStopped) || (result == kCFRunLoopRunFinished)) {
                // This should never happen, but exit this run loop anyways.
                done = YES;
            }
        }
        // TODO: This is fake
        return (PEPStatus) lastStatus;
    } else {
        // no passphrase provider
        return (PEPStatus) lastStatus;
    }
}

/// Invokes the given block while setting passphrases requested from the
/// passphrase provider, if set.
- (PEPStatus)tryPassphraseProviderAsyncLastStatus:(PEP_STATUS)lastStatus
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
            [self.passphraseCache addPassphrase:normalizedPassphrase];

            if (normalizedPassphrase == nil) {
                // Assume excessively long passphrase means PEP_WRONG_PASSPHRASE
                lastPassphraseProviderStatus = PEP_WRONG_PASSPHRASE;

                dispatch_group_enter(group);
                [passphraseProvider passphraseTooLong:passphraseCallback];
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
