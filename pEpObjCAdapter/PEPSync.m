//
//  PEPSync.m
//  pEpObjCAdapter
//
//  Created by Dirk Zimmermann on 04.10.18.
//  Copyright © 2018 p≡p. All rights reserved.
//

#import "PEPSync.h"

#import "PEPSendMessageDelegate.h"
#import "PEPMessageUtil.h"
#import "PEPQueue.h"
#import "PEPLock.h"
#import <PEPObjCAdapterFramework/PEPObjCAdapter.h>
#import "NSError+PEP+Internal.h"
#import "PEPSessionProvider.h"
#import "PEPInternalSession.h"

@implementation PEPSync

+ (PEP_SESSION)createSession:(NSError **)error
{
    PEP_SESSION session = NULL;

    [PEPLock lockWrite];
    PEP_STATUS status = init(&session);
    [PEPLock unlockWrite];

    if (status != PEP_STATUS_OK) {
        if (error) {
            *error = [NSError errorWithPEPStatusInternal:status];
        }
        return nil;
    }

    return session;
}

+ (void)releaseSession:(PEP_SESSION)session
{
    [PEPLock lockWrite];
    release(session);
    [PEPLock unlockWrite];
}

@end
