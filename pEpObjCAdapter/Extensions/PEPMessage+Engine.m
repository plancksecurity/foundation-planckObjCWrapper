//
//  PEPMessage+Engine.m
//  pEpiOSAdapter
//
//  Created by Dirk Zimmermann on 21.10.20.
//  Copyright © 2020 p≡p. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "PEPMessage+Engine.h"

#import "pEp_string.h"

#import "PEPIdentity+Engine.h"
#import "NSArray+Engine.h"

@implementation PEPMessage (Engine)

+ (instancetype _Nullable)fromStruct:(message * _Nullable)msg
{
    if (!msg) {
        return nil;
    }
    PEPMessage *theMessage = [PEPMessage new];
    [theMessage overWriteFromStruct:msg];
    return theMessage;
}

- (message * _Nullable)toStruct
{
    PEP_msg_direction dir = self.direction == PEPMsgDirectionIncoming ? PEP_dir_incoming : PEP_dir_outgoing;

    message *msg = new_message(dir);

    if (!msg) {
        return NULL;
    }

    if (self.messageID)
        msg->id = new_string([[self.messageID precomposedStringWithCanonicalMapping]
                              UTF8String], 0);

    if (self.shortMessage)
        msg->shortmsg = new_string([[self.shortMessage
                                     precomposedStringWithCanonicalMapping] UTF8String], 0);

    if (self.sentDate)
        msg->sent = new_timestamp([self.sentDate timeIntervalSince1970]);

    if (self.receivedDate)
        msg->recv = new_timestamp([self.receivedDate timeIntervalSince1970]);

    if (self.from)
        msg->from = [self.from toStruct];

    if (self.to)
        msg->to = [self.to toIdentityList];

    if (self.receivedBy)
        msg->recv_by = [self.receivedBy toStruct];

    if (self.cc)
        msg->cc = [self.cc toIdentityList];

    if (self.bcc)
        msg->bcc = [self.bcc toIdentityList];

    if (self.replyTo)
        msg->reply_to = [self.replyTo toIdentityList];

    if (self.inReplyTo)
        msg->in_reply_to = [self.inReplyTo toStringList];

    if (self.references)
        msg->references = [self.references toStringList];

    if (self.keywords)
        msg->keywords = [self.keywords toStringList];

    if (self.optionalFields)
        msg->opt_fields = [self.optionalFields toStringPairlist];

    if (self.longMessage)
        msg->longmsg = new_string([[self.longMessage
                                    precomposedStringWithCanonicalMapping] UTF8String], 0);

    if (self.longMessageFormatted)
        msg->longmsg_formatted = new_string([[self.longMessageFormatted
                                              precomposedStringWithCanonicalMapping]
                                             UTF8String], 0);

    if (self.attachments)
        msg->attachments = [self.attachments toBloblist];

    return msg;
}

- (instancetype)removeEmptyRecipients
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
        self.optionalFields = [NSArray arrayFromStringPairlist:message->opt_fields];
    }

    if (message->longmsg_formatted) {
        self.longMessageFormatted = [NSString stringWithUTF8String:message->longmsg_formatted];
    }

    if (message->longmsg) {
        self.longMessage = [NSString stringWithUTF8String:message->longmsg];
    }

    if (message->attachments && message->attachments->value) {
        self.attachments = [NSArray arrayFromBloblist:message->attachments];
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
    self.direction = PEP_dir_incoming; // basically, 0
}

@end
