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
#import "NSString+NormalizePassphrase.h"

#import "keymanagement.h"
#import "mime.h"
#import "message.h"

const PEP_decrypt_flags PEP_decrypt_flag_none = 0x0;

/**
 The pEp part of the home directory (where pEp is supposed to store data).
 */
static NSString * const s_pEpHomeComponent = @"pEp_home";

#if TARGET_OS_IPHONE
// marked for iOS to think about what we want on macOS
const char* _Nullable perMachineDirectory = NULL;
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

#pragma mark - Passphrase for own keys

+ (BOOL)configurePassphraseForNewKeys:(NSString * _Nullable)passphrase
                                error:(NSError * _Nullable * _Nullable)error
{
    if (passphrase == nil) {
        // TODO: Set for future
        return YES;
    } else {
        NSString *normalizedPassphrase = [passphrase normalizedPassphraseWithError:error];

        if (normalizedPassphrase == nil) {
            return NO;
        }

        // TODO: Set for future
        return YES;
    }
}

#pragma mark - DB PATHS

+ (void)initialize
{
    s_homeURL = [self createApplicationDirectory];

    // The engine will put its per_user_directory under this directory.
    setenv("HOME", [[s_homeURL path] cStringUsingEncoding:NSUTF8StringEncoding], 1);

    // This sets the engine's per_machine_directory under iOS.
    [self setPerMachineDirectory:s_homeURL];
}

+ (NSURL *)homeURL
{
    return s_homeURL;
}

/**
 Looks up (and creates if necessary) a pEp directory under "Application Support".

 @return A URL pointing a pEp directory under "Application Support".
 */
+ (NSURL *)createApplicationDirectoryOSX
{
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
        dirPath = [[appSupportDir objectAtIndex:0] URLByAppendingPathComponent:s_pEpHomeComponent];

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

/**
 Looks up the shared directory for pEp apps under iOS and makes sure it exists.

 @return A URL pointing a pEp directory in the app container.
*/
+ (NSURL *)createApplicationDirectoryiOS
{
    NSString *appGroupId = @"group.security.pep.pep4ios";
    NSFileManager *fm = [NSFileManager defaultManager];
    NSURL *containerUrl = [fm containerURLForSecurityApplicationGroupIdentifier:appGroupId];
    NSLog(@"containerUrl '%@'", containerUrl);

    if (containerUrl == nil) {
        // Will happen when running tests, so fall back.
        NSArray *appSupportDir = [fm URLsForDirectory:NSApplicationSupportDirectory
                                            inDomains:NSUserDomainMask];
        containerUrl = [appSupportDir lastObject];
    }

    if (containerUrl == nil) {
        NSLog(@"ERROR: No app container, no application support directory.");
    }

    NSURL *dirPath = [containerUrl URLByAppendingPathComponent:s_pEpHomeComponent];

    // If the directory does not exist, this method creates it.
    NSError *theError = nil;
    if (![fm createDirectoryAtURL:dirPath withIntermediateDirectories:YES
                       attributes:nil error:&theError]) {
        NSLog(@"ERROR: Could not create pEp home directory, directly writing to app container instead.");
    }

    return dirPath;
}

/**
 Looks up the shared directory for pEp apps under iOS and makes sure it exists.

 Derived settings:

 * $HOME (the engine uses that).
 * The engine's per_user_directory (which is placed under $HOME).
 * The engine's per_machine_directory (see [PEPObjCAdapter setPerMachineDirectory:]).

 @return A URL pointing to as app-specific directory under the OS defined
 application support directory for the current user.
 */
+ (NSURL *)createApplicationDirectory
{
#if TARGET_OS_IPHONE
    return [self createApplicationDirectoryiOS];
#else
    return [self createApplicationDirectoryOSX];
#endif
}

/**
 Sets the directory that will be fed into the engine's per_machine_directory.

 Does not handle macOS. For macOS, either PER_MACHINE_DIRECTORY has to be defined
 (if constant), or this method has to be extended to handle it.

 @param perMachineDir The url to use as the per_machine_directory directory.
 */
+ (void)setPerMachineDirectory:(NSURL *)perMachineDir
{
#if TARGET_OS_IPHONE
    if (perMachineDirectory) {
        free((void *) perMachineDirectory);
    }
    perMachineDirectory = strdup([perMachineDir path].UTF8String);
#endif
}

+ (NSString *)getBundlePathFor: (NSString *) filename
{
    return nil;
}

+ (void)copyAssetsIntoDocumentsDirectory:(NSBundle *)rootBundle
                                    bundleName:(NSString *)bundleName
                                      fileName:(NSString *)fileName {

    NSString *systemDir = [NSString stringWithUTF8String:perMachineDirectory];
    
    if(!(systemDir && bundleName && fileName))
        return;
    
    // Check if the database file exists in the documents directory.
    NSString *destinationPath = [systemDir stringByAppendingPathComponent:fileName];
    if (![[NSFileManager defaultManager] fileExistsAtPath:destinationPath]) {
        // The file does not exist in the documents directory, so copy it from bundle now.
        NSBundle *bundleObj = [NSBundle bundleWithPath:
                               [[rootBundle resourcePath]
                                stringByAppendingPathComponent: bundleName]];
        if (!bundleObj)
            return;
        
        NSString *sourcePath =[[bundleObj resourcePath] stringByAppendingPathComponent: fileName];
        
        NSError *error;
        [[NSFileManager defaultManager]
         copyItemAtPath:sourcePath toPath:destinationPath error:&error];
        
        // Check if any error occurred during copying and display it.
        if (error != nil) {
            NSLog(@"%@", [error localizedDescription]);
        }
    }
}

+ (void)setupTrustWordsDB:(NSBundle *)rootBundle {
// iOS to force us to think about macOS
#if TARGET_OS_IPHONE
    [PEPObjCAdapter copyAssetsIntoDocumentsDirectory:rootBundle
                                          bundleName:@"pEpTrustWords.bundle"
                                            fileName:@"system.db"];

#endif
}

+ (void)setupTrustWordsDB
{
    [PEPObjCAdapter setupTrustWordsDB:[NSBundle mainBundle]];
}


+ (NSString * _Nonnull)perUserDirectoryString
{
    return [NSString stringWithCString:per_user_directory() encoding:NSUTF8StringEncoding];
}

+ (NSString * _Nonnull)perMachineDirectoryString
{
    return [NSString stringWithCString:per_machine_directory() encoding:NSUTF8StringEncoding];
}

@end
