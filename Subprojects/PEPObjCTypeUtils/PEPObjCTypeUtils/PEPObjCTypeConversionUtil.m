//
//  PEPObjCTypeConversionUtil.m
//  PEPObjCTypeUtils
//
//  Created by Andreas Buff on 04.11.21.
//

#import "PEPObjCTypeConversionUtil.h"

#import <PEPTransport.h>
#import <PEPAttachment.h>
#import <PEPMessage.h>
#import <PEPIdentity.h>
#import <pEp_string.h>
#import <status_to_string.h>

@implementation PEPObjCTypeConversionUtil

// MARK: - PEPTransport

+ (PEPTransport * _Nullable)pEpTransportfromStruct:(PEP_transport_t * _Nonnull)transportStruct
{
    PEPTransport *result = nil;
    NSAssert(false, @"unimplemented stub");
    return result;
}

+ (PEP_transport_t *)structFromPEPTransport:(PEPTransport *)pEpTransport
{
    PEP_transport_t *transportStruct = NULL;
    NSAssert(false, @"unimplemented stub");
    return transportStruct;
}

+ (void)overWritePEPTransportObject:(PEPTransport *)pEpTransport
               withValuesFromStruct:(PEP_transport_t * _Nonnull)transportStruct
{
    NSAssert(false, @"unimplemented stub");
}

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

    if (pEpMessage.shortMessage)
        msg->shortmsg = new_string([[pEpMessage.shortMessage
                                     precomposedStringWithCanonicalMapping] UTF8String], 0);

    if (pEpMessage.sentDate)
        msg->sent = new_timestamp([pEpMessage.sentDate timeIntervalSince1970]);

    if (pEpMessage.receivedDate)
        msg->recv = new_timestamp([pEpMessage.receivedDate timeIntervalSince1970]);

    if (pEpMessage.from)
        msg->from = [self structFromPEPIdentity:pEpMessage.from];

    if (pEpMessage.to)
        msg->to = [self arrayToIdentityList:pEpMessage.to];

    if (pEpMessage.receivedBy)
        msg->recv_by = [self structFromPEPIdentity:pEpMessage.receivedBy];

    if (pEpMessage.cc)
        msg->cc = [self arrayToIdentityList:pEpMessage.cc];

    if (pEpMessage.bcc)
        msg->bcc = [self arrayToIdentityList:pEpMessage.bcc];

    if (pEpMessage.replyTo)
        msg->reply_to = [self arrayToIdentityList:pEpMessage.replyTo];

    if (pEpMessage.inReplyTo)
        msg->in_reply_to = [self arrayToStringList:pEpMessage.inReplyTo];

    if (pEpMessage.references)
        msg->references = [self arrayToStringList:pEpMessage.references];

    if (pEpMessage.keywords)
        msg->keywords = [self arrayToStringList:pEpMessage.keywords];

    if (pEpMessage.optionalFields)
        msg->opt_fields = [self arrayToStringPairlist:pEpMessage.optionalFields];

    if (pEpMessage.longMessage)
        msg->longmsg = new_string([[pEpMessage.longMessage
                                    precomposedStringWithCanonicalMapping] UTF8String], 0);

    if (pEpMessage.longMessageFormatted)
        msg->longmsg_formatted = new_string([[pEpMessage.longMessageFormatted
                                              precomposedStringWithCanonicalMapping]
                                             UTF8String], 0);

    if (pEpMessage.attachments) {
        msg->attachments = [self arrayToBloblist:pEpMessage.attachments];
    }

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
        pEpMessage.from = [self pEpIdentityfromStruct:message->from];
    }

    if (message->to && message->to->ident) {
        pEpMessage.to = [self arrayFromIdentityList:message->to];
    }

    if (message->recv_by) {
        pEpMessage.receivedBy = [self pEpIdentityfromStruct:message->recv_by];
    }

    if (message->cc && message->cc->ident) {
        pEpMessage.cc = [self arrayFromIdentityList:message->cc];
    }

    if (message->bcc && message->bcc->ident) {
        pEpMessage.bcc = [self arrayFromIdentityList:message->bcc];
    }

    if (message->reply_to && message->reply_to->ident) {
        pEpMessage.replyTo = [self arrayFromIdentityList:message->reply_to];
    }

    if (message->in_reply_to) {
        pEpMessage.inReplyTo = [self arrayFromStringlist:message->in_reply_to];
    }

    if (message->references && message->references->value) {
        pEpMessage.references = [self arrayFromStringlist:message->references];
    }

    if (message->keywords && message->keywords->value) {
        pEpMessage.keywords = [self arrayFromStringlist:message->keywords];
    }

    if (message->opt_fields) {
        pEpMessage.optionalFields = [self arrayFromStringPairlist:message->opt_fields];
    }

    if (message->longmsg_formatted) {
        pEpMessage.longMessageFormatted = [NSString stringWithUTF8String:message->longmsg_formatted];
    }

    if (message->longmsg) {
        pEpMessage.longMessage = [NSString stringWithUTF8String:message->longmsg];
    }

    if (message->attachments && message->attachments->value) {
        pEpMessage.attachments = [self arrayFromBloblist:message->attachments];
    }
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
}

