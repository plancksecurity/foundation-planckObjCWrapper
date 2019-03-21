//
//  NSMutableDictionary+PEP.m
//  pEpObjCAdapter
//
//  Created by Dirk Zimmermann on 24.04.18.
//  Copyright © 2018 p≡p. All rights reserved.
//

#import "NSMutableDictionary+PEP.h"

#import "PEPConstants.h"

#import "PEPMessageUtil.h"

void replaceDictionaryContentsWithMessage(NSMutableDictionary *dict, message *message)
{
    [dict removeAllObjects];
    
    [dict setValue:(message->dir == PEP_dir_outgoing) ? @YES : @NO forKey:kPepOutgoing];
    
    if (message->id) {
        [dict setValue:[NSString stringWithUTF8String:message->id] forKey:kPepID];
    }
    
    if (message->shortmsg) {
        [dict setValue:[NSString stringWithUTF8String:message->shortmsg] forKey:kPepShortMessage];
    }
    
    if (message->sent) {
        [dict setValue:[NSDate dateWithTimeIntervalSince1970:timegm(message->sent)]
                forKey:kPepSent];
    }
    
    if (message->recv) {
        [dict setValue:[NSDate dateWithTimeIntervalSince1970:mktime(message->recv)]
                forKey:kPepReceived];
    }
    
    if (message->from) {
        [dict setValue:PEP_identityFromStruct(message->from) forKey:kPepFrom];
    }
    
    if (message->to && message->to->ident) {
        [dict setValue:PEP_identityArrayFromList(message->to) forKey:kPepTo];
    }
    
    if (message->recv_by) {
        [dict setValue:PEP_identityFromStruct(message->recv_by) forKey:kPepReceivedBy];
    }
    
    if (message->cc && message->cc->ident) {
        [dict setValue:PEP_identityArrayFromList(message->cc) forKey:kPepCC];
    }
    
    if (message->bcc && message->bcc->ident) {
        [dict setValue:PEP_identityArrayFromList(message->bcc) forKey:kPepBCC];
    }
    
    if (message->reply_to && message->reply_to->ident) {
        [dict setValue:PEP_identityArrayFromList(message->reply_to) forKey:kPepReplyTo];
    }
    
    if (message->in_reply_to) {
        [dict setValue:PEP_arrayFromStringlist(message->in_reply_to) forKey:kPepInReplyTo];
    }
    
    if (message->references && message->references->value) {
        [dict setValue:PEP_arrayFromStringlist(message->references) forKey:kPepReferences];
    }
    
    if (message->keywords && message->keywords->value) {
        [dict setValue:PEP_arrayFromStringlist(message->keywords) forKey:kPepKeywords];
    }
    
    if (message->opt_fields) {
        [dict setValue:PEP_arrayFromStringPairlist(message->opt_fields) forKey:kPepOptFields];
    }
    
    if (message->longmsg_formatted) {
        [dict setValue:[NSString stringWithUTF8String:message->longmsg_formatted]
                forKey:kPepLongMessageFormatted];
    }
    
    if (message->longmsg) {
        [dict setValue:[NSString stringWithUTF8String:message->longmsg] forKey:kPepLongMessage];
    }
    
    if (message->attachments && message->attachments->value) {
        [dict setValue: PEP_arrayFromBloblist(message->attachments) forKey:kPepAttachments];
    }
    
    if (message->rawmsg_size > 0 && *message->rawmsg_ref) {
        NSData *data = [NSData dataWithBytes:message->rawmsg_ref length:message->rawmsg_size];
        dict[kPepRawMessage] = data;
    }
}

@implementation NSMutableDictionary (PEP)

- (void)replaceWithMessage:(message *)message
{
    replaceDictionaryContentsWithMessage(self, message);
}

@end
