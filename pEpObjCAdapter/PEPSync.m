//
//  PEPSync.m
//  pEpObjCAdapter
//
//  Created by Dirk Zimmermann on 04.10.18.
//  Copyright © 2018 p≡p. All rights reserved.
//

#import "pEpEngine.h"

#import "PEPSync.h"
#import "PEPSync_Internal.h"

#import "message_api.h"

#import "PEPSendMessageDelegate.h"
#import "PEPNotifyHandshakeDelegate.h"
#import "PEPMessage.h"
#import "PEPQueue.h"
#import "PEPObjCAdapter.h"
#import "NSError+PEP+Internal.h"
#import "PEPSessionProvider.h"
#import "PEPInternalSession.h"
#import "PEPPassphraseCache.h"
#import "PEPPassphraseUtil.h"
#import "Logger.h"
#import "PEPIdentity+Engine.h"
#import "PEPMessage+Engine.h"

// MARK: - Internals

typedef PEP_STATUS (* t_messageToSendCallback)(struct _message * _Nullable msg);
typedef int (* t_injectSyncCallback)(SYNC_EVENT ev, void *management);

@interface PEPSync ()

@property (nonatomic, nonnull) PEPQueue *queue;
@property (nonatomic, nullable) NSThread *syncThread;
@property (nonatomic, nullable) NSConditionLock *conditionLockForJoiningSyncThread;
/// Used to block messageToSend() until the client configured a passphrase.
@property (atomic, nullable) dispatch_group_t blockmessageToSendGroup;
/// Object used for synchronizing modifications of `blockmessageToSendGroup`.
@property (atomic, nonnull) NSObject *lockObjectBlockmessageToSendGroupChanges;
/// True if someone called `shutdown()`
@property (atomic) BOOL shutdownRequested;

/// The session created and used by the sync loop
@property (nonatomic, nullable) PEPInternalSession *syncLoopSession;

/// @Return: The callback for message sending that should be used on every session init.
+ (t_messageToSendCallback)messageToSendCallback;

/// @Return: The callback for injectiong sync messages that should be used on every session init.
+ (t_injectSyncCallback)injectSyncCallback;

/// @Return: The callback for ensure_passphrase that should be used on every session init.
+ (ensure_passphrase_t)ensurePassphraseCallback;

- (PEP_STATUS)messageToSend:(struct _message * _Nullable)msg;

- (int)injectSyncEvent:(SYNC_EVENT)event isFromShutdown:(BOOL)isFromShutdown;

- (PEP_STATUS)notifyHandshake:(pEp_identity *)me
                      partner:(pEp_identity *)partner
                       signal:(sync_handshake_signal)signal;

- (SYNC_EVENT)retrieveNextSyncEvent:(time_t)threshold;

@end

// MARK: - Callbacks called by the engine, used in session init

static PEP_STATUS s_messageToSendObjc(struct _message * _Nullable msg)
{
    PEPSync *pEpSync = [PEPSync sharedInstance];

    if (pEpSync) {
        return [pEpSync messageToSend:msg];
    } else {
        return PEP_SYNC_NO_NOTIFY_CALLBACK;
    }
}

static int s_inject_sync_event(SYNC_EVENT ev, void *management)
{
    PEPSync *pEpSync = [PEPSync sharedInstance];

    if (pEpSync) {
        // The inject comes from the engine, so we know it's not the
        // adapter client calling shutdown.
        return [pEpSync injectSyncEvent:ev isFromShutdown:NO];
    } else {
        return 1;
    }
}

static PEP_STATUS s_ensure_passphrase(PEP_SESSION session, const char *fpr)
{
    PEP_STATUS status = (PEP_STATUS) [PEPPassphraseUtil
                                      runWithPasswordsSession:session
                                      block:^PEP_STATUS(PEP_SESSION session) {
        return probe_encrypt(session, fpr);
    }];

    return status;
}

// MARK: - Callbacks called by the engine, used in register_sync_callbacks

static PEP_STATUS s_notifyHandshake(pEp_identity *me,
                                    pEp_identity *partner,
                                    sync_handshake_signal signal)
{
    PEPSync *pEpSync = [PEPSync sharedInstance];

    if (pEpSync) {
        return [pEpSync notifyHandshake:me partner:partner signal:signal];
    } else {
        return PEP_SYNC_NO_NOTIFY_CALLBACK;
    }
}

