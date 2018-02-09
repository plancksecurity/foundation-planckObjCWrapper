//
//  PEPTestUtils.m
//  pEpObjCAdapter
//
//  Created by Andreas Buff on 17.01.18.
//  Copyright © 2018 p≡p. All rights reserved.
//

#import "PEPTestUtils.h"

#import "NSDictionary+Extension.h"
#import "PEPIdentity.h"
#import "PEPInternalSession.h"
#import "PEPMessage.h"
#import "PEPSession.h"

/**
 For now, safer to use that, until the engine copes with our own.
 Should mimick the value of PEP_OWN_USERID.
 */
NSString * const ownUserId = @"pEp_own_userId";

@implementation PEPTestUtils

+ (PEPIdentity *)foreignPepIdentityWithAddress:(NSString *)address userName:(NSString *)username;
{
    return [[PEPIdentity alloc] initWithAddress:address
                                         userID:@"UNIT-TEST-USER-ID-FOREIGN-IDENTITY"
                                       userName:username
                                          isOwn:NO fingerPrint:nil];
}

+ (PEPIdentity *)ownPepIdentityWithAddress:(NSString *)address userName:(NSString *)username;
{
    return [[PEPIdentity alloc] initWithAddress:address
                                         userID:ownUserId
                                       userName:username
                                          isOwn:YES fingerPrint:nil];
}

+ (NSString *)loadResourceByName:(NSString *)name;
{
    NSURL *url = [[NSBundle bundleForClass:[self class]] URLForResource:name withExtension:nil];
    return [NSString stringWithContentsOfURL:url usedEncoding:nil error:nil];
}

+ (NSString *)loadStringFromFileName:(NSString *)fileName;
{
    NSString *txtFilePath = [[[NSBundle bundleForClass:[self class]] resourcePath]
                             stringByAppendingPathComponent:fileName];
    NSString *txtFileContents = [NSString stringWithContentsOfFile:txtFilePath
                                                          encoding:NSUTF8StringEncoding error:NULL];
    return txtFileContents;
}

+ (NSDictionary *)unarchiveDictionary:(NSString *)fileName
{
    NSString *filePath = [[[NSBundle bundleForClass:[self class]]
                           resourcePath] stringByAppendingPathComponent:fileName];
    NSMutableData *data = [NSMutableData dataWithContentsOfFile:filePath];
    NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    NSDictionary *dict = [unarchiver decodeObject];
    [unarchiver finishDecoding];
    return dict;
}

+ (void)importBundledKey:(NSString *)item;
{
    PEPSession *session = [PEPSession new];
    NSString *txtFileContents = [self loadStringFromFileName:item];
    [session importKey:txtFileContents];
}

+ (PEPMessage * _Nonnull) mailFrom:(PEPIdentity * _Nullable) fromIdent
                           toIdent: (PEPIdentity * _Nullable) toIdent
                      shortMessage:(NSString *)shortMessage
                       longMessage: (NSString *)longMessage
                          outgoing:(BOOL) outgoing;
{
    PEPMessage *message = [PEPMessage new];
    message.from = fromIdent;
    message.to = @[toIdent];
    message.direction = outgoing ? PEP_dir_outgoing:PEP_dir_incoming;
    message.shortMessage = shortMessage;
    message.longMessage = longMessage;
    return message;
}

+ (NSArray *)pEpWorkFiles;
{
    // Only files whose content is affected by tests.
    NSString *home = [[[NSProcessInfo processInfo]environment]objectForKey:@"HOME"];
    NSString *gpgHome = [home stringByAppendingPathComponent:@".gnupg"];
    return @[[home stringByAppendingPathComponent:@".pEp_management.db"],
             [home stringByAppendingPathComponent:@".pEp_management.db-shm"],
             [home stringByAppendingPathComponent:@".pEp_management.db-wal"],
             [gpgHome stringByAppendingPathComponent:@"pubring.gpg"],
             [gpgHome stringByAppendingPathComponent:@"secring.gpg"]];

}

+ (void)deleteWorkFilesAfterBackingUpWithBackupName:(NSString *_Nullable)backup;
{
    [PEPSession cleanup];

    for (id path in [self pEpWorkFiles]) {
        [self delFilePath:path backup:backup];
    }
}

+ (void)restoreWorkFilesFromBackupNamed:(NSString *)backup;
{
    if (!backup) {
        return;
    }
    [PEPSession cleanup];

    for (id path in [self pEpWorkFiles]) {
        [self undelFileWithPath:path backup:backup];
    }
}

#pragma mark - PRIVATE

+ (void)delFilePath:(NSString *)path backup:(NSString * _Nullable)bkpsfx;
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error = nil;
    if ([fileManager fileExistsAtPath:path]) {
        BOOL success;
        if (!bkpsfx) {
            success = [fileManager removeItemAtPath:path error:&error];
        } else {
            NSString *toPath = [path stringByAppendingString:bkpsfx];

            if ([fileManager fileExistsAtPath:toPath]) {
                [fileManager removeItemAtPath:toPath error:&error];
            }

            success = [fileManager moveItemAtPath:path toPath:toPath error:&error];
        }
        if (!success) {
            NSLog(@"Error: %@", [error localizedDescription]);
        }
    }
}

+ (void)undelFileWithPath:(NSString *)path backup:(NSString *)backup;
{
    NSParameterAssert(backup);
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString* bpath = [path stringByAppendingString:backup];
    BOOL fileExists = [fileManager fileExistsAtPath:bpath];
    if (fileExists) {
        NSError *error = nil;
        BOOL success = [fileManager moveItemAtPath:bpath toPath:path error:&error];
        if (!success) {
            NSLog(@"Error: %@", [error localizedDescription]);
        }
    }
}

@end
