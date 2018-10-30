//
//  PEPSync.m
//  pEpObjCAdapter
//
//  Created by Dirk Zimmermann on 04.10.18.
//  Copyright © 2018 p≡p. All rights reserved.
//

#import "PEPSync.h"

#import "PEPSendMessageDelegate.h"
#import "PEPNotifyHandshakeDelegate.h"
#import "PEPMessageUtil.h"
#import "PEPMessage.h"
#import "PEPQueue.h"
#import "PEPLock.h"
#import "PEPObjCAdapter.h"
#import "NSError+PEP.h"

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

- (int)injectSyncEvent:(SYNC_EVENT)event;

- (PEP_STATUS)notifyHandshake:(pEp_identity *)me
                      partner:(pEp_identity *)partner
                       signal:(sync_handshake_signal)signal;

- (SYNC_EVENT)retrieveNextSyncEvent:(time_t)threshold;

@end

// MARK: - Callbacks called by the engine, used in session init

static PEP_STATUS messageToSendObjc(struct _message *msg)
{
    id<PEPSendMessageDelegate> delegate = [[PEPSync instance] sendMessageDelegate];
    if (delegate) {
        PEPMessage *theMessage = pEpMessageFromStruct(msg);
        return [delegate sendMessage:theMessage];
    } else {
        return PEP_SYNC_NO_MESSAGE_SEND_CALLBACK;
    }
}

static int inject_sync_eventObjc(SYNC_EVENT ev, void *management)
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
    PEPSync *sync = [PEPSync instance];
    return [sync notifyHandshake:me partner:partner signal:signal];
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
    return messageToSendObjc;
}

+ (t_injectSyncCallback)injectSyncCallback
{
    return inject_sync_eventObjc;
}

+ (PEP_SESSION)createSession:(NSError **)error
{
    [PEPSync setupTrustWordsDB];

    PEP_SESSION session = NULL;

    [PEPLock lockWrite];
    PEP_STATUS status = init(&session,
                             [PEPSync messageToSendCallback],
                             [PEPSync injectSyncCallback]);
    [PEPLock unlockWrite];

    if (status != PEP_STATUS_OK) {
        if (error) {
            *error = [NSError errorWithPEPStatus:status];
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
    self.conditionLockForJoiningSyncThread = [[NSConditionLock alloc] initWithCondition:NO];
    NSThread *theSyncThread = [[NSThread alloc] initWithTarget:self
                                                      selector:@selector(syncThreadLoop:)
                                                        object:nil];
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

+ (void)setupTrustWordsDB
{
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        [PEPObjCAdapter setupTrustWordsDB:[NSBundle bundleForClass:[self class]]];
    });
}

- (void)syncThreadLoop:(id)object
{
    [self.conditionLockForJoiningSyncThread lock];

    NSError *error = nil;
    PEP_SESSION session = [PEPSync createSession:&error];

    if (session) {
        register_sync_callbacks(session, nil, s_notifyHandshake, s_retrieve_next_sync_event);
        do_sync_protocol(session, nil);
        unregister_sync_callbacks(session);
    } else {
        // indicate error, maybe through `object`?
    }

    [PEPSync releaseSession:session];

    [self.conditionLockForJoiningSyncThread unlockWithCondition:YES];
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
                                                      signal:signal];
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
