//
//  pEpiOSAdapter.m
//  pEpiOSAdapter
//
//  Created by Volker Birk on 28.04.15.
//  Copyright (c) 2015 p≡p. All rights reserved.
//

@import Foundation;

#import "PEPiOSAdapter.h"
#import "MCOAbstractMessage+PEPMessage.h"
#import "PEPQueue.h"
#include "keymanagement.h"

const char* _Nullable SystemDB = NULL;

int examine_identity(pEp_identity *ident, void *management)
{
    PEPQueue *q = (__bridge PEPQueue *)management;
    
    NSMutableDictionary *identity = [[NSMutableDictionary alloc] init];
    PEP_identityFromStruct(identity, ident);
    
    [q enqueue:identity];
    return 0;
}

static pEp_identity *retrieve_next_identity(void *management)
{
    PEPQueue *q = (__bridge PEPQueue *)management;
    
    // Dequeue is a blocking operation
    // that returns nil when queue is killed
    NSDictionary *ident = [q dequeue];
    
    if (ident)
        return PEP_identityToStruct(ident);
    else
        return NULL;
}

@implementation PEPiOSAdapter

+ (NSString *) getBundlePathFor: (NSString *) filename
{
    return nil;
}

+ (const char * _Nullable) copyAssetIntoDocumentsDirectory:(NSBundle *)rootBundle
                                                          :(NSString *)bundleName
                                                          :(NSString *)fileName{
    
    // Set the documents directory path to the documentsDirectory property.
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    if(!(bundleName && fileName))
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
    return [destinationPath UTF8String];
}

+ (void)setupTrustWordsDB:(NSBundle *)rootBundle{
    SystemDB = [PEPiOSAdapter copyAssetIntoDocumentsDirectory:rootBundle
                                                             :@"pEpTrustWords.bundle"
                                                             :@"system.db"];
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
    
    do_keymanagement(retrieve_next_identity, (__bridge void *)queue);
    
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
    register_examine_function(session, examine_identity, (__bridge void *)queue);
}

@end
