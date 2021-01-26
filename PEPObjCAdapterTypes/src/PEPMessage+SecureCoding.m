//
//  PEPMessage+SecureCoding.m
//  PEPObjCAdapterTypes_macOS
//
//  Created by David Alarcon on 25/1/21.
//  Copyright © 2021 p≡p. All rights reserved.
//

#import "PEPMessage+SecureCoding.h"

#import "PEPIdentity.h"
#import "PEPAttachment.h"

@implementation PEPMessage (SecureCoding)

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
        self.direction = [decoder decodeIntForKey:@"direction"];;
    }

    return self;
}

- (void)encodeWithCoder:(nonnull NSCoder *)coder {
    [coder encodeObject:self.messageID              forKey:@"messageID"];

    [coder encodeObject:self.from                   forKey:@"from"];
    [coder encodeObject:self.to                     forKey:@"to"];
    [coder encodeObject:self.cc                     forKey:@"cc"];
    [coder encodeObject:self.bcc                    forKey:@"bcc"];

    [coder encodeObject:self.shortMessage           forKey:@"shortMessage"];
    [coder encodeObject:self.longMessage            forKey:@"longMessage"];
    [coder encodeObject:self.longMessageFormatted   forKey:@"longMessageFormatted"];

    [coder encodeObject:self.replyTo                forKey:@"replyTo"];
    [coder encodeObject:self.inReplyTo              forKey:@"inReplyTo"];
    [coder encodeObject:self.references             forKey:@"references"];

    [coder encodeObject:self.sentDate               forKey:@"sentDate"];
    [coder encodeObject:self.receivedDate           forKey:@"receivedDate"];

    [coder encodeObject:self.attachments            forKey:@"attachments"];

    [coder encodeObject:self.optionalFields         forKey:@"optionalFields"];
    [coder encodeObject:self.keywords               forKey:@"keywords"];
    [coder encodeObject:self.receivedBy             forKey:@"receivedBy"];
    [coder encodeInt:self.direction                 forKey:@"direction"];
}

+ (BOOL)supportsSecureCoding {
    return  YES;
}

@end
