//
//  PEPSessionProvider.m
//  pEpObjCAdapter
//
//  Created by Andreas Buff on 09.10.17.
//  Copyright © 2017 p≡p. All rights reserved.
//

#import "PEPSessionProvider.h"

#import "PEPSession.h"
#import "PEPSession+Internal.h"
#import "PEPCopyableThread.h"

@implementation PEPSessionProvider

static NSLock *s_sessionForThreadLock = nil;
static NSMutableDictionary<PEPCopyableThread*,PEPSession*> *s_sessionForThreadDict;

#pragma mark - Public API

+ (PEPSession * _Nonnull)session
{
    [[self sessionForThreadLock] lock];

    PEPCopyableThread *currentThread = [[PEPCopyableThread alloc] initWithThread:[NSThread currentThread]];
    NSMutableDictionary<PEPCopyableThread*,PEPSession*> *dict = [self sessionForThreadDict];
    PEPSession *session = dict[currentThread];
    if (!session) {
        session = [[PEPSession alloc] initInternal];
        dict[currentThread] = session;
    }
    [self nullifySesssionOfFinishedThreads];

    [[self sessionForThreadLock] unlock];

    return session;
}

+ (void)cleanup
{
    [[self sessionForThreadLock] lock];

    NSMutableDictionary<PEPCopyableThread*,PEPSession*> *dict = [self sessionForThreadDict];
    for (PEPCopyableThread *thread in dict.allKeys) {
        [thread cancel];
        [self nullifySessionForThread:thread];
    }
    [dict removeAllObjects];

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

+ (void)nullifySesssionOfFinishedThreads
{
    NSMutableDictionary<PEPCopyableThread*,PEPSession*> *dict = [self sessionForThreadDict];
    for (PEPCopyableThread *thread in dict.allKeys) {
        if (thread.isFinished) {
            [self nullifySessionForThread:thread];
        }
    }
}

+ (void)nullifySessionForThread:(PEPCopyableThread *)thread
{
    NSMutableDictionary<PEPCopyableThread*,PEPSession*> *dict = [self sessionForThreadDict];
    PEPSession *session = dict[thread];
    [self performSelector:@selector(nullifySession:)
                 onThread:thread.thread
               withObject:session
            waitUntilDone:YES];
    dict[thread] = nil;
}

+ (void)nullifySession:(PEPSession *)session
{
    session = nil;
}

@end
