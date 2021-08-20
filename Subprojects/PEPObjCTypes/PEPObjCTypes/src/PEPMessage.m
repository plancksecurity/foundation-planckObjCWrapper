//
//  PEPMessage.m
//  pEpObjCAdapter
//
//  Created by Dirk Zimmermann on 10.11.17.
//  Copyright © 2017 p≡p. All rights reserved.
//

#import "PEPMessage.h"

#import "PEPIdentity.h"

#import "NSObject+Extension.h"

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
