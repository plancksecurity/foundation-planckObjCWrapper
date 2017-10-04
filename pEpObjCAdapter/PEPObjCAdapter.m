//
//  pEpObjCAdapter.m
//  pEpObjCAdapter
//
//  Created by Volker Birk on 28.04.15.
//  Copyright (c) 2015 p≡p. All rights reserved.
//

@import Foundation;

#import "PEPObjCAdapter.h"
#import "PEPObjCAdapter+Internal.h"
#import "PEPMessage.h"
#include "keymanagement.h"

///////////////////////////////////////////////////////////////////////////////
//  Keyserver and Identity lookup - C part


int examine_identity(pEp_identity *ident, void *management)
{
    //PEPQueue *q = (__bridge PEPQueue *)management;
    PEPQueue *q = [PEPObjCAdapter getLookupQueue];
    
    NSDictionary *identity = PEP_identityDictFromStruct(ident);
    
    [q enqueue:identity];
    return 0;
}

static pEp_identity *retrieve_next_identity(void *management)
{
    //PEPQueue *q = (__bridge PEPQueue *)management;
    PEPQueue *q = [PEPObjCAdapter getLookupQueue];
    
    // Dequeue is a blocking operation
    // that returns nil when queue is killed
    NSDictionary *ident = [q dequeue];
    
    if (ident)
        return PEP_identityDictToStruct(ident);
    else
        return NULL;
}

///////////////////////////////////////////////////////////////////////////////
// Sync - C part

// Called by sync thread only
PEP_STATUS notify_handshake(void *unused_object, pEp_identity *me, pEp_identity *partner, sync_handshake_signal signal)
{
    id <PEPSyncDelegate> syncDelegate = [PEPObjCAdapter getSyncDelegate];
    if ( syncDelegate )
        return [syncDelegate
                notifyHandshakeWithSignal:signal
                me:PEP_identityDictFromStruct(me)
                partner:PEP_identityDictFromStruct(partner)];
    else
        return PEP_SYNC_NO_NOTIFY_CALLBACK;
}

// Called by sync thread only
PEP_STATUS message_to_send(void *unused_object, message *msg)
{
    id <PEPSyncDelegate> syncDelegate = [PEPObjCAdapter getSyncDelegate];
    if ( syncDelegate )
        return [syncDelegate sendMessage:PEP_messageDictFromStruct(msg)];
    else
        return PEP_SEND_FUNCTION_NOT_REGISTERED;
}

// called indirectly by decrypt message - any thread/session
int inject_sync_msg(void *msg, void *unused_management)
{
    PEPQueue *q = [PEPObjCAdapter getSyncQueue];
    
    [q enqueue:[NSValue valueWithPointer:msg]];
    
    return 0;
}

// Called by sync thread only
void *retrieve_next_sync_msg(void *unused_mamagement, time_t *timeout)
{
    bool needs_fastpoll = (*timeout != 0);
    
    id <PEPSyncDelegate> syncDelegate = [PEPObjCAdapter getSyncDelegate];
    if ( syncDelegate && needs_fastpoll )
        [syncDelegate fastPolling:true];
    
    PEPQueue *q = [PEPObjCAdapter getSyncQueue];

    void* result = (void*)[[q timedDequeue:timeout] pointerValue];

    if ( syncDelegate && needs_fastpoll )
        [syncDelegate fastPolling:false];
    
    return result;

}

///////////////////////////////////////////////////////////////////////////////
// DB and paths

const char* _Nullable SystemDB = NULL;
NSURL *s_homeURL;
NSLock initLock = [[NSLock alloc] init];

@implementation PEPObjCAdapter

+ (void)initialize
{
    s_homeURL = [self createApplicationDirectory];
}

+ (NSURL *)homeURL
{
    return s_homeURL;
}

+ (NSURL *)createApplicationDirectory
{
    NSString *bundleID = [[NSBundle mainBundle] bundleIdentifier];
    if (!bundleID) {
        // This can happen in unit tests
        bundleID = @"test";
    }
    NSFileManager *fm = [NSFileManager defaultManager];
    NSURL *dirPath = nil;

    // Find the application support directory in the home directory.
    NSArray *appSupportDir = [fm URLsForDirectory:NSApplicationSupportDirectory
                                        inDomains:NSUserDomainMask];
    if ([appSupportDir count] > 0)
    {
        // Append the bundle ID to the URL for the
        // Application Support directory.
        // Mainly needed for OS X, but doesn't do any harm on iOS
        dirPath = [[appSupportDir objectAtIndex:0] URLByAppendingPathComponent:bundleID];

        // If the directory does not exist, this method creates it.
        // This method is only available in OS X v10.7 and iOS 5.0 or later.
        NSError *theError = nil;
        if (![fm createDirectoryAtURL:dirPath withIntermediateDirectories:YES
                           attributes:nil error:&theError])
        {
            // Handle the error.
            return nil;
        }
    }

    return dirPath;
}

