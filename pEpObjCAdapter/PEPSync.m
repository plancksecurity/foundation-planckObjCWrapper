//
//  PEPSync.m
//  pEpObjCAdapter
//
//  Created by Dirk Zimmermann on 04.10.18.
//  Copyright © 2018 p≡p. All rights reserved.
//

#import "PEPSync.h"

#import "PEPSyncSendMessageDelegate.h"
#import "PEPNotifyHandshakeDelegate.h"
#import "PEPMessageUtil.h"
#import "PEPMessage.h"
#import "PEPQueue.h"

// MARK: - Declare internals

@interface PEPSync ()

+ (PEPSync * _Nullable)instance;

@property (nonatomic, nullable, weak) id<PEPSyncSendMessageDelegate> syncSendMessageDelegate;
@property (nonatomic, nullable, weak) id<PEPNotifyHandshakeDelegate> notifyHandshakeDelegate;
@property (nonatomic, nonnull) PEPQueue *queue;

- (int)injectSyncEvent:(SYNC_EVENT)event;

@end

// MARK: - Globals called by the engine, used in session init

PEP_STATUS messageToSendObjc(struct _message *msg)
{
    id<PEPSyncSendMessageDelegate> delegate = [[PEPSync instance] syncSendMessageDelegate];
    if (delegate) {
        PEPMessage *theMessage = pEpMessageFromStruct(msg);
        return [delegate sendMessage:theMessage];
    } else {
        return PEP_SYNC_NO_MESSAGE_SEND_CALLBACK;
    }
}

int inject_sync_eventObjc(SYNC_EVENT ev, void *management)
{
    PEPSync *pEpSync = [PEPSync instance];

    if (!pEpSync) {
        pEpSync = (PEPSync *) CFBridgingRelease(management);
    }

    if (pEpSync) {
        return [pEpSync injectSyncEvent:ev];
    } else {
        return 1;
    }
}

// MARK: - Internal globals

static __weak PEPSync *s_pEpSync;

// MARK: - PEPSync class

@implementation PEPSync

+ (PEPSync * _Nullable)instance
{
    return s_pEpSync;
}

- (instancetype)initWithSyncSendMessageDelegate:(id<PEPSyncSendMessageDelegate>
                                                 _Nonnull)syncSendMessageDelegate
                        notifyHandshakeDelegate:(id<PEPNotifyHandshakeDelegate>
                                                 _Nonnull)notifyHandshakeDelegate
{
    if (self = [super init]) {
        _syncSendMessageDelegate = syncSendMessageDelegate;
        _notifyHandshakeDelegate = notifyHandshakeDelegate;
        _queue = [PEPQueue new];
        s_pEpSync = self;
    }
    return self;
}

- (void)shutdown
{
}

- (int)injectSyncEvent:(SYNC_EVENT)event
{
    [self.queue enqueue:[NSValue valueWithBytes:&event objCType:@encode(SYNC_EVENT)]];
    return 0;
}

@end
