//
//  PEPSync.m
//  pEpObjCAdapter
//
//  Created by Dirk Zimmermann on 04.10.18.
//  Copyright © 2018 p≡p. All rights reserved.
//

#import <os/log.h>

#import "PEPSync.h"

#import "pEpEngine.h"

#import "PEPSendMessageDelegate.h"
#import "PEPNotifyHandshakeDelegate.h"
#import "PEPMessageUtil.h"
#import "PEPMessage.h"
#import "PEPQueue.h"
#import "PEPLock.h"
#import "PEPObjCAdapter.h"
#import "NSError+PEP+Internal.h"
#import "PEPSessionProvider.h"
#import "PEPInternalSession.h"

// MARK: - Declare internals

typedef PEP_STATUS (* t_messageToSendCallback)(struct _message *msg);
typedef int (* t_injectSyncCallback)(SYNC_EVENT ev, void *management);

@interface PEPSync ()

+ (PEPSync * _Nullable)instance;

@property (nonatomic, nullable, weak) id<PEPSendMessageDelegate> sendMessageDelegate;
@property (nonatomic, nullable, weak) id<PEPNotifyHandshakeDelegate> notifyHandshakeDelegate;
@property (nonatomic, nonnull) PEPQueue *queue;
@property (nonatomic, nullable) NSThread *syncThread;
@property (nonatomic, nullable) NSConditionLock *conditionLockForJoiningSyncThread;

/**
 @Return: The callback for message sending that should be used on every session init.
 */
+ (t_messageToSendCallback)messageToSendCallback;

/**
 @Return: The callback for injectiong sync messages that should be used on every session init.
 */
+ (t_injectSyncCallback)injectSyncCallback;

- (PEP_STATUS)messageToSend:(struct _message *)msg;

- (int)injectSyncEvent:(SYNC_EVENT)event;

- (PEP_STATUS)notifyHandshake:(pEp_identity *)me
                      partner:(pEp_identity *)partner
                       signal:(sync_handshake_signal)signal;

- (SYNC_EVENT)retrieveNextSyncEvent:(time_t)threshold;

@end

// MARK: - Callbacks called by the engine, used in session init

static PEP_STATUS s_messageToSendObjc(struct _message *msg)
{
    PEPSync *pEpSync = [PEPSync instance];

    if (pEpSync) {
        return [pEpSync messageToSend:msg];
    } else {
        return PEP_SYNC_NO_NOTIFY_CALLBACK;
    }
}

static int s_inject_sync_event(SYNC_EVENT ev, void *management)
{
    PEPSync *pEpSync = [PEPSync instance];

    if (pEpSync) {
        return [pEpSync injectSyncEvent:ev];
    } else {
        return 1;
    }
}

// MARK: - Callbacks called by the engine, used in register_sync_callbacks

static PEP_STATUS s_notifyHandshake(pEp_identity *me,
                                    pEp_identity *partner,
                                    sync_handshake_signal signal)
{
    PEPSync *pEpSync = [PEPSync instance];

    if (pEpSync) {
        return [pEpSync notifyHandshake:me partner:partner signal:signal];
    } else {
        return PEP_SYNC_NO_NOTIFY_CALLBACK;
    }
}

static SYNC_EVENT s_retrieve_next_sync_event(void *management, unsigned threshold)
{
    PEPSync *sync = [PEPSync instance];
    return [sync retrieveNextSyncEvent:threshold];
}

// MARK: - Internal globals

static __weak PEPSync *s_pEpSync;

// MARK: - Public PEPSync class

@implementation PEPSync

+ (t_messageToSendCallback)messageToSendCallback
{
    return s_messageToSendObjc;
}

+ (t_injectSyncCallback)injectSyncCallback
{
    return s_inject_sync_event;
}

