//
//  PEPMessageTest.m
//  PEPObjCAdapterTypesTests_macOS
//
//  Created by David Alarcon on 27/1/21.
//  Copyright © 2021 p≡p. All rights reserved.
//

#import "PEPMessageTest.h"

#import "PEPIdentityTest.h"
#import "PEPAttachmentTest.h"

@implementation PEPMessageTest

- (instancetype)init {
    if (self = [super init]) {
        self.messageID = [NSString stringWithFormat: @"19980506192030.26456.%@",
                          [PEPIdentityTest new].address];

        self.from = [PEPIdentityTest new];
        self.to = @[[PEPIdentityTest new]];
        self.cc = @[[PEPIdentityTest new]];
        self.bcc = @[[PEPIdentityTest new]];

        self.shortMessage = @"shortMessage";
        self.longMessage = @"longMessage";
        self.longMessageFormatted = @"longMessageFormatted";

        self.replyTo = @[[PEPIdentityTest new]];
        self.inReplyTo = @[[NSString stringWithFormat: @"19980507220459.5655.%@",
                            [PEPIdentityTest new].address]];
        self.references = @[[NSString stringWithFormat: @"19980509035615.40087.%@",
                             [PEPIdentityTest new].address]];

        NSDate *yesterday = [NSCalendar.currentCalendar dateByAddingUnit:NSCalendarUnitDay
                                                                   value:-1 toDate:[NSDate now]
                                                                 options:NSCalendarWrapComponents];
        self.sentDate = yesterday;
        self.receivedDate = [NSDate now];

        self.attachments = @[[PEPAttachmentTest new]];

        self.optionalFields = @[@"optionalField"];
        self.keywords = @[@"keyword"];
        self.receivedBy = [PEPIdentityTest new] ;
        self.direction = PEPMsgDirectionIncoming;
    }

    return  self;
}

@end
