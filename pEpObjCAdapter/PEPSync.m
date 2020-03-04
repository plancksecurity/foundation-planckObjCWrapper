//
//  PEPSync.m
//  pEpObjCAdapter
//
//  Created by Dirk Zimmermann on 04.10.18.
//  Copyright © 2018 p≡p. All rights reserved.
//

#import <os/log.h>

#import "pEpEngine.h"

#import "PEPSync.h"
#import "PEPSync_Internal.h"

#import "PEPSendMessageDelegate.h"
#import "PEPNotifyHandshakeDelegate.h"
#import "PEPMessageUtil.h"
#import "PEPMessage.h"
#import "PEPQueue.h"
#import "PEPObjCAdapter.h"
#import "NSError+PEP+Internal.h"
#import "PEPSessionProvider.h"
#import "PEPInternalSession.h"

// MARK: - Internals

static os_log_t s_logger;

typedef PEP_STATUS (* t_messageToSendCallback)(struct _message *msg);
typedef int (* t_injectSyncCallback)(SYNC_EVENT ev, void *management);

@interface PEPSync ()

+ (PEPSync * _Nullable)instance;

@property (nonatomic, nonnull) PEPQueue *queue;
@property (nonatomic, nullable) NSThread *syncThread;
@property (nonatomic, nullable) NSConditionLock *conditionLockForJoiningSyncThread;

/// Condition that gets signaled when the sync thread has registered the sync callbacks,
/// in tandem with haveRegisteredSyncCallbacks.
@property (nonatomic, nullable) NSCondition *haveRegisteredSyncCallbacksCondition;

/// Tracks whether the sync callbacks have been registered or not, in tandem with
/// haveRegisteredSyncCallbacksCondition.
@property BOOL haveRegisteredSyncCallbacks;

/**
 @Return: The callback for message sending that should be used on every session init.
 */
+ (t_messageToSendCallback)messageToSendCallback;

/**
 @Return: The callback for injectiong sync messages that should be used on every session init.
 */
+ (t_injectSyncCallback)injectSyncCallback;

- (PEP_STATUS)messageToSend:(struct _message *)msg;

- (int)injectSyncEvent:(SYNC_EVENT)event isFromShutdown:(BOOL)isFromShutdown;

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
        // The inject comes from the engine, so we know it's not the
        // adapter client calling shutdown.
        return [pEpSync injectSyncEvent:ev isFromShutdown:NO];
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

    PEP_STATUS status = init(&session,
                             [PEPSync messageToSendCallback],
                             [PEPSync injectSyncCallback]);

    if (status != PEP_STATUS_OK) {
        if (error) {
            *error = [NSError errorWithPEPStatusInternal:status];
            os_log(s_logger, "error creating session: %{public}@", *error);
        }
        return nil;
    }

    return session;
}

- (instancetype)initWithSendMessageDelegate:(id<PEPSendMessageDelegate>
                                             _Nullable)sendMessageDelegate
                    notifyHandshakeDelegate:(id<PEPNotifyHandshakeDelegate>
                                             _Nullable)notifyHandshakeDelegate
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
    if (self.syncThread != nil) {
        // already started
        return;
    }

    NSThread *theSyncThread = [[NSThread alloc] initWithTarget:self
                                                      selector:@selector(syncThreadLoop:)
                                                        object:nil];
    theSyncThread.name = @"pEp-sync-loop";
    self.syncThread = theSyncThread;

    // Make sure queue is empty when we start.
    [self.queue removeAllObjects];

    [self assureMainSessionExists];

    self.conditionLockForJoiningSyncThread = [[NSConditionLock alloc] initWithCondition:NO];

    self.haveRegisteredSyncCallbacksCondition = [NSCondition new];
    [self.haveRegisteredSyncCallbacksCondition lock];
    self.haveRegisteredSyncCallbacks = NO;
    [theSyncThread start];

    while (!self.haveRegisteredSyncCallbacks) {
        [self.haveRegisteredSyncCallbacksCondition wait];
    }

    [self.haveRegisteredSyncCallbacksCondition unlock];
}