+ (NSURL *)createAndSetHomeDirectory
{
    // create and set home directory
    setenv("HOME", [[s_homeURL path] cStringUsingEncoding:NSUTF8StringEncoding], 1);

    // create and set temp directory
    NSURL *tmpDirUrl = [NSURL fileURLWithPath:NSTemporaryDirectory() isDirectory:YES];
    setenv("TEMP", [[tmpDirUrl path] cStringUsingEncoding:NSUTF8StringEncoding], 1);

    return s_homeURL;
}

+ (NSString *) getBundlePathFor: (NSString *) filename
{
    return nil;
}

+ (NSString *) copyAssetIntoDocumentsDirectory:(NSBundle *)rootBundle
                                                          :(NSString *)bundleName
                                                          :(NSString *)fileName{

    NSURL *homeUrl = [PEPObjCAdapter createAndSetHomeDirectory];
    NSString *documentsDirectory = [homeUrl path];
    
    if(!(documentsDirectory && bundleName && fileName))
        return nil;
    
    // Check if the database file exists in the documents directory.
    NSString *destinationPath = [documentsDirectory stringByAppendingPathComponent:fileName];
    if (![[NSFileManager defaultManager] fileExistsAtPath:destinationPath]) {
        // The file does not exist in the documents directory, so copy it from bundle now.
        NSBundle *bundleObj = [NSBundle bundleWithPath:
                               [[rootBundle resourcePath]
                                stringByAppendingPathComponent: bundleName]];
        
        if (!bundleObj)
            return nil;
        
        NSString *sourcePath =[[bundleObj resourcePath] stringByAppendingPathComponent: fileName];
        
        NSError *error;
        [[NSFileManager defaultManager]
         copyItemAtPath:sourcePath toPath:destinationPath error:&error];
        
        // Check if any error occurred during copying and display it.
        if (error != nil) {
            NSLog(@"%@", [error localizedDescription]);
            return nil;
        }
    }
    NSLog(@"Asset %@ copied into %@", fileName, destinationPath);
    return destinationPath;
}

+ (void)setupTrustWordsDB:(NSBundle *)rootBundle{
    NSString *systemDBPath = [PEPObjCAdapter copyAssetIntoDocumentsDirectory:rootBundle
                                                                           :@"pEpTrustWords.bundle"
                                                                           :@"system.db"];
    if (SystemDB) {
        free((void *) SystemDB);
    }
    SystemDB = strdup(systemDBPath.UTF8String);
}

+ (void)setupTrustWordsDB
{
    [PEPObjCAdapter setupTrustWordsDB:[NSBundle mainBundle]];
}

static NSMutableArray* boundSessions = nil;

+ (NSMutableArray*)boundSessions
{
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        boundSessions =  [[NSMutableArray alloc] init];
    });
    return boundSessions;
}

///////////////////////////////////////////////////////////////////////////////
//  Keyserver and Identity lookup - ObjC part

static PEPQueue *lookupQueue = nil;
static NSThread *lookupThread = nil;
static NSConditionLock *lookupThreadJoinCond = nil;

+ (void)lookupThreadRoutine:(id)object
{
    [lookupThreadJoinCond lock];

    // FIXME: do_KeyManagement asserts if management is null.
    do_keymanagement(retrieve_next_identity, "NOTNULL" /* (__bridge void *)queue */);
    
    // Set and signal join()
    [lookupThreadJoinCond unlockWithCondition:YES];
}

+ (void)startKeyserverLookup
{
    if (!lookupQueue)
    {
        lookupQueue = [[PEPQueue alloc]init];
        
        // There is no join() call on NSThreads.
        lookupThreadJoinCond = [[NSConditionLock alloc] initWithCondition:NO];
        
        lookupThread = [[NSThread alloc] initWithTarget:self selector:@selector(lookupThreadRoutine:) object:nil];
        [lookupThread start];
    }
}

