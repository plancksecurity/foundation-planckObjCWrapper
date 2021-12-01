//
//  PEPTypesTestUtil.m
//  PEPObjCTypesTests_iOS
//
//  Created by David Alarcon on 27/1/21.
//  Copyright © 2021 p≡p. All rights reserved.
//

#import "PEPTypesTestUtil.h"

#import "PEPIdentity.h"
#import "PEPAttachment.h"
#import "PEPLanguage.h"
#import "PEPMessage.h"

@implementation PEPTypesTestUtil

+ (PEPIdentity *)pEpIdentityWithAllFieldsFilled {
    PEPIdentity *identity = [PEPIdentity new];

    identity.address = @"test@host.com";
    identity.userID = @"pEp_own_userId";
    identity.fingerPrint = @"184C1DE2D4AB98A2A8BB7F23B0EC5F483B62E19D";
    identity.language = @"cat";
    identity.commType = PEPCommTypePEP;
    identity.isOwn = YES;
    identity.flags = PEPIdentityFlagsNotForSync;

    return identity;
}

+ (PEPAttachment *)pEpAttachmentWithAllFieldsFilled {
    PEPAttachment *attachment = [PEPAttachment new];

    attachment.data = [@"attachment" dataUsingEncoding:NSUTF8StringEncoding];
    attachment.size = attachment.data.length;
    attachment.mimeType = @"text/plain";
    attachment.filename = @"attachment.txt";
    attachment.contentDisposition = PEPContentDispositionAttachment;

    return attachment;
}

+ (PEPLanguage *)pEpLanguageWithAllFieldsFilled {
    PEPLanguage *language = [PEPLanguage new];

    language.code = @"cat";
    language.name = @"Català";
    language.sentence = @"Bon profit";

    return language;
}

+ (PEPMessage *)pEpMessageWithAllFieldsFilled {
    PEPMessage *message = [PEPMessage new];
    PEPIdentity *identity = [PEPTypesTestUtil pEpIdentityWithAllFieldsFilled];
    PEPAttachment *attachment = [PEPTypesTestUtil pEpAttachmentWithAllFieldsFilled];

    message.messageID = [NSString stringWithFormat: @"19980506192030.26456.%@", identity.address];

    message.from = identity;
    message.to = @[identity];
    message.cc = @[identity];
    message.bcc = @[identity];

    message.shortMessage = @"shortMessage";
    message.longMessage = @"longMessage";
    message.longMessageFormatted = @"longMessageFormatted";

    message.replyTo = @[identity];
    message.inReplyTo = @[[NSString stringWithFormat: @"19980507220459.5655.%@", identity.address]];
    message.references = @[[NSString stringWithFormat:
                            @"19980509035615.40087.%@",
                            identity.address]];

    NSDate *yesterday = [NSCalendar.currentCalendar dateByAddingUnit:NSCalendarUnitDay
                                                               value:-1 toDate:[NSDate now]
                                                             options:NSCalendarWrapComponents];
    message.sentDate = yesterday;
    message.receivedDate = [NSDate now];

    message.attachments = @[attachment];

    message.optionalFields = @[@[@"optionalField", @"optionalValue"]];
    message.keywords = @[@"keyword"];
    message.receivedBy = identity;
    message.direction = PEPMsgDirectionIncoming;

    return message;
}

@end
