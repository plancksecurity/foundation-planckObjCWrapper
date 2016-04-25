//
//  pEpiOSAdapter.m
//  pEpiOSAdapter
//
//  Created by Volker Birk on 28.04.15.
//  Copyright (c) 2015 p≡p. All rights reserved.
//

@import Foundation;

#import "PEPiOSAdapter.h"
#import "PEPIOSAdapter+Internal.h"
#import "PEPMessage.h"
#include "keymanagement.h"

const char* _Nullable SystemDB = NULL;

int examine_identity(pEp_identity *identity, void *management)
{
    id<PEPKeyManagementDelegate> keyManagementDelegate =
        [PEPiOSAdapter getkeyManagementDelegate];
    
    PEPQueue *q = [PEPiOSAdapter getQueue];
    
    // Make a copy of given identity, to hold it in the queue.
    pEp_identity *ident_dup = identity_dup(identity);
    if (ident_dup == NULL)
    {
        // XXX Should examine really return just int ?
        return PEP_OUT_OF_MEMORY;
    }
    
    NSValue *identity_p = [NSValue valueWithPointer:ident_dup];
    [keyManagementDelegate managementBusy];
    [q enqueue:identity_p];
    return 0;
}

static pEp_identity *retrieve_next_identity(
        pEp_identity *processed_identity,
        void *management,
        bool *allow_keyserver_lookup
    )
{
    id<PEPKeyManagementDelegate> keyManagementDelegate =
    [PEPiOSAdapter getkeyManagementDelegate];
    
    PEPQueue *q = [PEPiOSAdapter getQueue];
    
    *allow_keyserver_lookup = false;
    
    if(processed_identity)
    {
        // Signal the app :
        //    - something happened with *processed_identity
        //    - background processing is finished

        // XXX where should identity be deallocated ? ARC ?

        [keyManagementDelegate identityWasUpdated:
         PEP_identityDictFromStruct(processed_identity)];
    }
    else
    {
        // This happens at first loop of key amangement
        [keyManagementDelegate managementStarted];
    }
    
    if (q.count == 0)
    {
        [keyManagementDelegate managementIdle];
    }
    
    // Dequeue is a blocking operation that returns nil when queue is killed
    
    NSValue *next_ident = [q dequeue];
    
    if (next_ident)
    {
        // Signal the app :
        //    - something is gonna happen with *next_ident
        //    - background processing is starting
        
        // XXX where should identity be deallocated ? ARC ?
        
        [keyManagementDelegate identityWillBeUpdated:
         PEP_identityDictFromStruct((pEp_identity *)[next_ident pointerValue])];
        
        *allow_keyserver_lookup = keyManagementDelegate.allowKeyserverLookup;
        
        return [next_ident pointerValue];
    }
    else
    {
        // Signal the app management thread is gonna finish.
        [keyManagementDelegate managementFinishing];
        
        return NULL;
    }
}

@implementation PEPiOSAdapter

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
    NSURL *homeUrl = [self createApplicationDirectory];
    setenv("HOME", [[homeUrl path] cStringUsingEncoding:NSUTF8StringEncoding], 1);

    // create and set temp directory
    NSURL *tmpDirUrl = [NSURL fileURLWithPath:NSTemporaryDirectory() isDirectory:YES];
    setenv("TEMP", [[tmpDirUrl path] cStringUsingEncoding:NSUTF8StringEncoding], 1);

    return homeUrl;
}

+ (NSString *) getBundlePathFor: (NSString *) filename
{
    return nil;
}

+ (NSString *) copyAssetIntoDocumentsDirectory:(NSBundle *)rootBundle
                                                          :(NSString *)bundleName
                                                          :(NSString *)fileName{

    NSURL *homeUrl = [PEPiOSAdapter createAndSetHomeDirectory];
    NSString *documentsDirectory = [homeUrl path];
    
    if(!(documentsDirectory && bundleName && fileName))
        return nil;
    
    // Check if the database file exists in the documents directory.
    NSString *destinationPath = [documentsDirectory stringByAppendingPathComponent:fileName];
    if (![[NSFileManager defaultManager] fileExistsAtPath:destinationPath]) {
        
        // The file does not exist in the documents directory, so copy it from bundle now.
        NSBundle *bundleObj = [NSBundle bundleWithPath: [[rootBundle resourcePath] stringByAppendingPathComponent: bundleName]];
        
        if(!bundleObj)
            return nil;
        
        NSString *sourcePath =[[bundleObj resourcePath] stringByAppendingPathComponent: fileName];
        
        NSError *error;
        [[NSFileManager defaultManager] copyItemAtPath:sourcePath toPath:destinationPath error:&error];
        
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
    NSString *systemDBPath = [PEPiOSAdapter copyAssetIntoDocumentsDirectory:rootBundle
                                                                           :@"pEpTrustWords.bundle"
                                                                           :@"system.db"];
    if (SystemDB) {
        free((void *) SystemDB);
    }
    SystemDB = strdup(systemDBPath.UTF8String);
}

+ (void)setupTrustWordsDB
{
    [PEPiOSAdapter setupTrustWordsDB:[NSBundle mainBundle]];
}

static PEPQueue *queue = nil;
static NSThread *keyManagement_thread = nil;
static NSConditionLock *joinCond = nil;
static id<PEPKeyManagementDelegate> keyManagementDelegate;

+ (void)keyManagementThread:(id)object
{
    [joinCond lock];

    do_keymanagement(retrieve_next_identity, "NULL");
    
    // Set and signal join()
    [joinCond unlockWithCondition:YES];
}

+ (void)setKeyManagementDelegate:(id<PEPKeyManagementDelegate>)delegate
{
    keyManagementDelegate = delegate;
}

+ (void)startKeyManagement
{
    if (!queue)
    {
        queue = [[PEPQueue alloc]init];
        
        // There is no join() call on NSThreads.
        joinCond = [[NSConditionLock alloc] initWithCondition:NO];
        
        keyManagement_thread = [[NSThread alloc]
                                initWithTarget:self
                                selector:@selector(keyManagementThread:)
                                object:nil];
        [keyManagement_thread start];
    }
}

+ (void)stopKeyManagement
{
    
    if (queue)
    {
        // Flush queue and kick the consumer
        [queue kill];
        
        // Thread then bailout. Wait fo that.
        [joinCond lockWhenCondition:YES];
        [joinCond unlock];
        
        keyManagement_thread = nil;
        queue = nil;
        joinCond = nil;
    }
}

+ (void)registerExamineFunction:(PEP_SESSION)session
{
    register_examine_function(session,
                              examine_identity,
                              "NULL");
}

+ (PEPQueue*)getQueue
{
    return queue;
}

+ (id<PEPKeyManagementDelegate>)getkeyManagementDelegate
{
    return keyManagementDelegate;
}


@end
