//
//  MCOAbstractMessage+PEPMessage.m
//  pEpiOSAdapter
//
//  Created by Volker Birk on 09.07.15.
//  Copyright (c) 2015 p≡p. All rights reserved.
//

#import "MCOAbstractMessage+PEPMessage.h"
#import <MailCore/MailCore.h>

NSArray *PEP_arrayFromStringlist(stringlist_t *sl)
{
    NSMutableArray *array = [NSMutableArray array];
    
    for (stringlist_t *_sl = sl; _sl && _sl->value; _sl = _sl->next) {
        [array addObject:[NSString stringWithUTF8String:_sl->value]];
    }
    
    return array;
}

stringlist_t *PEP_arrayToStringlist(NSArray *array)
{
    stringlist_t *sl = new_stringlist(NULL);
    if (!sl)
        return NULL;
    
    stringlist_t *_sl = sl;
    for (NSString *str in array) {
        _sl = stringlist_add(_sl, [[str precomposedStringWithCanonicalMapping] UTF8String]);
    }
    
    return sl;
}

void PEP_identityFromStruct(NSMutableDictionary *dict, pEp_identity *ident)
{
    if (ident) {
        if (ident->address && ident->address[0])
            [dict setObject:[NSString stringWithUTF8String:ident->address] forKey:@"address"];
        
        if (ident->fpr && ident->fpr[0])
            [dict setObject:[NSString stringWithUTF8String:ident->fpr] forKey:@"fpr"];
        
        if (ident->user_id && ident->user_id[0])
            [dict setObject:[NSString stringWithUTF8String:ident->user_id] forKey:@"user_id"];
        
        if (ident->username && ident->username[0])
            [dict setObject:[NSString stringWithUTF8String:ident->username] forKey:@"username"];
        
        if (ident->lang[0])
            [dict setObject:[NSString stringWithUTF8String:ident->lang] forKey:@"lang"];
        
        [dict setObject:[NSNumber numberWithInt: ident->comm_type] forKey:@"comm_type"];
        
        if (ident->me)
            [dict setObject:@YES forKey:@"me"];
        else
            [dict setObject:@NO forKey:@"me"];
    }
}

pEp_identity *PEP_identityToStruct(NSDictionary *dict)
{
    pEp_identity *ident = new_identity(NULL, NULL, NULL, NULL);
    
    if (dict && ident) {
        if ([dict objectForKey:@"address"])
            ident->address = strdup(
                                    [[[dict objectForKey:@"address"] precomposedStringWithCanonicalMapping] UTF8String]
                                    );
        
        if ([dict objectForKey:@"fpr"])
            ident->fpr = strdup(
                                [[[dict objectForKey:@"fpr"] precomposedStringWithCanonicalMapping] UTF8String]
                                );
        
        if ([dict objectForKey:@"user_id"]){
            ident->user_id = strdup(
                                    [[[dict objectForKey:@"user_id"] precomposedStringWithCanonicalMapping] UTF8String]
                                    );
            ident->user_id_size = ident->user_id ? strlen(ident->user_id) : 0;
        }
        
        if ([dict objectForKey:@"username"])
            ident->username = strdup(
                                     [[[dict objectForKey:@"username"] precomposedStringWithCanonicalMapping] UTF8String]
                                     );
        
        if ([dict objectForKey:@"lang"])
            strncpy(ident->fpr, [[[dict objectForKey:@"lang"] precomposedStringWithCanonicalMapping] UTF8String], 2);
        
        if ([[dict objectForKey:@"me"] isEqual: @YES])
            ident->me = true;
        
        if ([dict objectForKey:@"comm_type"])
            ident->comm_type = [[dict objectForKey:@"comm_type"] intValue];
    }
    
    return ident;
}

NSArray *PEP_arrayFromIdentityList(identity_list *il)
{
    NSMutableArray *array = [NSMutableArray array];
    
    for (identity_list *_il = il; _il && _il->ident; _il = _il->next) {
        NSMutableDictionary * dict = [NSMutableDictionary dictionary];
        PEP_identityFromStruct(dict, il->ident);
        [array addObject:dict];
    }
    
    return array;
}