+ (PEP_SESSION)createSession:(NSError **)error
{
    PEP_SESSION session = NULL;

    [PEPLock lockWrite];
    PEP_STATUS status = init(&session,
                             [PEPSync messageToSendCallback],
                             [PEPSync injectSyncCallback]);
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

- (instancetype)initWithSendMessageDelegate:(id<PEPSendMessageDelegate>
                                             _Nonnull)sendMessageDelegate
                    notifyHandshakeDelegate:(id<PEPNotifyHandshakeDelegate>
                                             _Nonnull)notifyHandshakeDelegate
{
    if (self = [super init]) {
        _sendMessageDelegate = sendMessageDelegate;
        _notifyHandshakeDelegate = notifyHandshakeDelegate;
        _queue = [PEPQueue new];
        s_pEpSync = self;
    }
    return self;
}

- (void)startup
{
    // assure the main session exists
    PEPInternalSession *session = [PEPSessionProvider session];
    session = nil;

    self.conditionLockForJoiningSyncThread = [[NSConditionLock alloc] initWithCondition:NO];
    NSThread *theSyncThread = [[NSThread alloc] initWithTarget:self
                                                      selector:@selector(syncThreadLoop:)
                                                        object:nil];
    theSyncThread.name = @"pEp-sync-loop";
    self.syncThread = theSyncThread;
    [theSyncThread start];
}

- (void)shutdown
{
    if (self.syncThread) {
        [self injectSyncEvent:nil];
        [self.conditionLockForJoiningSyncThread lockWhenCondition:YES];
        [self.conditionLockForJoiningSyncThread unlock];
    }
    self.conditionLockForJoiningSyncThread = nil;
}

// MARK: - Private

+ (PEPSync * _Nullable)instance
{
    return s_pEpSync;
}

- (void)syncThreadLoop:(id)object
{
    [self.conditionLockForJoiningSyncThread lock];

    os_log(OS_LOG_DEFAULT, "trying to start the sync loop");

    PEPInternalSession *session = [PEPSessionProvider session];

    if (session) {
        PEP_STATUS status = register_sync_callbacks(session.session, nil, s_notifyHandshake,
                                                    s_retrieve_next_sync_event);
        if (status == PEP_STATUS_OK) {
            status = do_sync_protocol(session.session, nil);
            if (status != PEP_STATUS_OK) {
                os_log_error(OS_LOG_DEFAULT, "do_sync_protocol returned %d", status);
                os_log(OS_LOG_DEFAULT, "sync loop is NOT running");
            }
            unregister_sync_callbacks(session.session);
        } else {
            os_log_error(OS_LOG_DEFAULT, "register_sync_callbacks returned %d", status);
            os_log(OS_LOG_DEFAULT, "sync loop is NOT running");
        }
    } else {
        os_log_error(OS_LOG_DEFAULT, "could not create session for starting the sync loop");
    }

    os_log(OS_LOG_DEFAULT, "sync loop finished");

    session = nil;

    [self.conditionLockForJoiningSyncThread unlockWithCondition:YES];
}

- (PEP_STATUS)messageToSend:(struct _message *)msg
{
    if (self.sendMessageDelegate) {
        PEPMessage *theMessage = pEpMessageFromStruct(msg);
        return [self.sendMessageDelegate sendMessage:theMessage];
    } else {
        return PEP_SYNC_NO_MESSAGE_SEND_CALLBACK;
    }
}

- (int)injectSyncEvent:(SYNC_EVENT)event
{
    [self.queue enqueue:[NSValue valueWithBytes:&event objCType:@encode(SYNC_EVENT)]];
    return 0;
}

- (PEP_STATUS)notifyHandshake:(pEp_identity *)me
                      partner:(pEp_identity *)partner
                       signal:(sync_handshake_signal)signal
{
    if (self.notifyHandshakeDelegate) {
        PEPIdentity *meIdentity = PEP_identityFromStruct(me);
        PEPIdentity *partnerIdentity = PEP_identityFromStruct(partner);
        return [self.notifyHandshakeDelegate notifyHandshake:NULL
                                                          me:meIdentity
                                                     partner:partnerIdentity
                                                      signal:(PEPSyncHandshakeSignal) signal];
    } else {
        return PEP_SYNC_NO_NOTIFY_CALLBACK;
    }
}

- (SYNC_EVENT)retrieveNextSyncEvent:(time_t)threshold
{
    NSValue *value = [self.queue timedDequeue:&threshold];
    if (value) {
        SYNC_EVENT event;
        [value getValue:&event];
        return event;
    } else {
        return new_sync_timeout_event();
    }
}

@end