// MARK: - PEPIdentity

+ (PEPIdentity * _Nullable)pEpIdentityfromStruct:(pEp_identity * _Nonnull)identityStruct
{
    PEPIdentity *identity = nil;

    if (identityStruct->address && identityStruct->address[0]) {
        identity = [[PEPIdentity alloc]
                    initWithAddress:[NSString stringWithUTF8String:identityStruct->address]];
    }
    [self overWritePEPIdentityObject:identity withValuesFromStruct:identityStruct];
    return identity;
}

+ (pEp_identity *)structFromPEPIdentity:(PEPIdentity *)pEpIdentity
{
    pEp_identity *ident = new_identity([[pEpIdentity.address
                                         precomposedStringWithCanonicalMapping] UTF8String],
                                       [[pEpIdentity.fingerPrint
                                         precomposedStringWithCanonicalMapping] UTF8String],
                                       [[pEpIdentity.userID
                                         precomposedStringWithCanonicalMapping] UTF8String],
                                       [[pEpIdentity.userName
                                         precomposedStringWithCanonicalMapping] UTF8String]);
    ident->me = pEpIdentity.isOwn;
    ident->flags = pEpIdentity.flags;

    if (pEpIdentity.language) {
        strncpy(ident->lang, [[pEpIdentity.language
                               precomposedStringWithCanonicalMapping] UTF8String], 2);
    }

    ident->comm_type = (PEP_comm_type) pEpIdentity.commType;

    return ident;
}

+ (void)overWritePEPIdentityObject:(PEPIdentity *)pEpIdentity
               withValuesFromStruct:(pEp_identity * _Nonnull)identityStruct
{
    if (identityStruct->address && identityStruct->address[0]) {
        pEpIdentity.address = [NSString stringWithUTF8String:identityStruct->address];
    }

    if (identityStruct->fpr && identityStruct->fpr[0]) {
        pEpIdentity.fingerPrint = [NSString stringWithUTF8String:identityStruct->fpr];
    }

    if (identityStruct->user_id && identityStruct->user_id[0]) {
        pEpIdentity.userID = [NSString stringWithUTF8String:identityStruct->user_id];
    }

    if (identityStruct->username && identityStruct->username[0]) {
        pEpIdentity.userName = [NSString stringWithUTF8String:identityStruct->username];
    }

    if (identityStruct->lang[0]) {
        pEpIdentity.language = [NSString stringWithUTF8String:identityStruct->lang];
    }

    pEpIdentity.commType = (PEPCommType) identityStruct->comm_type;

    pEpIdentity.isOwn = identityStruct->me;
    pEpIdentity.flags = identityStruct->flags;
}

// MARK: - NSArray <-> stringlist_t

+ (NSArray<NSString*> *)arrayFromStringlist:(stringlist_t * _Nonnull)stringList {
    NSMutableArray *array = [NSMutableArray array];

    for (stringlist_t *_sl = stringList; _sl && _sl->value; _sl = _sl->next) {
        [array addObject:[NSString stringWithUTF8String:_sl->value]];
    }

    return array;
}

+ (stringlist_t * _Nullable)arrayToStringList:(NSArray<NSString*> *)array {
    stringlist_t *sl = new_stringlist(NULL);
    if (!sl) {
        return NULL;
    }

    stringlist_t *_sl = sl;
    for (NSString *str in array) {
        _sl = stringlist_add(_sl, [[str precomposedStringWithCanonicalMapping] UTF8String]);
    }

    return sl;
}