static SYNC_EVENT s_retrieve_next_sync_event(void *management, unsigned threshold)
{
    PEPSync *sync = [PEPSync sharedInstance];
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

+ (ensure_passphrase_t)ensurePassphraseCallback
{
    return s_ensure_passphrase;
}

+ (PEP_SESSION)createSession:(NSError **)error
{
    PEP_SESSION session = NULL;

    PEP_STATUS status = init(&session,
                             [PEPSync messageToSendCallback],
                             [PEPSync injectSyncCallback],
                             [PEPSync ensurePassphraseCallback]);

    if (status != PEP_STATUS_OK) {
        if (error) {
            *error = [NSError errorWithPEPStatusInternal:status];
            LogError(@"error creating session: %@", *error);
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
        _lockObjectBlockmessageToSendGroupChanges = [NSObject new];
        _shutdownRequested = NO;
    }
    return self;
}

- (void)startup
{
    self.shutdownRequested = NO;
    [self stopWaiting];

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

    self.conditionLockForJoiningSyncThread = [[NSConditionLock alloc] initWithCondition:NO];
    [theSyncThread start];
}

- (void)shutdown
{
    self.shutdownRequested = YES;
    [self stopWaiting];

    if (self.syncThread) {
        [self injectSyncEvent:nil isFromShutdown:YES];
    }
}

- (void)handleNewPassphraseConfigured {
    [self stopWaiting];
}

// MARK: - Internal

+ (PEPSync * _Nullable)sharedInstance
{
    return s_pEpSync;
}

// MARK: - Private

- (void)assureMainSessionExists
{
    PEPInternalSession *session __attribute__((unused)) = [PEPSessionProvider session];
}

- (void)syncThreadLoop:(id)object
{
    [self.conditionLockForJoiningSyncThread lock];

    LogInfo(@"trying to start the sync loop");

    self.syncLoopSession = [PEPSessionProvider session];

    if (self.syncLoopSession) {
        PEP_STATUS status = register_sync_callbacks(self.syncLoopSession.session,
                                                    nil,
                                                    s_notifyHandshake,
                                                    s_retrieve_next_sync_event);
        if (status == PEP_STATUS_OK) {
            status = do_sync_protocol(self.syncLoopSession.session, nil);
            if (status != PEP_STATUS_OK) {
                LogError(@"do_sync_protocol returned PEP_STATUS %d", status);
                LogInfo(@"sync loop is NOT running");
            }
            unregister_sync_callbacks(self.syncLoopSession.session);
        } else {
            LogError(@"register_sync_callbacks returned PEP_STATUS %d", status);
            LogInfo(@"sync loop is NOT running");
        }
    } else {
        LogError(@"could not create session for starting the sync loop");
    }

    LogInfo(@"sync loop finished")

    self.syncLoopSession = nil;
    self.syncThread = nil;

    [self.conditionLockForJoiningSyncThread unlockWithCondition:YES];
}

/// Handles the sending of an engine provided message without caring about freeing it.
- (PEP_STATUS)messageToSendHelper:(struct _message * _Nullable)msg
{
    [self blockUntilPassphraseIsEnteredIfRequired];

    if (self.shutdownRequested) {
        // The client has signalled that she was unable to provide a passphrase by calling
        // `shutdown()`.
        // We signal the same to the Engine.
        return PEP_SYNC_NO_CHANNEL;
    }

    if (msg == NULL && [NSThread currentThread] == self.syncThread) {
        static NSMutableArray *passphrasesCopy = nil;
        static BOOL makeNewCopy = YES;

        if (makeNewCopy) {
            passphrasesCopy = [NSMutableArray
                               arrayWithArray:[self.syncLoopSession.passphraseCache passphrases]];

            if (self.syncLoopSession.passphraseCache.storedPassphrase) {
                [passphrasesCopy
                 insertObject:self.syncLoopSession.passphraseCache.storedPassphrase
                 atIndex:0];
            }

            if ([passphrasesCopy count] == 0) {
                makeNewCopy = YES;
                [self nextCallMustWait];
                return PEP_PASSPHRASE_REQUIRED;
            } else {
                makeNewCopy = NO;
            }
        }

        if ([passphrasesCopy count] == 0) {
            makeNewCopy = YES;
            [self nextCallMustWait];
            return PEP_WRONG_PASSPHRASE;
        } else {
            NSString *password = [passphrasesCopy firstObject];
            [passphrasesCopy removeObjectAtIndex:0];
            [self.syncLoopSession configurePassphrase:password error:nil];
            return PEP_STATUS_OK;
        }
    } else if (msg != NULL) {
        if (self.sendMessageDelegate) {
            PEPMessage *theMessage = [PEPMessage fromStruct:msg];
            return (PEP_STATUS)  [self.sendMessageDelegate sendMessage:theMessage];
        } else {
            return PEP_SYNC_NO_MESSAGE_SEND_CALLBACK;
        }
    } else {
        return PEP_SYNC_ILLEGAL_MESSAGE;
    }
}

/// Uses `messageToSendHelper` to send the message and conditionally frees
/// the engine provided message.
- (PEP_STATUS)messageToSend:(struct _message * _Nullable)msg
{
    PEP_STATUS status = [self messageToSendHelper:msg];
    if (status == PEP_STATUS_OK) {
        free(msg);
    }
    return status;
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
            [self.notifyHandshakeDelegate
             notifyHandshake:NULL
             me:nil
             partner:nil
             signal:PEPSyncHandshakeSignalStop];
        }
    }

    return 0;
}

- (PEP_STATUS)notifyHandshake:(pEp_identity *)me
                      partner:(pEp_identity *)partner
                       signal:(sync_handshake_signal)signal
{
    if (self.notifyHandshakeDelegate) {
        PEPIdentity *meIdentity = [PEPIdentity fromStruct:me];
        PEPIdentity *partnerIdentity = partner != nil ? [PEPIdentity fromStruct:partner] : nil;
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

// MARK: Blocking (messageToSend)

- (void)blockUntilPassphraseIsEnteredIfRequired {
    if (self.blockmessageToSendGroup) {
        dispatch_group_wait(self.blockmessageToSendGroup, DISPATCH_TIME_FOREVER);
    }
}

- (void)nextCallMustWait {
    @synchronized (self.blockmessageToSendGroup) {
        if (!self.blockmessageToSendGroup) {
            self.blockmessageToSendGroup = dispatch_group_create();
        }
        dispatch_group_enter(self.blockmessageToSendGroup);
    }
}

- (void)stopWaiting {
    @synchronized (self.blockmessageToSendGroup) {
        if (self.blockmessageToSendGroup) {
            dispatch_group_leave(self.blockmessageToSendGroup);
            self.blockmessageToSendGroup = nil;
        }
    }
}

@end