+ (void)stopKeyserverLookup
{
    
    if (lookupQueue)
    {
        // Flush queue and kick the consumer
        [lookupQueue kill];
        
        // Thread then bailout. Wait for that.
        [lookupThreadJoinCond lockWhenCondition:YES];
        [lookupThreadJoinCond unlock];
        
        lookupThread = nil;
        lookupQueue = nil;
        lookupThreadJoinCond = nil;
    }
}

+ (void)registerExamineFunction:(PEP_SESSION)session
{
    register_examine_function(session, examine_identity, NULL /* (__bridge void *)queue */);
}

+ (PEPQueue*)getLookupQueue
{
    return lookupQueue;
}

///////////////////////////////////////////////////////////////////////////////
// Sync - ObjC part

static PEPQueue *syncQueue = nil;
static NSThread *syncThread = nil;
static NSConditionLock *syncThreadJoinCond = nil;
static PEP_SESSION sync_session = NULL;
static id <PEPSyncDelegate> syncDelegate = nil;


+ (void)syncThreadRoutine:(id)object
{
    [syncThreadJoinCond lock];
    

    PEP_STATUS status;

    status = do_sync_protocol(sync_session,
                              /* "object" : notifying, sending (unused) */
                              "NOTNULL");
    
    // TODO : log something if status not as expected
    
    
    [syncThreadJoinCond unlockWithCondition:YES];
}

+ (void)attachSyncSession:(PEP_SESSION)session
{
    if(sync_session)
        attach_sync_session(session, sync_session);
}

+ (void)detachSyncSession:(PEP_SESSION)session
{
    detach_sync_session(session);
}

+ (void)startSync:(id <PEPSyncDelegate>)delegate;
{
    syncDelegate = delegate;
    
    if (!syncQueue)
    {
        syncQueue = [[PEPQueue alloc]init];
        
        syncThreadJoinCond = [[NSConditionLock alloc] initWithCondition:NO];

        [initLock lock];
        PEP_STATUS status = init(&sync_session);
        [initLock unlock];
        if (status != PEP_STATUS_OK) {
            return;
        }
        
        register_sync_callbacks(sync_session,
                                /* "management" : queuing (unused) */
                                "NOTNULL",
                                message_to_send,
                                notify_handshake,
                                inject_sync_msg,
                                retrieve_next_sync_msg);
        
        syncThread = [[NSThread alloc]
                      initWithTarget:self
                      selector:@selector(syncThreadRoutine:)
                      object:nil];

        [syncThread start];
    }

    NSMutableArray* sessionList = [PEPObjCAdapter boundSessions];
    NSValue* v;
    PEPSession* session;
    @synchronized (sessionList) {
        for (v in sessionList) {
            session = [v nonretainedObjectValue];
            [PEPObjCAdapter attachSyncSession:[session session]];
        }
    }
}

+ (void)stopSync
{
    NSMutableArray* sessionList = [PEPObjCAdapter boundSessions];
    NSValue* v;
    PEPSession* session;
    @synchronized (sessionList) {
        for (v in sessionList) {
            session = [v nonretainedObjectValue];
            [PEPObjCAdapter detachSyncSession:[session session]];
        }
    }
    
    syncDelegate = nil;
    
    if (syncQueue)
    {
        [syncQueue purge:^(id item){
            sync_msg_t *msg = [item pointerValue];
            free_sync_msg(msg);
        }];
        
        [syncThreadJoinCond lockWhenCondition:YES];
        [syncThreadJoinCond unlock];

        [initLock lock];
        release(sync_session);
        [initLock unlock];
        
        sync_session = NULL;
        syncThread = nil;
        syncQueue = nil;
        syncThreadJoinCond = nil;
    }
}

+ (PEPQueue*)getSyncQueue
{
    return syncQueue;
}

+ (id <PEPSyncDelegate>)getSyncDelegate
{
    return syncDelegate;
}

+ (void)bindSession:(PEPSession*)session
{
    NSMutableArray* sessionList = [PEPObjCAdapter boundSessions];
    @synchronized (sessionList) {
        [sessionList addObject:[NSValue valueWithNonretainedObject:session]];
    }

    [PEPObjCAdapter registerExamineFunction:[session session]];
    [PEPObjCAdapter attachSyncSession:[session session]];
}

+ (void)unbindSession:(PEPSession*)session
{
    [PEPObjCAdapter detachSyncSession:[session session]];
    
    NSMutableArray* sessionList = [PEPObjCAdapter boundSessions];
    @synchronized (sessionList) {
        [sessionList removeObject:[NSValue valueWithNonretainedObject:session]];
    }

}



@end
