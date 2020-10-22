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
#import "PEPIdentity+Engine.h"
#import "NSArray+Engine.h"

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

- (void)overWriteFromStruct:(message * _Nonnull)message
{
    [self reset];

    self.direction = message->dir == PEP_dir_outgoing ? PEPMsgDirectionOutgoing : PEPMsgDirectionIncoming;

    if (message->id) {
        self.messageID = [NSString stringWithUTF8String:message->id];
    }

    if (message->shortmsg) {
        self.shortMessage = [NSString stringWithUTF8String:message->shortmsg];
    }

    if (message->sent) {
        self.sentDate = [NSDate dateWithTimeIntervalSince1970:timegm(message->sent)];
    }

    if (message->recv) {
        self.receivedDate = [NSDate dateWithTimeIntervalSince1970:mktime(message->recv)];
    }

    if (message->from) {
        self.from = [PEPIdentity fromStruct:message->from];
    }

    if (message->to && message->to->ident) {
        self.to = [NSArray arrayFromIdentityList:message->to];
    }

    if (message->recv_by) {
        self.receivedBy = [PEPIdentity fromStruct:message->recv_by];
    }

    if (message->cc && message->cc->ident) {
        self.cc = [NSArray arrayFromIdentityList:message->cc];
    }

    if (message->bcc && message->bcc->ident) {
        self.bcc = [NSArray arrayFromIdentityList:message->bcc];
    }

    if (message->reply_to && message->reply_to->ident) {
        self.replyTo = [NSArray arrayFromIdentityList:message->reply_to];
    }

    if (message->in_reply_to) {
        self.inReplyTo = [NSArray arrayFromStringlist:message->in_reply_to];
    }

    if (message->references && message->references->value) {
        self.references = [NSArray arrayFromStringlist:message->references];
    }

    if (message->keywords && message->keywords->value) {
        self.keywords = [NSArray arrayFromStringlist:message->keywords];
    }

    if (message->opt_fields) {
        self.optionalFields = PEP_arrayFromStringPairlist(message->opt_fields);
    }

    if (message->longmsg_formatted) {
        self.longMessageFormatted = [NSString stringWithUTF8String:message->longmsg_formatted];
    }

    if (message->longmsg) {
        self.longMessage = [NSString stringWithUTF8String:message->longmsg];
    }

    if (message->attachments && message->attachments->value) {
        self.attachments = PEP_arrayFromBloblist(message->attachments);
    }
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
