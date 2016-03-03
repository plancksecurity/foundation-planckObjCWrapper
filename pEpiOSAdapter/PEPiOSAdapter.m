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

int examine_identity(pEp_identity *ident, void *management)
{
    //PEPQueue *q = (__bridge PEPQueue *)management;
    PEPQueue *q = [PEPiOSAdapter getQueue];
    
    NSMutableDictionary *identity = PEP_identityFromStruct(ident);
    
    [q enqueue:identity];
    return 0;
}

static pEp_identity *retrieve_next_identity(void *management)
{
    //PEPQueue *q = (__bridge PEPQueue *)management;
    PEPQueue *q = [PEPiOSAdapter getQueue];
    
    // Dequeue is a blocking operation
    // that returns nil when queue is killed
    NSDictionary *ident = [q dequeue];
    
    if (ident)
        return PEP_identityToStruct(ident);
    else
        return NULL;
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
static NSThread *keyserver_thread = nil;
static NSConditionLock *joinCond = nil;

+ (void)keyserverThread:(id)object
{
    [joinCond lock];

    // FIXME: do_KeyManagement asserts if management is null.
    do_keymanagement(retrieve_next_identity, "NOTNULL" /* (__bridge void *)queue */);
    
    // Set and signal join()
    [joinCond unlockWithCondition:YES];
}

+ (void)startKeyserverLookup
{
    if (!queue)
    {
        queue = [[PEPQueue alloc]init];
        
        // There is no join() call on NSThreads.
        joinCond = [[NSConditionLock alloc] initWithCondition:NO];
        
        keyserver_thread = [[NSThread alloc] initWithTarget:self selector:@selector(keyserverThread:) object:nil];
        [keyserver_thread start];
    }
}

+ (void)stopKeyserverLookup
{
    
    if (queue)
    {
        // Flush queue and kick the consumer
        [queue kill];
        
        // Thread then bailout. Wait fo that.
        [joinCond lockWhenCondition:YES];
        [joinCond unlock];
        
        keyserver_thread = nil;
        queue = nil;
        joinCond = nil;
    }
}

+ (void)registerExamineFunction:(PEP_SESSION)session
{
    register_examine_function(session, examine_identity, NULL /* (__bridge void *)queue */);
}

+ (PEPQueue*)getQueue
{
    return queue;
}

@end
