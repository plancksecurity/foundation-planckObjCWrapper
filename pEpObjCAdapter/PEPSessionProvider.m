//
//  PEPSessionProvider.m
//  pEpObjCAdapter
//
//  Created by Andreas Buff on 09.10.17.
//  Copyright © 2017 p≡p. All rights reserved.
//

#import "PEPSessionProvider.h"

#import "PEPObjCAdapter+Internal.h"
#import "PEPInternalSession.h"
#import "PEPCopyableThread.h"

@implementation PEPSessionProvider

static NSLock *s_sessionForThreadLock = nil;
static NSMutableDictionary<PEPCopyableThread*,PEPInternalSession*> *s_sessionForThreadDict;

/** We have to conform to the Engines rule: "The first session has to be created on the main thread and kept
 alive until all sessiopns created afterwards have been teared down."
 Here we hold it.
 */
static PEPInternalSession *s_sessionForMainThread = nil;

#pragma mark - Public API

+ (PEPInternalSession * _Nonnull)session
{
    [[self sessionForThreadLock] lock];

    // Assure a session for the main thread exists and is kept alive before anyother session is created.
    [self assureSessionForMainThreadExists];

    if ([NSThread isMainThread]) {
        [[self sessionForThreadLock] unlock];
        return s_sessionForMainThread;
    }

    NSMutableDictionary<PEPCopyableThread*,PEPInternalSession*> *dict = [self sessionForThreadDict];
    PEPCopyableThread *currentThread = [[PEPCopyableThread alloc] initWithThread:[NSThread currentThread]];
    PEPInternalSession * __strong newOrExistingSession = dict[currentThread];
    if (!newOrExistingSession) {
        newOrExistingSession = [PEPInternalSession new];
        dict[currentThread] = newOrExistingSession;
    }

    // configuration
    [self setConfigUnEncryptedSubjectOnSession:newOrExistingSession];
    [self setPassiveModeOnSession:newOrExistingSession];

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

#pragma mark - configuration

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

#pragma mark -

/**
 Assures a session for the main thread is set.
 */
+ (void)assureSessionForMainThreadExists
{
    // shared code to set global configuration every time
    void (^configurationBlock)(void) = ^{
        [self setConfigUnEncryptedSubjectOnSession:s_sessionForMainThread];
        [self setPassiveModeOnSession:s_sessionForMainThread];
    };

    if (s_sessionForMainThread) {
        configurationBlock();
        return;
    }

    // shared code that is executed in any case, either on the main thread or in the background
    void (^creationBlock)(void) = ^{
        if (s_sessionForMainThread) {
            return;
        }
        s_sessionForMainThread = [PEPInternalSession new];
        configurationBlock();
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
    NSLog(@"*** 0x%lu (niling s_sessionForMainThread)", (u_long) s_sessionForMainThread);
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
