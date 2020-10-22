//
//  PEPMessage+Engine.m
//  pEpiOSAdapter
//
//  Created by Dirk Zimmermann on 21.10.20.
//  Copyright © 2020 p≡p. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "PEPMessage+Engine.h"

#import "PEPMessage.h"
#import "PEPMessageUtil.h"

@implementation PEPMessage (Engine)

+ (PEPMessage * _Nullable)fromStruct:(message * _Nullable)msg
{
    if (!msg) {
        return nil;
    }
    NSDictionary *dict = PEP_messageDictFromStruct(msg);
    PEPMessage *theMessage = [PEPMessage new];
    [theMessage setValuesForKeysWithDictionary:dict];
    return theMessage;
}

- (message * _Nullable)toStruct
{
    return PEP_messageDictToStruct((NSDictionary *) self);
}

- (PEPMessage *)removeEmptyRecipients
{
    if (self.to.count == 0) {
        self.to = nil;
    }

    if (self.cc.count == 0) {
        self.cc = nil;
    }

    if (self.bcc.count == 0) {
        self.bcc = nil;
    }

    return self;
}

// MARK: - Private

- (void)reset
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
    self.direction = PEPMsgDirectionIncoming;
}

@end
