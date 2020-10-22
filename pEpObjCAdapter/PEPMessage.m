//
//  PEPMessage.m
//  pEpObjCAdapter
//
//  Created by Dirk Zimmermann on 10.11.17.
//  Copyright © 2017 p≡p. All rights reserved.
//

#import "PEPMessage.h"

#import "PEPIdentity.h"
#import "PEPConstants.h"

#import "NSObject+Extension.h"

#import "message_api.h"

@implementation PEPMessage

- (instancetype _Nonnull)initWithMessage:(PEPMessage *)message
{
    self = [super init];
    if (self) {
        self.messageID = message.messageID;
        self.from = message.from;
        self.to = message.to;
        self.cc = message.cc;
        self.bcc = message.bcc;
        self.shortMessage = message.shortMessage;
        self.longMessage = message.longMessage;
        self.longMessageFormatted = message.longMessageFormatted;
        self.replyTo = message.replyTo;
        self.inReplyTo = message.inReplyTo;
        self.references = message.references;
        self.sentDate = message.sentDate;
        self.receivedDate = message.receivedDate;
        self.attachments = message.attachments;
        self.optionalFields = message.optionalFields;
        self.keywords = message.keywords;
        self.receivedBy = message.receivedBy;
        self.direction = message.direction;
    }
    return self;
}

// MARK: - Faking directory

- (PEPDict * _Nonnull)dictionary
{
    // most adapter use should be ok.
    return (PEPDict *) self;
}

- (PEPMutableDict * _Nonnull)mutableDictionary
{
    // most adapter use should be ok.
    return (PEPMutableDict *) self;
}

- (void)removeAllObjects
{
    self.messageID = nil;
    self.from = nil;
    self.to = nil;
    self.cc = nil;
    self.bcc = nil;
    self.shortMessage = nil;
    self.longMessage = nil;
    self.longMessageFormatted = nil;
    self.replyTo = nil;
    self.inReplyTo = nil;
    self.references = nil;
    self.sentDate = nil;
    self.receivedDate = nil;
    self.attachments = nil;
    self.optionalFields = nil;
    self.keywords = nil;
    self.receivedBy = nil;
    self.direction = PEP_dir_incoming; // basically, 0
}

// MARK: - NSDictionary - Helpers

- (NSArray<NSArray<NSString *> *> *)keyValuePairs
{
    NSMutableArray *result = [NSMutableArray new];

    if (self.from) {
        [result addObject:@[kPepFrom, self.from]];
    }

    if (self.to) {
        [result addObject:@[kPepTo, self.to]];
    }

    if (self.cc) {
        [result addObject:@[kPepCC, self.cc]];
    }

    if (self.shortMessage) {
        [result addObject:@[kPepShortMessage, self.shortMessage]];
    }

    if (self.longMessage) {
        [result addObject:@[kPepLongMessage, self.longMessage]];
    }

    if (self.longMessageFormatted) {
        [result addObject:@[kPepLongMessageFormatted, self.longMessageFormatted]];
    }

    if (self.attachments) {
        [result addObject:@[kPepAttachments, self.attachments]];
    }

    if (self.references) {
        [result addObject:@[kPepReferences, self.references]];
    }

    if (self.inReplyTo) {
        [result addObject:@[kPepInReplyTo, self.inReplyTo]];
    }

    BOOL outgoing = self.direction == PEP_dir_outgoing ? YES:NO;
    [result addObject:@[kPepOutgoing, [NSNumber numberWithBool:outgoing]]];

    return result;
}

// MARK: - NSDictionary

- (nullable id)objectForKey:(NSString *)key
{
    return [self valueForKey:key];
}

- (void)removeObjectForKey:(NSString *)key
{
    if ([@"bcc" isEqualToString:key]) {
        self.bcc = nil;
    } else if ([@"cc" isEqualToString:key]) {
        self.cc = nil;
    } else if ([@"to" isEqualToString:key]) {
        self.to = nil;
    } else {
        NSAssert1(false, @"Unsupported key for removeObjectForKey: |%@|",  key);
    }
}

- (NSInteger)count
{
    return [[self keyValuePairs] count];
}

- (void)enumerateKeysAndObjectsUsingBlock:(void (^)(id key, id obj, BOOL *stop))block
{
    BOOL stop = NO;
    NSArray *pairs = [self keyValuePairs];
    for (NSArray *pair in pairs) {
        block(pair[0], pair[1], &stop);
        if (stop) {
            break;
        }
    }
}

// MARK: - NSMutableCopying

- (id)mutableCopyWithZone:(nullable NSZone *)zone
{
    PEPMessage *newMessage = [PEPMessage new];
    newMessage.messageID = self.messageID;
    newMessage.from = self.from;
    newMessage.to = self.to;
    newMessage.cc = self.cc;
    newMessage.bcc = self.bcc;
    newMessage.shortMessage = self.shortMessage;
    newMessage.longMessage = self.longMessage;
    newMessage.longMessageFormatted = self.longMessageFormatted;
    newMessage.replyTo = self.replyTo;
    newMessage.inReplyTo = self.inReplyTo;
    newMessage.references = self.references;
    newMessage.sentDate = self.sentDate;
    newMessage.receivedDate = self.receivedDate;
    newMessage.attachments = self.attachments;
    newMessage.optionalFields = self.optionalFields;
    newMessage.keywords = self.keywords;
    newMessage.receivedBy = self.receivedBy;
    newMessage.direction = self.direction;
    return newMessage;
}

// MARK: - Equality

/**
 The keys that should be used to decide `isEqual` and compute the `hash`.
 */
static NSArray *s_keys;

- (BOOL)isEqualToPEPMessage:(PEPMessage * _Nonnull)message
{
    return [self isEqualToObject:message basedOnKeys:s_keys];
}

- (NSUInteger)hash
{
    return [self hashBasedOnKeys:s_keys];
}

- (BOOL)isEqual:(id)object
{
    if (object == self) {
        return YES;
    }
    if (!object || ![object isKindOfClass:[self class]]) {
        return NO;
    }

    return [self isEqualToPEPMessage:object];
}

// MARK: - Static Initialization

+ (void)initialize
{
    s_keys = @[
               @"attachments",
               @"bcc",
               @"cc",
               @"direction",
               @"from",
               @"inReplyTo",
               @"keywords",
               @"longMessage",
               @"longMessageFormatted",
               @"messageID",
               @"optionalFields",
               @"receivedBy",
               @"receivedDate",
               @"references",
               @"replyTo",
               @"sentDate",
               @"shortMessage",
               @"to",
               ];
}

@end
