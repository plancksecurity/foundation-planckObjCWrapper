//
//  PEPTestUtils.m
//  pEpObjCAdapter
//
//  Created by Andreas Buff on 17.01.18.
//  Copyright © 2018 p≡p. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "PEPTestUtils.h"

@import PEPObjCTypes_iOS;
@import PEPObjCAdapter_iOS;

#import "PEPInternalSession.h"
#import "PEPSessionProvider.h"

/**
 For now, safer to use that, until the engine copes with our own.
 Should mimick the value of PEP_OWN_USERID.
 */
NSString * const ownUserId = @"pEp_own_userId";

const NSInteger PEPTestInternalSyncTimeout = 20;

const NSInteger PEPTestInternalFastTimeout = 5;

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

+ (BOOL)importBundledKey:(NSString *)item session:(PEPInternalSession *)session
{
    if (!session) {
        session = [PEPSessionProvider session];
    }

    NSString *txtFileContents = [self loadStringFromFileName:item];
    if (!txtFileContents) {
        return NO;
    } else {
        NSError *error = nil;
        NSArray<PEPIdentity *> *identities = [session importKey:txtFileContents error:&error];
        return (identities != nil);
    }
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
    message.direction = outgoing ? PEPMsgDirectionOutgoing : PEPMsgDirectionIncoming;
    message.shortMessage = shortMessage;
    message.longMessage = longMessage;
    message.attachments = @[];
    message.optionalFields = @[];
    return message;
}

+ (void)cleanUp
{
    [PEPSession cleanup];

    NSString *homeString = [PEPObjCAdapter perUserDirectoryString];
    NSURL *homeUrl = [NSURL fileURLWithPath:homeString isDirectory:YES];

    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSDirectoryEnumerator<NSString *> *enumerator = [fileManager enumeratorAtPath:homeString];
    for (NSString *path in enumerator) {
        NSURL *fileUrl = [NSURL fileURLWithPath:path isDirectory:NO relativeToURL:homeUrl];
        NSError *error = nil;
        if (![fileManager removeItemAtURL:fileUrl error:&error]) {
            NSLog(@"Error deleting '%@': %@", fileUrl, [error localizedDescription]);
        }
    }
}

@end
