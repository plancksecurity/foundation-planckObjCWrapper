//
//  PEPSessionProvider.m
//  pEpObjCAdapter
//
//  Created by Andreas Buff on 09.10.17.
//  Copyright © 2017 p≡p. All rights reserved.
//

#include <pthread.h>

#import "PEPSessionProvider.h"

#import "PEPObjCAdapter+ReadConfig.h"
#import "PEPObjCAdapter+ReadEchoConfig.h"
#import "PEPObjCAdapter+ReadMediaKeyConfig.h"
#import "PEPInternalSession.h"
#import "PEPCopyableThread.h"
#import "Logger.h"

@implementation PEPSessionProvider

static NSLock *s_sessionForThreadLock = nil;
static NSMutableDictionary<PEPCopyableThread*,PEPInternalSession*> *s_sessionForThreadDict;

/** We have to conform to the Engines rule: "The first session has to be created on the main thread and kept
 alive until all sessiopns created afterwards have been teared down."
 PEPSessionProvider makes sure we conform to that rules.
 All PEPSessions given to the client of PEPObjCAdapter MUST be provided by PEPSessionProvider.
 PEPSessionProvider is threadsave.
 */
static PEPInternalSession *s_sessionForMainThread = nil;

#pragma mark - Public API

void annotatedThreadname(void)
{
    pthread_t thread = pthread_self();
    uint64_t thread_id;
    int success = pthread_threadid_np(thread, &thread_id);
    assert(success == 0);

    NSString *label = @"posix";
    NSString *threadIdString = [NSString stringWithFormat:@"%@ %llu", label, thread_id];

    NSString *threadName = [[NSThread currentThread] name];
    if (!threadName) {
        threadName = @"";
    }
    if ([threadName isEqualToString:@""]) {
        [[NSThread currentThread] setName:threadIdString];
    } else {
        if (![threadName containsString:label]) {
            NSString *combinedThreadName = [NSString stringWithFormat:@"%@ (%@)",
                                            threadName,
                                            threadIdString];
            [[NSThread currentThread] setName:combinedThreadName];
        }
    }
}

+ (PEPInternalSession * _Nonnull)session
{
    // Assure a session for the main thread exists and is kept alive before anyother session is created.
    [self assureSessionForMainThreadExists];

    if ([NSThread isMainThread]) {
        [self configureSession:s_sessionForMainThread];
        return s_sessionForMainThread;
    }

    [[self sessionForThreadLock] lock];
    NSMutableDictionary<PEPCopyableThread*,PEPInternalSession*> *dict = [self sessionForThreadDict];
    PEPCopyableThread *currentThread = [[PEPCopyableThread alloc] initWithThread:[NSThread currentThread]];
    PEPInternalSession *newOrExistingSession = dict[currentThread];
    if (!newOrExistingSession) {
        newOrExistingSession = [PEPInternalSession new];
        dict[currentThread] = newOrExistingSession;
    }

    // configuration
    [self configureSession:newOrExistingSession];

    [self nullifySessionsOfFinishedThreads];

    [[self sessionForThreadLock] unlock];

    return newOrExistingSession;
}

+ (void)cleanup
{
    [[self sessionForThreadLock] lock];

    [self cleanupInternal];

    [[self sessionForThreadLock] unlock];
}

#pragma mark - Life Cycle

+ (void)initialize
{
    s_sessionForThreadLock = [NSLock new];
    s_sessionForThreadDict = [NSMutableDictionary new];
}

#pragma mark - Lock

+ (NSLock *)sessionForThreadLock
{
    return s_sessionForThreadLock;
}

+ (NSMutableDictionary *)sessionForThreadDict
{
    return s_sessionForThreadDict;
}

#pragma mark - Configuration

+ (void)configureSession:(PEPInternalSession *)session
{
    [self setConfigUnEncryptedSubjectOnSession:session];
    [self setPassiveModeOnSession:session];
    [self setPassphraseForNewKeysOnSession:session];
    [self configureEchoProtocolOnSession:session];
    [self configureMediaKeysOnSession:session];
}

