//
//  NSMutableDictionary+PEP.m
//  pEpObjCAdapter
//
//  Created by Dirk Zimmermann on 24.04.18.
//  Copyright © 2018 p≡p. All rights reserved.
//

#import "NSMutableDictionary+PEP.h"

#import "PEPMessageUtil.h"

@implementation NSMutableDictionary (PEP)

- (void)replaceWithMessage:(message *)message
{
    [self removeAllObjects];

    [self setObject:(message->dir == PEP_dir_outgoing) ? @YES : @NO forKey:kPepOutgoing];

    if (message->id) {
        [self setObject:[NSString stringWithUTF8String:message->id] forKey:kPepID];
    }

    if (message->shortmsg) {
        [self setObject:[NSString stringWithUTF8String:message->shortmsg] forKey:kPepShortMessage];
    }

    if (message->sent) {
        [self setObject:[NSDate dateWithTimeIntervalSince1970:timegm(message->sent)]
                 forKey:kPepSent];
    }

    if (message->recv) {
        [self setObject:[NSDate dateWithTimeIntervalSince1970:mktime(message->recv)]
                 forKey:kPepReceived];
    }

    if (message->from) {
        [self setObject:PEP_identityFromStruct(message->from) forKey:kPepFrom];
    }

    if (message->to && message->to->ident) {
        [self setObject:PEP_identityArrayFromList(message->to) forKey:kPepTo];
    }

    if (message->recv_by) {
        [self setObject:PEP_identityFromStruct(message->recv_by) forKey:kPepReceivedBy];
    }

    if (message->cc && message->cc->ident) {
        [self setObject:PEP_identityArrayFromList(message->cc) forKey:kPepCC];
    }

    if (message->bcc && message->bcc->ident) {
        [self setObject:PEP_identityArrayFromList(message->bcc) forKey:kPepBCC];
    }

    if (message->reply_to && message->reply_to->ident) {
        [self setObject:PEP_identityArrayFromList(message->reply_to) forKey:kPepReplyTo];
    }

    if (message->in_reply_to) {
        [self setObject:PEP_arrayFromStringlist(message->in_reply_to) forKey:kPepInReplyTo];
    }

    if (message->references && message->references->value) {
        [self setObject:PEP_arrayFromStringlist(message->references) forKey:kPepReferences];
    }

    if (message->keywords && message->keywords->value) {
        [self setObject:PEP_arrayFromStringlist(message->keywords) forKey:kPepKeywords];
    }

    if (message->opt_fields) {
        [self setObject:PEP_arrayFromStringPairlist(message->opt_fields) forKey:kPepOptFields];
    }

    if (message->longmsg_formatted) {
        [self setObject:[NSString stringWithUTF8String:message->longmsg_formatted]
                 forKey:kPepLongMessageFormatted];
    }

    if (message->longmsg) {
        [self setObject:[NSString stringWithUTF8String:message->longmsg] forKey:kPepLongMessage];
    }

    if (message->attachments && message->attachments->value) {
        [self setObject: PEP_arrayFromBloblist(message->attachments) forKey:kPepAttachments];
    }

    if (message->rawmsg_size > 0 && *message->rawmsg_ref) {
        NSData *data = [NSData dataWithBytes:message->rawmsg_ref length:message->rawmsg_size];
        self[kPepRawMessage] = data;
    }
}

@end
