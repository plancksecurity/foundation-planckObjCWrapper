//
//  PEPTestUtils.m
//  pEpObjCAdapter
//
//  Created by Andreas Buff on 17.01.18.
//  Copyright © 2018 p≡p. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "PEPTestUtils.h"

#import "PEPObjCAdapterFramework.h"
#import "PEPInternalSession.h"
#import "PEPMessage.h"
#import "PEPSession.h"
#import "PEPAttachment.h"
#import "PEPSessionProvider.h"
#import "PEPInternalSession.h"

/**
 For now, safer to use that, until the engine copes with our own.
 Should mimick the value of PEP_OWN_USERID.
 */
NSString * const ownUserId = @"pEp_own_userId";

const NSInteger PEPTestInternalSyncTimeout = 20;

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

/**
 Converts a given message dict to a version with correct attachments, using PEPAttachment.
 Using unarchiveDirectory for a message object will yield the old attachment format,
 which was just an array of dictionaries. Now the correct way is to use PEPAttachments.
 */
+ (void)migrateUnarchivedMessageDictionary:(NSMutableDictionary *)message
{
    NSMutableArray *attachments = [NSMutableArray new];
    for (NSDictionary *attachmentDict in [message objectForKey:kPepAttachments]) {
        PEPAttachment *attachment = [[PEPAttachment alloc]
                                     initWithData:[attachmentDict objectForKey:@"data"]];
        attachment.filename = [attachmentDict objectForKey:@"filename"];
        attachment.mimeType = [attachmentDict objectForKey:@"mimeType"];
        [attachments addObject:attachment];
    }
    [message setValue:[NSArray arrayWithArray:attachments] forKey:kPepAttachments];
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
        return [session importKey:txtFileContents error:nil];
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
