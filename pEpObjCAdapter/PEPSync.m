//
//  PEPSync.m
//  pEpObjCAdapter
//
//  Created by Dirk Zimmermann on 04.10.18.
//  Copyright © 2018 p≡p. All rights reserved.
//

#import "PEPSync.h"

#import "PEPSyncSendMessageDelegate.h"
#import "PEPMessageUtil.h"
#import "PEPMessage.h"

PEP_STATUS messageToSendObjc(struct _message *msg)
{
    PEPSyncSendMessageDelegate *delegate = [PEPSync syncSendMessageDelegate];
    if (delegate) {
        PEPMessage *theMessage = pEpMessageFromStruct(msg);
        return [delegate sendMessage:theMessage];
    }

    return PEP_STATUS_OK;
}

int inject_sync_eventObjc(SYNC_EVENT ev, void *management)
{
    return 0;
}

static __weak PEPSyncSendMessageDelegate *s_PEPSyncSendMessageDelegate;

@implementation PEPSync

+ (void)setPEPSyncSendMessageDelegate:
(PEPSyncSendMessageDelegate * _Nullable)syncSendMessageDelegate
{
    s_PEPSyncSendMessageDelegate = syncSendMessageDelegate;
}

+ (PEPSyncSendMessageDelegate * _Nullable)syncSendMessageDelegate
{
    return s_PEPSyncSendMessageDelegate;
}

- (void)setSyncSendMessageDelegate:(PEPSyncSendMessageDelegate *)syncSendMessageDelegate
{
    [PEPSync setPEPSyncSendMessageDelegate:syncSendMessageDelegate];
}

- (PEPSyncSendMessageDelegate *)syncSendMessageDelegate
{
    return [PEPSync syncSendMessageDelegate];
}

@end
