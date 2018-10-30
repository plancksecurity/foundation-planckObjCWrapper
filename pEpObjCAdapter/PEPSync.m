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
#import "PEPLock.h"
#import "PEPObjCAdapter.h"
#import "NSError+PEP.h"

// MARK: - Declare internals

typedef PEP_STATUS (* t_messageToSendCallback)(struct _message *msg);
typedef int (* t_injectSyncCallback)(SYNC_EVENT ev, void *management);

@interface PEPSync ()

+ (PEPSync * _Nullable)instance;

@property (nonatomic, nullable, weak) id<PEPSyncSendMessageDelegate> syncSendMessageDelegate;
@property (nonatomic, nullable, weak) id<PEPNotifyHandshakeDelegate> notifyHandshakeDelegate;
@property (nonatomic, nonnull) PEPQueue *queue;
@property (nonatomic, nullable) NSThread *syncThread;

/**
 @Return: The callback for message sending that should be used on every session init.
 */
+ (t_messageToSendCallback)messageToSendCallback;

/**
 @Return: The callback for injectiong sync messages that should be used on every session init.
 */
+ (t_injectSyncCallback)injectSyncCallback;

- (int)injectSyncEvent:(SYNC_EVENT)event;
- (SYNC_EVENT)retrieveNextSyncEvent:(time_t)threshold;

@end

// MARK: - Callbacks called by the engine, used in session init

static PEP_STATUS messageToSendObjc(struct _message *msg)
{
    id<PEPSyncSendMessageDelegate> delegate = [[PEPSync instance] syncSendMessageDelegate];
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

    if (!pEpSync) {
        pEpSync = (PEPSync *) CFBridgingRelease(management);
    }

    if (pEpSync) {
        return [pEpSync injectSyncEvent:ev];
    } else {
        return 1;
    }
}

// MARK: - Callbacks called by the engine, used in register_sync_callbacks

static PEP_STATUS notifyHandshake(pEp_identity *me,
                                  pEp_identity *partner,
                                  sync_handshake_signal signal)
{
    return PEP_STATUS_OK;
}

static SYNC_EVENT retrieve_next_sync_event(void *management, time_t threshold)
{
    PEPSync *sync = (PEPSync *) CFBridgingRelease(management);
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

- (void)startup
{
    NSThread *theSyncThread = [[NSThread alloc] initWithTarget:self
                                                      selector:@selector(syncThreadLoop:)
                                                        object:nil];
    self.syncThread = theSyncThread;
}

- (void)shutdown
{
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

- (void)syncThreadLoop:(id)object {
    NSError *error = nil;
    PEP_SESSION session = [PEPSync createSession:&error];

    if (session) {
    } else {
    }

    [PEPSync releaseSession:session];
}

- (int)injectSyncEvent:(SYNC_EVENT)event
{
    [self.queue enqueue:[NSValue valueWithBytes:&event objCType:@encode(SYNC_EVENT)]];
    return 0;
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
