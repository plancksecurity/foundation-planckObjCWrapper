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

// MARK: - Declare internals

@interface PEPSync ()

+ (PEPSync * _Nullable)instance;

@property (nonatomic, nullable, weak) PEPSyncSendMessageDelegate *syncSendMessageDelegate;
@property (nonatomic, nullable, weak) PEPNotifyHandshakeDelegate *notifyHandshakeDelegate;

@end

// MARK: - Globals called by the engine, used in session init

PEP_STATUS messageToSendObjc(struct _message *msg)
{
    PEPSyncSendMessageDelegate *delegate = [[PEPSync instance] syncSendMessageDelegate];
    if (delegate) {
        PEPMessage *theMessage = pEpMessageFromStruct(msg);
        return [delegate sendMessage:theMessage];
    } else {
        return PEP_SYNC_NO_MESSAGE_SEND_CALLBACK;
    }
}

int inject_sync_eventObjc(SYNC_EVENT ev, void *management)
{
    PEPNotifyHandshakeDelegate *delegate = [[PEPSync instance] notifyHandshakeDelegate];
    if (delegate) {
        return 0;
    }
    return 1;
}

// MARK: - Internal globals

static __weak PEPSync *s_pEpSync;

// MARK: - PEPSync class

@implementation PEPSync

+ (PEPSync * _Nullable)instance
{
    return s_pEpSync;
}

- (instancetype)initWithSyncSendMessageDelegate:(PEPSyncSendMessageDelegate *
                                                 _Nonnull)syncSendMessageDelegate
                        notifyHandshakeDelegate:(PEPNotifyHandshakeDelegate *
                                                 _Nonnull)notifyHandshakeDelegate
{
    if (self = [super init]) {
        _syncSendMessageDelegate = syncSendMessageDelegate;
        _notifyHandshakeDelegate = notifyHandshakeDelegate;
        s_pEpSync = self;
    }
    return self;
}

@end
