//
//  PEPSessionProvider.m
//  pEpObjCAdapter
//
//  Created by Andreas Buff on 09.10.17.
//  Copyright © 2017 p≡p. All rights reserved.
//

#import "PEPSessionProvider.h"

#import "PEPInternalSession.h"
#import "PEPCopyableThread.h"

@implementation PEPSessionProvider

static NSLock *s_sessionForThreadLock = nil;
static NSMutableDictionary<PEPCopyableThread*,PEPInternalSession*> *s_sessionForThreadDict;

#pragma mark - Public API

+ (PEPInternalSession * _Nonnull)session
{
    [[self sessionForThreadLock] lock];

    PEPCopyableThread *currentThread = [[PEPCopyableThread alloc] initWithThread:[NSThread currentThread]];
    NSMutableDictionary<PEPCopyableThread*,PEPInternalSession*> *dict = [self sessionForThreadDict];
    PEPInternalSession *session = dict[currentThread];
    if (!session) {
        session = [PEPInternalSession new];
        dict[currentThread] = session;
    }
    [self nullifySessionsOfFinishedThreads];
    NSLog(@"#################\nnum sessions is now %lu\n#################", (unsigned long)[self sessionForThreadDict].count);

    [[self sessionForThreadLock] unlock];

    return session;
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

#pragma mark -

+ (void)cleanupInternal
{
    NSMutableDictionary<PEPCopyableThread*,PEPInternalSession*> *dict = [self sessionForThreadDict];

    for (PEPCopyableThread *thread in dict.allKeys) {
        if (thread.isFinished) {
            [self nullifySessionForThread:thread];
        } else {
            PEPInternalSession *session = dict[thread];
            [session logTitle:@"Cleaning session that is potentially still in use"
                       entity:[[self class] description]
                  description:@"We are going to nullify a session for an active thread.\
             This must not happen. \
             It is the clients responsibility to assure no session is in use anymore when calling cleanup()."
                      comment:nil];
            [self nullifySessionForThread:thread];
        }
    }
    NSLog(@"All sessions have been cleaned up. Session count is %lu", (unsigned long)dict.count); //BUFF:
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
    PEPInternalSession *session = dict[thread];
    dict[thread] = nil;
    session = nil;
}

@end
