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
    
    while (![q count])
        usleep(100);
    
    NSDictionary *ident = [q dequeue];
    
    if ([ident objectForKey:@"THE_END"])
        return NULL;
    else
        return PEP_identityToStruct(ident);
}

@implementation PEPiOSAdapter


#define BUNDLE_NAME       @"pEpTrustWords.bundle"
#define BUNDLE_PATH       [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent: BUNDLE_NAME]
#define BUNDLE_OBJ        [NSBundle bundleWithPath: BUNDLE_PATH]

+ (NSString *) getBundlePathFor: (NSString *) filename
{
    NSBundle *libBundle = BUNDLE_OBJ;
    if( libBundle && filename ){
        return [[libBundle resourcePath] stringByAppendingPathComponent: filename];
    }
    return nil;
}

+ (const char * _Nullable) copyAssetIntoDocumentsDirectory:(NSString *)dbFilename{
    
    // Set the documents directory path to the documentsDirectory property.
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    // Check if the database file exists in the documents directory.
    NSString *destinationPath = [documentsDirectory stringByAppendingPathComponent:dbFilename];
    if (![[NSFileManager defaultManager] fileExistsAtPath:destinationPath]) {
        
        // The database file does not exist in the documents directory, so copy it from the main bundle now.
        NSString *sourcePath = [PEPiOSAdapter getBundlePathFor: dbFilename];
        NSError *error;
        [[NSFileManager defaultManager] copyItemAtPath:sourcePath toPath:destinationPath error:&error];
        
        // Check if any error occurred during copying and display it.
        if (error != nil) {
            NSLog(@"%@", [error localizedDescription]);
        }
    }
    return [destinationPath UTF8String];
}

+ (void)setupTrustWordsDB
{
    SystemDB = [PEPiOSAdapter copyAssetIntoDocumentsDirectory:@"system.db"];
}

static PEPQueue *queue = nil;
static NSThread *keyserver_thread = nil;

+ (void)keyserverThread:(id)object
{
    do_keymanagement(retrieve_next_identity, (__bridge void *)queue);
}

+ (void)startKeyserverLookup
{
    if (!queue) {
        queue = [PEPQueue init];
        keyserver_thread = [[NSThread alloc] initWithTarget:self selector:@selector(keyserverThread:) object:nil];
        [keyserver_thread start];
    }
}

+ (void)stopKeyserverLookup
{
    
    if (queue) {
        [queue enqueue:[NSDictionary dictionaryWithObject:@"THE_END" forKey:@"THE_END"]];
        keyserver_thread = nil;
        queue = nil;
    }
}

+ (void)registerExamineFunction:(PEP_SESSION)session
{
    register_examine_function(session, examine_identity, (__bridge void *)queue);
}

@end
