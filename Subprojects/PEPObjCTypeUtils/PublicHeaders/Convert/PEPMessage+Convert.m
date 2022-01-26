//
//  PEPMessage+Convert.m
//  PEPObjCTypeUtils
//
//  Created by Martín Brude on 25/1/22.
//

#import "PEPObjCTypeConversionUtil.h"
#import "PEPMessage.h"
#import "PEPMessage+Convert.h"
#import "PEPIdentity+Convert.h"
#import "PEPAttachment+Convert.h"
#import "pEp_string.h"

@implementation PEPMessage (Convert)

// MARK: - PEPMessage

+ (PEPMessage * _Nullable)pEpMessagefromStruct:(message * _Nullable)msg
{
    if (!msg) {
        return nil;
    }
    PEPMessage *theMessage = [PEPMessage new];
    [self overWritePEPMessageObject:theMessage withValuesFromStruct:msg];
    return theMessage;
}

+ (message * _Nullable)structFromPEPMessage:(PEPMessage *)pEpMessage
{
    PEP_msg_direction dir = pEpMessage.direction == PEPMsgDirectionIncoming ? PEP_dir_incoming : PEP_dir_outgoing;

    message *msg = new_message(dir);

    if (!msg) {
        return NULL;
    }

    if (pEpMessage.messageID)
        msg->id = new_string([[pEpMessage.messageID precomposedStringWithCanonicalMapping]
                              UTF8String], 0);

    if (pEpMessage.shortMessage) {
        msg->shortmsg = new_string([[pEpMessage.shortMessage
                                     precomposedStringWithCanonicalMapping] UTF8String], 0);
    }

    if (pEpMessage.sentDate) {
        msg->sent = new_timestamp([pEpMessage.sentDate timeIntervalSince1970]);
    }

    if (pEpMessage.receivedDate) {
        msg->recv = new_timestamp([pEpMessage.receivedDate timeIntervalSince1970]);
    }

    if (pEpMessage.from) {
        msg->from = [PEPIdentity structFromPEPIdentity:pEpMessage.from];
    }

    if (pEpMessage.to) {
        msg->to = [PEPIdentity arrayToIdentityList:pEpMessage.to];
    }

    if (pEpMessage.receivedBy) {
        msg->recv_by = [PEPIdentity structFromPEPIdentity:pEpMessage.receivedBy];
    }

    if (pEpMessage.cc) {
        msg->cc = [PEPIdentity arrayToIdentityList:pEpMessage.cc];
    }

    if (pEpMessage.bcc) {
        msg->bcc = [PEPIdentity arrayToIdentityList:pEpMessage.bcc];
    }

    if (pEpMessage.replyTo) {
        msg->reply_to = [PEPIdentity arrayToIdentityList:pEpMessage.replyTo];
    }

    if (pEpMessage.inReplyTo) {
        msg->in_reply_to = [PEPObjCTypeConversionUtil arrayToStringList:pEpMessage.inReplyTo];
    }

    if (pEpMessage.references) {
        msg->references = [PEPObjCTypeConversionUtil arrayToStringList:pEpMessage.references];
    }

    if (pEpMessage.keywords) {
        msg->keywords = [PEPObjCTypeConversionUtil arrayToStringList:pEpMessage.keywords];
    }

    if (pEpMessage.optionalFields) {
        msg->opt_fields = [PEPObjCTypeConversionUtil arrayToStringPairlist:pEpMessage.optionalFields];
    }

    if (pEpMessage.longMessage) {
        msg->longmsg = new_string([[pEpMessage.longMessage
                                    precomposedStringWithCanonicalMapping] UTF8String], 0);
    }

    if (pEpMessage.longMessageFormatted) {
        msg->longmsg_formatted = new_string([[pEpMessage.longMessageFormatted
                                              precomposedStringWithCanonicalMapping]
                                             UTF8String], 0);
    }

    if (pEpMessage.attachments) {
        msg->attachments = [PEPAttachment arrayToBloblist:pEpMessage.attachments];
    }

    msg->rating = (PEP_rating) pEpMessage.rating;

    return msg;
}

+ (void)overWritePEPMessageObject:(PEPMessage *)pEpMessage
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
        pEpMessage.from = [PEPIdentity pEpIdentityfromStruct:message->from];
    }

    if (message->to && message->to->ident) {
        pEpMessage.to = [PEPIdentity arrayFromIdentityList:message->to];
    }

    if (message->recv_by) {
        pEpMessage.receivedBy = [PEPIdentity pEpIdentityfromStruct:message->recv_by];
    }

    if (message->cc && message->cc->ident) {
        pEpMessage.cc = [PEPIdentity arrayFromIdentityList:message->cc];
    }

    if (message->bcc && message->bcc->ident) {
        pEpMessage.bcc = [PEPIdentity arrayFromIdentityList:message->bcc];
    }

    if (message->reply_to && message->reply_to->ident) {
        pEpMessage.replyTo = [PEPIdentity arrayFromIdentityList:message->reply_to];
    }

    if (message->in_reply_to) {
        pEpMessage.inReplyTo = [PEPObjCTypeConversionUtil arrayFromStringlist:message->in_reply_to];
    }

    if (message->references && message->references->value) {
        pEpMessage.references = [PEPObjCTypeConversionUtil arrayFromStringlist:message->references];
    }

    if (message->keywords && message->keywords->value) {
        pEpMessage.keywords = [PEPObjCTypeConversionUtil arrayFromStringlist:message->keywords];
    }

    if (message->opt_fields) {
        pEpMessage.optionalFields = [PEPObjCTypeConversionUtil arrayFromStringPairlist:message->opt_fields];
    }

    if (message->longmsg_formatted) {
        pEpMessage.longMessageFormatted = [NSString stringWithUTF8String:message->longmsg_formatted];
    }

    if (message->longmsg) {
        pEpMessage.longMessage = [NSString stringWithUTF8String:message->longmsg];
    }

    if (message->attachments && message->attachments->value) {
        pEpMessage.attachments = [PEPAttachment arrayFromBloblist:message->attachments];
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
