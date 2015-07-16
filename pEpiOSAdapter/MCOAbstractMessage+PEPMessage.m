//
//  MCOAbstractMessage+PEPMessage.m
//  pEpiOSAdapter
//
//  Created by Volker Birk on 09.07.15.
//  Copyright (c) 2015 p≡p. All rights reserved.
//

#import "MCOAbstractMessage+PEPMessage.h"

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

NSMutableDictionary *PEP_identityFromStruct(pEp_identity *ident)
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    
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
    
    return dict;
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
        
        if ([dict objectForKey:@"user_id"])
            ident->user_id = strdup(
                                    [[[dict objectForKey:@"user_id"] precomposedStringWithCanonicalMapping] UTF8String]
                                    );
        
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
        NSMutableDictionary * dict = PEP_identityFromStruct(il->ident);
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

pEp_identity *PEP_MCOAddressToStruct(MCOAddress *address)
{
    pEp_identity *ident = new_identity([[address.mailbox precomposedStringWithCanonicalMapping] UTF8String], NULL, NULL, [[address.displayName precomposedStringWithCanonicalMapping] UTF8String]);
    return ident;
}

MCOAddress *PEP_MCOAddressFromStruct(pEp_identity *ident)
{
    MCOAddress *address = [MCOAddress addressWithDisplayName:[NSString stringWithUTF8String:ident->username] mailbox:[NSString stringWithUTF8String:ident->address]];
    return address;
}

identity_list *PEP_MCOAddressArrayToList(NSArray *array)
{
    identity_list *il = new_identity_list(NULL);
    if (!il)
        return NULL;
    
    identity_list *_il = il;
    for (MCOAddress *address in array) {
        _il = identity_list_add(_il, PEP_MCOAddressToStruct(address));
    }
    
    return il;
}

NSMutableArray *PEP_MCOAddressArrayFromList(identity_list *il)
{
    NSMutableArray *array = [NSMutableArray array];
    
    for (identity_list *_il = il; _il && _il->ident; _il = _il->next) {
        MCOAddress * address = PEP_MCOAddressFromStruct(il->ident);
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
    
}

- (message *)PEP_toStruct
{
    message *_msg = new_message([self outgoing] ? PEP_dir_outgoing : PEP_dir_incoming);
    
    _msg->id = strdup([self.header.messageID UTF8String]);
    _msg->shortmsg = strdup([[self.header.subject precomposedStringWithCanonicalMapping] UTF8String]);
    _msg->sent = new_timestamp([self.header.date timeIntervalSince1970]);
    _msg->recv = new_timestamp([self.header.receivedDate timeIntervalSince1970]);
    _msg->from = PEP_MCOAddressToStruct(self.header.from);
    _msg->to = PEP_MCOAddressArrayToList(self.header.to);
    _msg->recv_by = PEP_MCOAddressToStruct(self.header.sender);
    _msg->cc = PEP_MCOAddressArrayToList(self.header.cc);
    _msg->bcc = PEP_MCOAddressArrayToList(self.header.bcc);
    _msg->reply_to = PEP_MCOAddressArrayToList(self.header.replyTo);
    _msg->in_reply_to = PEP_arrayToStringlist(self.header.inReplyTo);
    _msg->references = PEP_arrayToStringlist(self.header.references);
    
    if (![self.header.userAgent isEqual: @""])
        _msg->opt_fields = new_stringpair_list(new_stringpair("X-Mailer", [[self.header.userAgent precomposedStringWithCanonicalMapping] UTF8String]));
    
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
    else if ([self isKindOfClass: [MCOIMAPMessage class]]) {
        assert(0); // an MCOIMAPMessage cannot be rendered directly but this is needed
    }
    
    _msg->longmsg = strdup([[plain precomposedStringWithCanonicalMapping] UTF8String]);
    _msg->longmsg_formatted = strdup([[html precomposedStringWithCanonicalMapping] UTF8String]);
    
    if ([self.htmlInlineAttachments count]) {
        _msg->attachments = new_bloblist(NULL, 0, NULL, NULL);
        
        bloblist_t *_bl = _msg->attachments;
        for (MCOAttachment *attachment in self.htmlInlineAttachments) {
            size_t size = [[attachment data] length];
            
            char *data = malloc(size);
            assert(data);
            memcpy(data, [[attachment data] bytes], size);
            
            _bl = bloblist_add(_bl, data, size, [[attachment mimeType] UTF8String], [[[attachment filename] precomposedStringWithCanonicalMapping] UTF8String]);
        }
    }

    if ([self.attachments count]) {
        if (_msg->attachments == NULL)
            _msg->attachments = new_bloblist(NULL, 0, NULL, NULL);
        
        bloblist_t *_bl = _msg->attachments;
        for (MCOAttachment *attachment in self.attachments) {
            size_t size = [[attachment data] length];
            
            char *data = malloc(size);
            assert(data);
            memcpy(data, [[attachment data] bytes], size);

            _bl = bloblist_add(_bl, data, size, [[attachment mimeType] UTF8String], [[[attachment filename] precomposedStringWithCanonicalMapping] UTF8String]);
        }
    }

    return _msg;
}

@end
