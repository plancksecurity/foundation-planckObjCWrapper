//
//  PEPMessage.m
//  pEpObjCAdapter
//
//  Created by Dirk Zimmermann on 10.11.17.
//  Copyright © 2017 p≡p. All rights reserved.
//

#import "PEPMessage.h"

#import "PEPIdentity.h"
#import "PEPAttachment.h"
#import "NSObject+Equality.h"

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
               @"rating"
               ];
}

// MARK: -  <NSSecureCoding>

- (nullable instancetype)initWithCoder:(nonnull NSCoder *)decoder {
    if (self = [self init]) {
        NSSet *identityArraySet = [NSSet setWithArray:@[[NSArray class], [PEPIdentity class]]];
        NSSet *stringArraySet = [NSSet setWithArray:@[[NSArray class], [NSString class]]];
        NSSet *attachmentArraySet = [NSSet setWithArray:@[[NSArray class], [PEPAttachment class]]];

        self.messageID = [decoder decodeObjectOfClass:[NSString class] forKey:@"messageID"];

        self.from = [decoder decodeObjectOfClass:[PEPIdentity class] forKey:@"from"];
        self.to = [decoder decodeObjectOfClasses:identityArraySet forKey:@"to"];
        self.cc = [decoder decodeObjectOfClasses:identityArraySet forKey:@"cc"];
        self.bcc = [decoder decodeObjectOfClasses:identityArraySet forKey:@"bcc"];

        self.shortMessage = [decoder decodeObjectOfClass:[NSString class] forKey:@"shortMessage"];
        self.longMessage = [decoder decodeObjectOfClass:[NSString class] forKey:@"longMessage"];
        self.longMessageFormatted = [decoder decodeObjectOfClass:[NSString class]
                                                          forKey:@"longMessageFormatted"];

        self.replyTo = [decoder decodeObjectOfClasses:identityArraySet forKey:@"replyTo"];
        self.inReplyTo = [decoder decodeObjectOfClasses:stringArraySet forKey:@"inReplyTo"];
        self.references = [decoder decodeObjectOfClasses:stringArraySet forKey:@"references"];

        self.sentDate = [decoder decodeObjectOfClass:[NSDate class] forKey:@"sentDate"];
        self.receivedDate = [decoder decodeObjectOfClass:[NSDate class] forKey:@"receivedDate"];

        self.attachments = [decoder decodeObjectOfClasses:attachmentArraySet forKey:@"attachments"];

        self.optionalFields = [decoder decodeObjectOfClasses:stringArraySet
                                                      forKey:@"optionalFields"];
        self.keywords = [decoder decodeObjectOfClasses:stringArraySet forKey:@"keywords"];
        self.receivedBy = [decoder decodeObjectOfClass:[PEPIdentity class] forKey:@"receivedBy"];
        self.direction = [decoder decodeIntForKey:@"direction"];
    }

    return self;
}

- (void)encodeWithCoder:(nonnull NSCoder *)coder {
    [coder encodeObject:self.messageID forKey:@"messageID"];

    [coder encodeObject:self.from forKey:@"from"];
    [coder encodeObject:self.to forKey:@"to"];
    [coder encodeObject:self.cc forKey:@"cc"];
    [coder encodeObject:self.bcc forKey:@"bcc"];

    [coder encodeObject:self.shortMessage forKey:@"shortMessage"];
    [coder encodeObject:self.longMessage forKey:@"longMessage"];
    [coder encodeObject:self.longMessageFormatted forKey:@"longMessageFormatted"];

    [coder encodeObject:self.replyTo forKey:@"replyTo"];
    [coder encodeObject:self.inReplyTo forKey:@"inReplyTo"];
    [coder encodeObject:self.references forKey:@"references"];

    [coder encodeObject:self.sentDate forKey:@"sentDate"];
    [coder encodeObject:self.receivedDate forKey:@"receivedDate"];

    [coder encodeObject:self.attachments forKey:@"attachments"];

    [coder encodeObject:self.optionalFields forKey:@"optionalFields"];
    [coder encodeObject:self.keywords forKey:@"keywords"];
    [coder encodeObject:self.receivedBy forKey:@"receivedBy"];
    [coder encodeInt:self.direction forKey:@"direction"];
}

+ (BOOL)supportsSecureCoding {
    return YES;
}

@end
