//
//  pEpiOSAdapter.m
//  pEpiOSAdapter
//
//  Created by Volker Birk on 28.04.15.
//  Copyright (c) 2015 p≡p. All rights reserved.
//


@import Foundation;

#import "PEPiOSAdapter.h"
#import "MCOAbstractMessage+PEPMessage.h"
#import "PEPQueue.h"
#include "keymanagement.h"

int examine_identity(pEp_identity *ident, void *management)
{
    PEPQueue *q = (__bridge PEPQueue *)management;
    
    NSMutableDictionary *identity = [[NSMutableDictionary alloc] init];
    PEP_identityFromStruct(identity, ident);
    
    [q enqueue:identity];
    return 0;
}

static pEp_identity *retrieve_next_identity(void *management)
{
    PEPQueue *q = (__bridge PEPQueue *)management;
    
    while (![q count])
        usleep(100);
    
    NSDictionary *ident = [q dequeue];
    
    if ([ident objectForKey:@"THE_END"])
        return NULL;
    else
        return PEP_identityToStruct(ident);
}

@implementation PEPiOSAdapter

static PEPQueue *queue = nil;
static NSThread *keyserver_thread = nil;

+ (void)keyserverThread:(id)object
{
    do_keymanagement(retrieve_next_identity, (__bridge void *)queue);
}

+ (void)startKeyserverLookup
{
    if (!queue) {
        queue = [PEPQueue init];
        keyserver_thread = [[NSThread alloc] initWithTarget:self selector:@selector(keyserverThread:) object:nil];
        [keyserver_thread start];
    }
}

+ (void)stopKeyserverLookup
{
    if (queue) {
        [queue enqueue:[NSDictionary dictionaryWithObject:@"THE_END" forKey:@"THE_END"]];
        keyserver_thread = nil;
        queue = nil;
    }
}

+ (void)registerExamineFunction:(PEP_SESSION)session
{
    register_examine_function(session, examine_identity, (__bridge void *)queue);
}

@end