- (void)shutdown
{
    if (self.syncThread) {
        [self injectSyncEvent:nil isFromShutdown:YES];
    }
}

// MARK: - Private

+ (void)initialize
{
    s_logger = os_log_create("security.pEp.adapter", "PEPSync");
}

+ (PEPSync * _Nullable)instance
{
    return s_pEpSync;
}

- (void)assureMainSessionExists
{
    PEPInternalSession *session __attribute__((unused)) = [PEPSessionProvider session];
}

- (void)syncThreadLoop:(id)object
{
    [self.conditionLockForJoiningSyncThread lock];

    os_log(s_logger, "trying to start the sync loop");

    PEPInternalSession *session = [PEPSessionProvider session];

    if (session) {
        PEP_STATUS status = register_sync_callbacks(session.session, nil, s_notifyHandshake,
                                                    s_retrieve_next_sync_event);

        [self.haveRegisteredSyncCallbacksCondition lock];
        self.haveRegisteredSyncCallbacks = YES;
        [self.haveRegisteredSyncCallbacksCondition signal];
        [self.haveRegisteredSyncCallbacksCondition unlock];

        if (status == PEP_STATUS_OK) {
            status = do_sync_protocol(session.session, nil);
            if (status != PEP_STATUS_OK) {
                os_log_error(s_logger, "do_sync_protocol returned PEP_STATUS %d", status);
                os_log(s_logger, "sync loop is NOT running");
            }
            unregister_sync_callbacks(session.session);
        } else {
            os_log_error(s_logger, "register_sync_callbacks returned PEP_STATUS %d", status);
            os_log(s_logger, "sync loop is NOT running");
        }
    } else {
        os_log_error(s_logger, "could not create session for starting the sync loop");
    }

    os_log(s_logger, "sync loop finished");

    session = nil;

    self.syncThread = nil;
    [self.conditionLockForJoiningSyncThread unlockWithCondition:YES];
}

- (PEP_STATUS)messageToSend:(struct _message *)msg
{
    if (self.sendMessageDelegate) {
        PEPMessage *theMessage = pEpMessageFromStruct(msg);
        return (PEP_STATUS) [self.sendMessageDelegate sendMessage:theMessage];
    } else {
        return PEP_SYNC_NO_MESSAGE_SEND_CALLBACK;
    }
}

/// Injects the given event into the queue.
/// @param event The event to inject, which may contain a nil value, which means the
///  sync loop should stop.
/// @param isFromShutdown This is `YES` when coming from `shutdown` itself, and `NO`
///  otherwise (e.g., when the engine requests a shutdown by injecting a nil event.
- (int)injectSyncEvent:(SYNC_EVENT)event isFromShutdown:(BOOL)isFromShutdown
{
    NSValue *value = [NSValue valueWithBytes:&event objCType:@encode(SYNC_EVENT)];

    if (event) {
        [self.queue enqueue:value];
    } else {
        // This is a nil event, which means shut it all down.
        if ([NSThread currentThread] != self.syncThread) {
            // Only do this when the shutdown is not coming in on the sync thread.
            // Otherwise it will just exit out of the sync loop and be done.
            [self.queue prequeue:value];
            [self.conditionLockForJoiningSyncThread lockWhenCondition:YES];
            [self.conditionLockForJoiningSyncThread unlock];
            self.conditionLockForJoiningSyncThread = nil;
        }
        if (!isFromShutdown) {
            // Only inform the delegate if the shutdown came from the engine
            [self.notifyHandshakeDelegate engineShutdownKeySync];
        }
    }

    return 0;
}

- (PEP_STATUS)notifyHandshake:(pEp_identity *)me
                      partner:(pEp_identity *)partner
                       signal:(sync_handshake_signal)signal
{
    if (self.notifyHandshakeDelegate) {
        PEPIdentity *meIdentity = PEP_identityFromStruct(me);
        PEPIdentity *partnerIdentity = PEP_identityFromStruct(partner);
        return (PEP_STATUS) [self.notifyHandshakeDelegate
                             notifyHandshake:NULL
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
