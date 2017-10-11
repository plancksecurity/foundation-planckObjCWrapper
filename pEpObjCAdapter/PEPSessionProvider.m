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
        session = [[PEPInternalSession alloc] initInternal];
        dict[currentThread] = session;
    }
    [self nullifySessionsOfFinishedThreads];
    
    [[self sessionForThreadLock] unlock];
    
    return session;
}

+ (void)cleanup
{
    [[self sessionForThreadLock] lock];
    
    NSMutableDictionary<PEPCopyableThread*,PEPInternalSession*> *dict = [self sessionForThreadDict];
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

+ (void)nullifySessionsOfFinishedThreads
{
    NSMutableDictionary<PEPCopyableThread*,PEPInternalSession*> *dict = [self sessionForThreadDict];
    for (PEPCopyableThread *thread in dict.allKeys) {
        if (thread.isFinished) {
            [self nullifySessionForThread:thread];
        }
    }
}

+ (void)nullifySessionForThread:(PEPCopyableThread *)thread
{
    NSMutableDictionary<PEPCopyableThread*,PEPInternalSession*> *dict = [self sessionForThreadDict];
    PEPInternalSession *session = dict[thread];
    [self performSelector:@selector(nullifySession:)
                 onThread:thread.thread
               withObject:session
            waitUntilDone:NO];
    dict[thread] = nil;
}

+ (void)nullifySession:(PEPInternalSession *)session
{
    session = nil;
}

@end
