//
//  pEpObjCAdapter.m
//  pEpObjCAdapter
//
//  Created by Volker Birk on 28.04.15.
//  Copyright (c) 2015 p≡p. All rights reserved.
//

@import Foundation;

#ifdef IS_IOS_BUILD
#import <pEp4iosIntern/pEp4iosIntern.h>
#endif

#import "PEPObjCAdapter.h"
#import "PEPObjCAdapter+Internal.h"
#import "NSError+PEP.h"
#import "NSString+NormalizePassphrase.h"
#import "PEPInternalSession.h"
#import "PEPPassphraseCache.h"

#import "keymanagement.h"
#import "mime.h"
#import "message.h"
#import "message_api.h"

const PEP_decrypt_flags PEP_decrypt_flag_none = 0x0;

/**
 The pEp part of the home directory (where pEp is supposed to store data).
 */
static NSString * const s_pEpHomeComponent = @"pEp_home";

#if TARGET_OS_IPHONE
const char* _Nullable perMachineDirectory = NULL;
#endif

NSURL *s_homeURL;

static BOOL s_unEncryptedSubjectEnabled = NO;
static BOOL s_passiveModeEnabled = NO;
static NSString *s_passphraseForNewKeys = nil;
static id<PEPPassphraseProviderProtocol> s_passphraseProvider = nil;

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
        s_passphraseForNewKeys = nil;
        [[PEPPassphraseCache sharedInstance] setStoredPassphrase:passphrase];

        return YES;
    } else {
        NSString *normalizedPassphrase = [passphrase normalizedPassphraseWithError:error];

        if (normalizedPassphrase == nil) {
            return NO;
        }

        s_passphraseForNewKeys = normalizedPassphrase;
        [[PEPPassphraseCache sharedInstance] setStoredPassphrase:passphrase];

        return YES;
    }
}

+ (NSString * _Nullable)passphraseForNewKeys
{
    return s_passphraseForNewKeys;
}

#pragma mark - Passphrase Provider

+ (void)setPassphraseProvider:(id<PEPPassphraseProviderProtocol> _Nullable)passphraseProvider
{
    s_passphraseProvider = passphraseProvider;
}

+ (id<PEPPassphraseProviderProtocol> _Nullable)passphraseProvider
{
    return s_passphraseProvider;
}

#pragma mark - DB PATHS

+ (void)initialize
{
    [self setupPerUserDirectory];
    [self setupPerMachineDirectory];
}

+ (NSURL *)homeURL
{
    return s_homeURL;
}

+ (void)setupPerUserDirectory {
    // The Engine uses the home env as per-user-directory. We hijack that on iOS.
#if TARGET_OS_IPHONE
    s_homeURL = [self createApplicationDirectory];
    // The engine will put its per_user_directory under this directory.
    setenv("HOME", [[s_homeURL path] cStringUsingEncoding:NSUTF8StringEncoding], 1);
#else
    // For macOS there is nothing toDo.
#endif
}

+ (void)setupPerMachineDirectory {
#if TARGET_OS_IPHONE
    [self setPerMachineDirectory:[self homeURL]];
#else
    NSURL *macPerMachineDir = [[NSURL alloc] initWithString:[@"/Library/Application Support/pEp" stringByAddingPercentEncodingWithAllowedCharacters:NSCharacterSet.URLPathAllowedCharacterSet]];
    [self setPerMachineDirectory:macPerMachineDir];
#endif
}

/**
 Looks up the shared directory for pEp apps under iOS and makes sure it exists.

 @return A URL pointing a pEp directory in the app container.
 */
#ifdef IS_IOS_BUILD
+ (NSURL *)createApplicationDirectoryiOS
{
    NSFileManager *fm = [NSFileManager defaultManager];
    NSURL *containerUrl = [fm containerURLForSecurityApplicationGroupIdentifier:appGroupIdentifier];
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
#endif

/**
 Looks up the shared directory for pEp apps under iOS and makes sure it exists.

 Derived settings:

 * $HOME (the engine uses that).
 * The engine's per_user_directory (which is placed under $HOME).
 * The engine's per_machine_directory (see [PEPObjCAdapter setPerMachineDirectory:]).

 @return A URL pointing to as app-specific directory under the OS defined
 application support directory for the current user.
 */
#ifdef IS_IOS_BUILD
+ (NSURL *)createApplicationDirectory
{
    return [self createApplicationDirectoryiOS];
}
#endif

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

+ (void)copyAssetsIntoDocumentsDirectory:(NSBundle *)srcBundle
                                fileName:(NSString *)fileName {
#ifdef IS_IOS_BUILD
    NSString *systemDir = [NSString stringWithUTF8String:perMachineDirectory];

    if(!(srcBundle && systemDir && fileName)) {
        return;
    }

    // Check if the database file exists in the documents directory.
    NSString *destinationPath = [systemDir stringByAppendingPathComponent:fileName];
    if (![[NSFileManager defaultManager] fileExistsAtPath:destinationPath]) {
        // The file does not exist in the documents directory, so copy it from bundle now.

        NSString *sourcePath =[[srcBundle resourcePath] stringByAppendingPathComponent: fileName];

        NSError *error;
        [[NSFileManager defaultManager]
         copyItemAtPath:sourcePath toPath:destinationPath error:&error];

        // Check if any error occurred during copying and display it.
        if (error != nil) {
            NSLog(@"%@", [error localizedDescription]);
        }
    }
#endif
}

+ (void)setupTrustWordsDB:(NSBundle *)rootBundle {
#if TARGET_OS_IPHONE
    [PEPObjCAdapter copyAssetsIntoDocumentsDirectory:rootBundle
                                            fileName:@"system.db"];
#else
    // On macOS the installer must put that in place.
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
