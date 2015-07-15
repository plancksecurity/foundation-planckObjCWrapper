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

static pEp_identity *retrieve_next_identity(void *management)
{
    PEPQueue *q = (__bridge PEPQueue *)management;
    
    while (![q count])
        sleep(100);
    
    return PEP_identityToStruct([q dequeue]);
}

@implementation PEPiOSAdapter

static NSMutableArray *queue = nil;
static NSThread *keyserver_thread = nil;

+ (void)keyserverThread:(id)object
{
    
}

+ (void)startKeyserverLookup
{
    if (!queue) {
        queue = [PEPQueue init];

        if (!keyserver_thread)
            keyserver_thread = [[NSThread alloc] initWithTarget:self selector:@selector(keyserverThread:) object:nil];

        [keyserver_thread start];
    }
}

+ (void)stopKeyserverLookup
{
    if (queue) {
        queue = nil;
    }
}

@end
