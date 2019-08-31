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
#import "PEPMessageUtil.h"
#import "NSError+PEP.h"

#import "keymanagement.h"
#import "mime.h"
#import "message.h"

const PEP_decrypt_flags PEP_decrypt_flag_none = 0x0;

#if TARGET_OS_IPHONE
// macOS must use Engine's default directoties to potentially share the data with other apps.
const char* _Nullable perMachineDirectory = NULL;
const char* _Nullable perUserDirectory = NULL;
#endif

NSURL *s_homeURL;

static BOOL s_unEncryptedSubjectEnabled = NO;
static BOOL s_passiveModeEnabled = NO;

@implementation PEPObjCAdapter

#pragma mark - SUBJECT PROTECTION

+ (BOOL)unEncryptedSubjectEnabled;
{
    return s_unEncryptedSubjectEnabled;
}

+ (void)setUnEncryptedSubjectEnabled:(BOOL)enabled;
{
    s_unEncryptedSubjectEnabled = enabled;
}

#pragma mark - Passive Mode

+ (BOOL)passiveModeEnabled
{
    return s_passiveModeEnabled;
}

+ (void)setPassiveModeEnabled:(BOOL)enabled
{
    s_passiveModeEnabled = enabled;
}

#pragma mark - DB PATHS

+ (void)initialize
{
    s_homeURL = [self createApplicationDirectory];
    [self setHomeDirectory:s_homeURL]; // Important, defines $HOME for the engine
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

+ (void)setHomeDirectory:(NSURL *)homeDir
{
#if TARGET_OS_IPHONE
    if (perUserDirectory) {
        free((void *) perUserDirectory);
    }
    perUserDirectory = strdup([homeDir path].UTF8String);
#endif
}

+ (NSString *)getBundlePathFor: (NSString *) filename
{
    return nil;
}

+ (NSString *)copyAssetsIntoDocumentsDirectory:(NSBundle *)rootBundle
                                    bundleName:(NSString *)bundleName
                                      fileName:(NSString *)fileName {
    
    NSURL *homeUrl = s_homeURL;
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
    return destinationPath;
}

+ (void)setupTrustWordsDB:(NSBundle *)rootBundle {
#if TARGET_OS_IPHONE
    NSString *systemDBPath = [PEPObjCAdapter
                              copyAssetsIntoDocumentsDirectory:rootBundle
                              bundleName:@"pEpTrustWords.bundle"
                              fileName:@"system.db"];
    if (perMachineDirectory) {
        free((void *) perMachineDirectory);
    }
    perMachineDirectory = strdup(systemDBPath.UTF8String);
#endif
}

+ (void)setupTrustWordsDB
{
    [PEPObjCAdapter setupTrustWordsDB:[NSBundle mainBundle]];
}

@end