// MARK: - NSArray <-> identity_list

+ (NSArray<PEPIdentity*> *)arrayFromIdentityList:(identity_list *)identityList {
    NSMutableArray *array = [NSMutableArray array];

    for (identity_list *_il = identityList; _il && _il->ident; _il = _il->next) {
        [array addObject:[self pEpIdentityfromStruct:_il->ident]];
    }

    return array;
}

+ (identity_list * _Nullable)arrayToIdentityList:(NSArray<PEPIdentity*> *)array {
    if (array.count == 0) {
        return NULL;
    }

    identity_list *il = new_identity_list(NULL);
    if (!il)
        return NULL;

    identity_list *_il = il;
    for (PEPIdentity *identity in array) {
        _il = identity_list_add(_il, [self structFromPEPIdentity:identity]);
    }

    return il;
}

// MARK: - NSArray <-> stringpair_list_t

+ (NSArray<NSArray<NSString*>*> *)arrayFromStringPairlist:(stringpair_list_t * _Nonnull)stringPairList {
    NSMutableArray *array = [NSMutableArray array];

    for (stringpair_list_t *_sl = stringPairList; _sl && _sl->value; _sl = _sl->next) {
        [array addObject:[[NSMutableArray alloc ]initWithObjects:
                [NSString stringWithUTF8String:_sl->value->key],
                [NSString stringWithUTF8String:_sl->value->value],
                nil]];
    }

    return array;
}

+ (stringpair_list_t * _Nullable)arrayToStringPairlist:(NSArray<NSArray<NSString*>*> *)array {
    stringpair_list_t *sl = new_stringpair_list(NULL);
    if (!sl)
        return NULL;

    stringpair_list_t *_sl = sl;
    for (NSArray *pair in array) {
        stringpair_t *_sp = new_stringpair(
               [[pair[0] precomposedStringWithCanonicalMapping] UTF8String],
               [[pair[1] precomposedStringWithCanonicalMapping] UTF8String]);
        _sl = stringpair_list_add(_sl, _sp);
    }

    return sl;
}

// MARK: - NSArray<PEPAttachment*> <-> bloblist_t

+ (NSArray<PEPAttachment*> *)arrayFromBloblist:(bloblist_t * _Nonnull)blobList {
    NSMutableArray *array = [NSMutableArray array];

    for (bloblist_t *_bl = blobList; _bl && _bl->value; _bl = _bl->next) {
        PEPAttachment* theAttachment = [[PEPAttachment alloc]
                                        initWithData:[NSData dataWithBytes:_bl->value
                                                                    length:_bl->size]];

        if(_bl->filename && _bl->filename[0]) {
            theAttachment.filename = [NSString stringWithUTF8String:_bl->filename];
        }

        if(_bl->mime_type && _bl->mime_type[0]) {
            theAttachment.mimeType = [NSString stringWithUTF8String:_bl->mime_type];
        }

        theAttachment.contentDisposition = (PEPContentDisposition) _bl->disposition;

        [array addObject:theAttachment];
    }
    return array;
}

+ (bloblist_t * _Nullable)arrayToBloblist:(NSArray<PEPAttachment*> *)array {
    if (array.count == 0) {
        return NULL;
    }

    bloblist_t *_bl = new_bloblist(NULL, 0, NULL, NULL);

    if (!_bl) {
        return NULL;
    }

    bloblist_t *bl =_bl;

    // free() might be the default, but let's be explicit
    bl->release_value = (void (*) (char *)) free;

    for (PEPAttachment *theAttachment in array) {
        NSData *data = theAttachment.data;
        size_t size = [data length];

        char *buf = malloc(size);
        assert(buf);
        memcpy(buf, [data bytes], size);

        bl = bloblist_add(bl, buf, size,
                          [[theAttachment.mimeType
                            precomposedStringWithCanonicalMapping]
                           UTF8String],
                          [[theAttachment.filename
                            precomposedStringWithCanonicalMapping]
                           UTF8String]);

        bl->disposition = (content_disposition_type) theAttachment.contentDisposition;
    }
    return _bl;
}

@end