identity_list *PEP_arrayToIdentityList(NSArray *array)
{
    identity_list *il = new_identity_list(NULL);
    if (!il)
        return NULL;
    
    identity_list *_il = il;
    for (NSDictionary *dict in array) {
        _il = identity_list_add(_il, PEP_identityToStruct(dict));
    }
    
    return il;
}

identity_list *PEP_MCOAddressArrayToList(NSArray *array)
{
    identity_list *il = new_identity_list(NULL);
    if (!il)
        return NULL;
    
    identity_list *_il = il;
    for (MCOAddress *address in array) {
        _il = identity_list_add(_il, [address PEP_toStruct]);
    }
    
    return il;
}

NSMutableArray *PEP_MCOAddressArrayFromList(identity_list *il)
{
    NSMutableArray *array = [NSMutableArray array];
    
    for (identity_list *_il = il; _il && _il->ident; _il = _il->next) {
        MCOAddress * address = [[MCOAddress alloc]init];
        [address PEP_fromStruct:il->ident];
        [array addObject:address];
    }
    
    return array;
}

@implementation MCOAbstractMessage (PEPMessage)

BOOL _outgoing;

- (BOOL)outgoing
{
    return _outgoing;
}

- (void)setOutgoing:(BOOL)outgoing
{
    _outgoing = outgoing;
}

- (void)PEP_fromStruct:(message *)msg
{
    if (msg) {
        if (msg->id)
            self.header.messageID = [NSString stringWithUTF8String:msg->id];
        
        if (msg->shortmsg)
            self.header.subject = [NSString stringWithUTF8String:msg->shortmsg];
        
        if (msg->sent)
            self.header.date = [NSDate dateWithTimeIntervalSince1970:mktime(msg->sent)];
        
        if (msg->recv)
            self.header.receivedDate = [NSDate dateWithTimeIntervalSince1970:mktime(msg->recv)];
        
        if (msg->from)
            self.header.from = [[MCOAddress alloc] initWithStruct:msg->from];
        
        if (msg->to && msg->to->ident)
            self.header.to = PEP_MCOAddressArrayFromList(msg->to);
        
        if (msg->recv_by)
            self.header.sender = [[MCOAddress alloc] initWithStruct:msg->recv_by];
        
        if (msg->cc && msg->cc->ident)
            self.header.cc = PEP_MCOAddressArrayFromList(msg->cc);
        
        if (msg->bcc && msg->bcc->ident)
            self.header.bcc = PEP_MCOAddressArrayFromList(msg->bcc);
        
        if (msg->reply_to && msg->reply_to->ident)
            self.header.replyTo = PEP_MCOAddressArrayFromList(msg->reply_to);
        
        if (msg->references && msg->references->value)
            self.header.references = PEP_arrayFromStringlist(msg->references);
        
        if (msg->opt_fields) {
            for (stringpair_list_t *_sl = msg->opt_fields; _sl && _sl->value; _sl = _sl->next) {
                if (_sl->value->key && strcasecmp(_sl->value->key, "X-Mailer") == 0) {
                    self.header.userAgent = [NSString stringWithUTF8String:_sl->value->value];
                }
            }
        }
        
        if ([self isKindOfClass: [MCOMessageBuilder class]]) {
            MCOMessageBuilder * me = (MCOMessageBuilder *) self;
            
            if (msg->longmsg_formatted)
                me.htmlBody = [NSString stringWithUTF8String:msg->longmsg_formatted];
            else if (msg->longmsg)
                me.htmlBody = [NSString stringWithUTF8String:msg->longmsg];
        
            if (msg->attachments && msg->attachments->value) {
                for (bloblist_t *_bl = msg->attachments; _bl && _bl->value; _bl = _bl->next) {
                    MCOAttachment * attachment = [MCOAttachment attachmentWithData:[NSData dataWithBytes:_bl->value length:_bl->size] filename:[NSString stringWithUTF8String:_bl->filename]];
                    attachment.mimeType = [NSString stringWithUTF8String:_bl->mime_type];
                    me.attachments = [me.attachments arrayByAddingObject:attachment];
                }
            }
        }
        else {
            assert(0); // this has to be a MCOMessageBuilder
        }

    }
}

