//
//  PEPSync.m
//  pEpObjCAdapter
//
//  Created by Dirk Zimmermann on 04.10.18.
//  Copyright © 2018 p≡p. All rights reserved.
//

#import "PEPSync.h"

PEP_STATUS messageToSendObjc(struct _message *msg)
{
    return PEP_STATUS_OK;
}

int inject_sync_eventObjc(SYNC_EVENT ev, void *management)
{
    return 0;
}

@implementation PEPSync

@end