+ (void)setConfigUnEncryptedSubjectOnSession:(PEPInternalSession *)session
{
    BOOL unEncryptedSubjectEnabled = [PEPObjCAdapter unEncryptedSubjectEnabled];
    [session configUnEncryptedSubjectEnabled:unEncryptedSubjectEnabled];
}

+ (void)setPassiveModeOnSession:(PEPInternalSession *)session
{
    BOOL passiveModeEnabled = [PEPObjCAdapter passiveModeEnabled];
    [session configurePassiveModeEnabled:passiveModeEnabled];
}

+ (void)setPassphraseForNewKeysOnSession:(PEPInternalSession *)session
{
    NSString *passphrase = [PEPObjCAdapter passphraseForNewKeys];

    PEP_STATUS status = PEP_ILLEGAL_VALUE;
    if (passphrase) {
        status = config_passphrase_for_new_keys(session.session, YES, [passphrase UTF8String]);
    } else {
        status = config_passphrase_for_new_keys(session.session, NO, NULL);
    }

    if (status != PEPStatusOK) {
        LogError(@"could not configure passphrase for new keys: %d", status);
    }
}

+ (void)configureEchoProtocolOnSession:(PEPInternalSession *)session
{
    BOOL echoEnabled = [PEPObjCAdapter echoProtocolEnabled];
    [session configureEchoProtocolEnabled:echoEnabled];

    BOOL echoInOutgoing = [PEPObjCAdapter echoInOutgoingMessageRatingPreviewEnabled];
    [session configureEchoInOutgoingMessageRatingPreviewEnabled:echoInOutgoing];
}

+ (void)configureMediaKeysOnSession:(PEPInternalSession *)session
{
    NSArray<PEPMediaKeyPair *> *mediaKeys = [PEPObjCAdapter mediaKeys];

    NSError *error = nil;

    BOOL success = [session configureMediaKeys:mediaKeys error:&error];
    if (!success) {
        if (error) {
            LogError(@"Could not configure the media keys: %@\n  media keys: %@",
                     error,
                     mediaKeys);
        } else {
            LogError(@"Could not configure the media keys %@", mediaKeys);
        }
    }
}

#pragma mark -

/**
 Assures a session for the main thread is set.
 */
+ (void)assureSessionForMainThreadExists
{
    if (s_sessionForMainThread) {
        return;
    }

    // shared code that is executed in any case, either on the main thread or in the background
    void (^creationBlock)(void) = ^{
        if (s_sessionForMainThread) {
            return;
        }
        [[self sessionForThreadLock] lock];
        s_sessionForMainThread = [PEPInternalSession new];
        [[self sessionForThreadLock] unlock];
    };

    if ([NSThread isMainThread]) {
        creationBlock();
    } else {
        dispatch_sync(dispatch_get_main_queue(), creationBlock);
    }
}

+ (void)cleanupInternal
{
    NSMutableDictionary<PEPCopyableThread*,PEPInternalSession*> *dict = [self sessionForThreadDict];

    for (PEPCopyableThread *thread in dict.allKeys) {
        [self nullifySessionForThread:thread];
    }
    s_sessionForMainThread = nil;
    [dict removeAllObjects];
}

/**
 Tears down all sessions that belong to a thread that has finish executing forever.
 */
+ (void)nullifySessionsOfFinishedThreads
{
    NSMutableDictionary<PEPCopyableThread*,PEPInternalSession*> *dict = [self sessionForThreadDict];
    for (PEPCopyableThread *thread in dict.allKeys) {
        if (thread.isFinished) {
            // The session has been created to run on the one and only thread.
            // As this thread did finish executing forever, we can be sure the session can not be
            // accessed anymore, thus it is OK to nullify it on another thread as the one it has been
            // created for.
            [self nullifySessionForThread:thread];
        }
    }
}

+ (void)nullifySessionForThread:(PEPCopyableThread *)thread
{
    NSMutableDictionary<PEPCopyableThread*,PEPInternalSession*> *dict = [self sessionForThreadDict];
    dict[thread] = nil;
}

@end