- (message *)PEP_toStruct
{
    message *msg = new_message([self outgoing] ? PEP_dir_outgoing : PEP_dir_incoming);
    
    if (self.header.messageID)
        msg->id = strdup([self.header.messageID UTF8String]);
    
    if (self.header.subject)
        msg->shortmsg = strdup([[self.header.subject precomposedStringWithCanonicalMapping] UTF8String]);
    
    if (self.header.date)
        msg->sent = new_timestamp([self.header.date timeIntervalSince1970]);
    
    if (self.header.receivedDate)
        msg->recv = new_timestamp([self.header.receivedDate timeIntervalSince1970]);
    
    if (self.header.from)
        msg->from = [self.header.from PEP_toStruct];
    
    if (self.header.to.count)
        msg->to = PEP_MCOAddressArrayToList(self.header.to);
    
    if (self.header.sender)
        msg->recv_by = [self.header.sender PEP_toStruct];
    
    if (self.header.cc.count)
        msg->cc = PEP_MCOAddressArrayToList(self.header.cc);
    
    if (self.header.bcc.count)
        msg->bcc = PEP_MCOAddressArrayToList(self.header.bcc);
    
    if (self.header.replyTo.count)
        msg->reply_to = PEP_MCOAddressArrayToList(self.header.replyTo);
    
    if (self.header.inReplyTo.count)
        msg->in_reply_to = PEP_arrayToStringlist(self.header.inReplyTo);
    
    if (self.header.references.count)
        msg->references = PEP_arrayToStringlist(self.header.references);
    
    if (self.header.userAgent && ![self.header.userAgent isEqual: @""])
        msg->opt_fields = new_stringpair_list(new_stringpair("X-Mailer", [[self.header.userAgent precomposedStringWithCanonicalMapping] UTF8String]));
    
    NSString *html;
    NSString *plain;
    
    if ([self isKindOfClass: [MCOMessageBuilder class]]) {
        MCOMessageBuilder * me = (MCOMessageBuilder *) self;
        html = me.htmlBodyRendering;
        plain = me.plainTextRendering;
    }
    else if ([self isKindOfClass: [MCOMessageParser class]]) {
        MCOMessageParser * me = (MCOMessageParser *) self;
        html = me.htmlBodyRendering;
        plain = me.plainTextRendering;
    }
    else /* if ([self isKindOfClass: [MCOIMAPMessage class]]) */ {
        assert(0); // an MCOIMAPMessage cannot be rendered directly
    }
    
    msg->longmsg = strdup([[plain precomposedStringWithCanonicalMapping] UTF8String]);
    msg->longmsg_formatted = strdup([[html precomposedStringWithCanonicalMapping] UTF8String]);
    
    if ([self.htmlInlineAttachments count]) {
        msg->attachments = new_bloblist(NULL, 0, NULL, NULL);
        
        bloblist_t *_bl = msg->attachments;
        for (MCOAttachment *attachment in self.htmlInlineAttachments) {
            size_t size = [[attachment data] length];
            
            char *data = malloc(size);
            assert(data);
            memcpy(data, [[attachment data] bytes], size);
            
            _bl = bloblist_add(_bl, data, size, [[attachment mimeType] UTF8String], [[[attachment filename] precomposedStringWithCanonicalMapping] UTF8String]);
        }
    }

    if ([self.attachments count]) {
        if (msg->attachments == NULL)
            msg->attachments = new_bloblist(NULL, 0, NULL, NULL);
        
        bloblist_t *_bl = msg->attachments;
        for (MCOAttachment *attachment in self.attachments) {
            size_t size = [[attachment data] length];
            
            char *data = malloc(size);
            assert(data);
            memcpy(data, [[attachment data] bytes], size);

            _bl = bloblist_add(_bl, data, size, [[attachment mimeType] UTF8String], [[[attachment filename] precomposedStringWithCanonicalMapping] UTF8String]);
        }
    }

    return msg;
}

@end
