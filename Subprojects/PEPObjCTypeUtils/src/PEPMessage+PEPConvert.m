//
//  PEPMessage+PEPConvert.m
//  PEPObjCTypeUtils
//
//  Created by Martín Brude on 25/1/22.
//

#import "PEPMessage.h"
#import "PEPMessage+PEPConvert.h"
#import "PEPIdentity+PEPConvert.h"
#import "NSArray+PEPConvert.h"
#import "NSArray+PEPIdentityList.h"
#import "NSArray+PEPBloblist.h"
#import "pEp_string.h"
#import "NSArray+PEPIdentityList.h"


@implementation PEPMessage (PEPConvert)

// MARK: - PEPMessage

+ (PEPMessage * _Nullable)fromStruct:(message * _Nullable)msg
{
    if (!msg) {
        return nil;
    }
    PEPMessage *theMessage = [PEPMessage new];
    [self overwritePEPMessageObject:theMessage withValuesFromStruct:msg];
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

    if (self.shortMessage) {
        msg->shortmsg = new_string([[self.shortMessage
                                     precomposedStringWithCanonicalMapping] UTF8String], 0);
    }

    if (self.sentDate) {
        msg->sent = new_timestamp([self.sentDate timeIntervalSince1970]);
    }

    if (self.receivedDate) {
        msg->recv = new_timestamp([self.receivedDate timeIntervalSince1970]);
    }

    if (self.from) {
        msg->from = [self.from toStruct];
    }

    if (self.to) {
        msg->to = [self.to toIdentityList];
    }

    if (self.receivedBy) {
        msg->recv_by = [self.receivedBy toStruct];
    }

    if (self.cc) {
        [self.cc toIdentityList];
    }

    if (self.bcc) {
        msg->bcc = [self.bcc toIdentityList];
    }

    if (self.replyTo) {
        msg->reply_to = [self.replyTo toIdentityList];
    }

    if (self.inReplyTo) {

        msg->in_reply_to = [self.inReplyTo toStringList];
    }

    if (self.references) {
        msg->references = [self.references toStringList];
    }

    if (self.keywords) {
        msg->keywords = [self.keywords toStringList];
    }

    if (self.optionalFields) {
        msg->opt_fields = [self.optionalFields toStringPairList];
    }

    if (self.longMessage) {
        msg->longmsg = new_string([[self.longMessage
                                    precomposedStringWithCanonicalMapping] UTF8String], 0);
    }

    if (self.longMessageFormatted) {
        msg->longmsg_formatted = new_string([[self.longMessageFormatted
                                              precomposedStringWithCanonicalMapping]
                                             UTF8String], 0);
    }

    if (self.attachments) {

        msg->attachments = [self.attachments toBloblist];
    }

    msg->rating = (PEP_rating) self.rating;

    return msg;
}

+ (void)overwritePEPMessageObject:(PEPMessage *)pEpMessage
             withValuesFromStruct:(message * _Nonnull)message
{
    [self resetPEPMessage:pEpMessage];

    pEpMessage.direction = message->dir == PEP_dir_outgoing ? PEPMsgDirectionOutgoing : PEPMsgDirectionIncoming;

    if (message->id) {
        pEpMessage.messageID = [NSString stringWithUTF8String:message->id];
    }

    if (message->shortmsg) {
        pEpMessage.shortMessage = [NSString stringWithUTF8String:message->shortmsg];
    }

    if (message->sent) {
        pEpMessage.sentDate = [NSDate dateWithTimeIntervalSince1970:timegm(message->sent)];
    }

    if (message->recv) {
        pEpMessage.receivedDate = [NSDate dateWithTimeIntervalSince1970:mktime(message->recv)];
    }

    if (message->from) {
        pEpMessage.from = [PEPIdentity fromStruct:message->from];
    }

    if (message->to && message->to->ident) {
        pEpMessage.to = [NSArray fromIdentityList:message->to];
    }

    if (message->recv_by) {
        pEpMessage.receivedBy = [PEPIdentity fromStruct:message->recv_by];
    }

    if (message->cc && message->cc->ident) {
        pEpMessage.cc = [NSArray fromIdentityList:message->cc];
    }

    if (message->bcc && message->bcc->ident) {
        pEpMessage.bcc = [NSArray fromIdentityList:message->bcc];
    }

    if (message->reply_to && message->reply_to->ident) {
        pEpMessage.replyTo = [NSArray fromIdentityList:message->reply_to];
    }

    if (message->in_reply_to) {
        pEpMessage.inReplyTo = [NSArray fromStringlist: message->in_reply_to];
    }

    if (message->references && message->references->value) {
        pEpMessage.references = [NSArray fromStringlist: message->references];
    }

    if (message->keywords && message->keywords->value) {
        pEpMessage.keywords = [NSArray fromStringlist:message->keywords];
    }

    if (message->opt_fields) {
        pEpMessage.optionalFields = [NSArray fromStringPairlist:message->opt_fields];
    }

    if (message->longmsg_formatted) {
        pEpMessage.longMessageFormatted = [NSString stringWithUTF8String:message->longmsg_formatted];
    }

    if (message->longmsg) {
        pEpMessage.longMessage = [NSString stringWithUTF8String:message->longmsg];
    }

    if (message->attachments && message->attachments->value) {
        pEpMessage.attachments = [NSArray fromBloblist:message->attachments];
    }

    pEpMessage.rating = (PEPRating) message->rating;
}

+ (void)removeEmptyRecipientsFromPEPMessage:(PEPMessage *)pEpMessage
{
    if (pEpMessage.to.count == 0) {
        pEpMessage.to = nil;
    }

    if (pEpMessage.cc.count == 0) {
        pEpMessage.cc = nil;
    }

    if (pEpMessage.bcc.count == 0) {
        pEpMessage.bcc = nil;
    }
}

+ (PEPMessage *)pEpMessageWithEmptyRecipientsRemovedFromPEPMessage:(PEPMessage *)pEpMessage
{
    [self removeEmptyRecipientsFromPEPMessage:pEpMessage];
    return pEpMessage;
}

// MARK: - PRIVATE

+ (void)resetPEPMessage:(PEPMessage *)pEpMessage
{
    pEpMessage.messageID = nil;
    pEpMessage.from = nil;
    pEpMessage.to = nil;
    pEpMessage.cc = nil;
    pEpMessage.bcc = nil;
    pEpMessage.shortMessage = nil;
    pEpMessage.longMessage = nil;
    pEpMessage.longMessageFormatted = nil;
    pEpMessage.replyTo = nil;
    pEpMessage.inReplyTo = nil;
    pEpMessage.references = nil;
    pEpMessage.sentDate = nil;
    pEpMessage.receivedDate = nil;
    pEpMessage.attachments = nil;
    pEpMessage.optionalFields = nil;
    pEpMessage.keywords = nil;
    pEpMessage.receivedBy = nil;
    pEpMessage.direction = (PEPMsgDirection) PEP_dir_incoming; // basically, 0
    pEpMessage.rating = PEPRatingUndefined;
}

@end
