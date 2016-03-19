//
//  PEPMessage.m
//  pEpiOSAdapter
//
//  Created by Volker Birk on 09.07.15.
//  Copyright (c) 2015 p≡p. All rights reserved.
//

#import "PEPMessage.h"

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

NSArray *PEP_arrayFromStringPairlist(stringpair_list_t *sl)
{
    NSMutableArray *array = [NSMutableArray array];

    for (stringpair_list_t *_sl = sl; _sl && _sl->value; _sl = _sl->next) {
        [array addObject:[[NSMutableArray alloc ]initWithObjects:
                [NSString stringWithUTF8String:_sl->value->key],
                [NSString stringWithUTF8String:_sl->value->value],
                nil]];
    }

    return array;
}

stringpair_list_t *PEP_arrayToStringPairlist(NSArray *array)
{
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


NSArray *PEP_arrayFromBloblist(bloblist_t *bl)
{
    NSMutableArray *array = [NSMutableArray array];
    
    for (bloblist_t *_bl = bl; _bl && _bl->value; _bl = _bl->next) {
        NSMutableDictionary* blob = [NSMutableDictionary new];
        [blob setObject: [NSData dataWithBytes:_bl->value
                                 length:_bl->size]
              forKey:@"data"];
        
        if(_bl->filename && _bl->filename[0])
            [blob setObject:[NSString stringWithUTF8String:_bl->filename]
                 forKey:@"filename"];
        
        if(_bl->mime_type && _bl->mime_type[0])
            [blob setObject: [NSString stringWithUTF8String:_bl->mime_type]
                 forKey:@"mimeType"];
        
        [array addObject:blob];
    }
    return array;
}

bloblist_t *PEP_arrayToBloblist(NSArray *array)
{
    bloblist_t *_bl = new_bloblist(NULL, 0, NULL, NULL);
    bloblist_t *bl =_bl;
    for (NSMutableDictionary *blob in array) {
        NSData *data = blob[@"data"];
        size_t size = [data length];
        
        char *buf = malloc(size);
        assert(buf);
        memcpy(buf, [data bytes], size);
        
        bl = bloblist_add(bl, buf, size,
                          [blob[@"mimeType"] UTF8String],
                          [[blob[@"filename"] precomposedStringWithCanonicalMapping] UTF8String]);
    }
    return _bl;
}

NSDictionary *PEP_identityDictFromStruct(pEp_identity *ident)
{
    NSMutableDictionary *dict = [NSMutableDictionary new];

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

pEp_identity *PEP_identityDictToStruct(NSDictionary *dict)
{
    pEp_identity *ident = new_identity(NULL, NULL, NULL, NULL);
    
    if (dict && ident) {
        if ([dict objectForKey:@"address"])
            ident->address = strdup(
                                    [[[dict objectForKey:@"address"] precomposedStringWithCanonicalMapping] UTF8String]
                                    );
        
        if ([dict objectForKey:@"fpr"]){
            ident->fpr = strdup(
                                [[[dict objectForKey:@"fpr"] precomposedStringWithCanonicalMapping] UTF8String]
                                );
            ident->fpr_size = ident->fpr ? strlen(ident->fpr) : 0;
        }
        
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
        [array addObject:PEP_identityDictFromStruct(il->ident)];
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
        _il = identity_list_add(_il, PEP_identityDictToStruct(dict));
    }
    
    return il;
}

identity_list *PEP_identityArrayToList(NSArray *array)
{
    identity_list *il = new_identity_list(NULL);
    if (!il)
        return NULL;
    
    identity_list *_il = il;
    for (NSMutableDictionary *address in array) {
        _il = identity_list_add(_il, PEP_identityDictToStruct(address));
    }
    
    return il;
}

NSArray *PEP_identityArrayFromList(identity_list *il)
{
    NSMutableArray *array = [NSMutableArray array];
    
    for (identity_list *_il = il; _il && _il->ident; _il = _il->next) {
        NSDictionary *address = PEP_identityDictFromStruct(_il->ident);
        [array addObject:address];
    }
    
    return array;
}

NSDictionary *PEP_messageDictFromStruct(message *msg)
{
    NSMutableDictionary *dict = [NSMutableDictionary new];
    if (msg && dict) {

        [dict setObject:(msg->dir==PEP_dir_outgoing)?@YES:@NO forKey:@"outgoing"];

        if (msg->id)
            [dict setObject:[NSString stringWithUTF8String:msg->id] forKey:@"id"];
        
        if (msg->shortmsg)
            [dict setObject:[NSString stringWithUTF8String:msg->shortmsg] forKey:@"shortmsg"];

        if (msg->sent)
            [dict setObject:[NSDate dateWithTimeIntervalSince1970:mktime(msg->sent)] forKey:@"sent"];
        
        if (msg->recv)
            [dict setObject:[NSDate dateWithTimeIntervalSince1970:mktime(msg->recv)] forKey:@"recv"];
        
        if (msg->from)
            [dict setObject:PEP_identityDictFromStruct(msg->from) forKey:@"from"];
        
        if (msg->to && msg->to->ident)
            [dict setObject:PEP_identityArrayFromList(msg->to) forKey:@"to"];
        
        if (msg->recv_by)
            [dict setObject:PEP_identityDictFromStruct(msg->recv_by) forKey:@"recv_by"];
        
        if (msg->cc && msg->cc->ident)
            [dict setObject:PEP_identityArrayFromList(msg->cc) forKey:@"cc"];
        
        if (msg->bcc && msg->bcc->ident)
            [dict setObject:PEP_identityArrayFromList(msg->bcc) forKey:@"bcc"];
        
        if (msg->reply_to && msg->reply_to->ident)
            [dict setObject:PEP_identityArrayFromList(msg->reply_to) forKey:@"reply_to"];
        
        if (msg->in_reply_to)
            [dict setObject:PEP_arrayFromStringlist(msg->in_reply_to) forKey:@"in_reply_to"];

        if (msg->references && msg->references->value)
            [dict setObject:PEP_arrayFromStringlist(msg->references) forKey:@"references"];
        
        if (msg->opt_fields)
            [dict setObject:PEP_arrayFromStringPairlist(msg->opt_fields) forKey:@"opt_fields"];
        
        if (msg->longmsg_formatted)
            [dict setObject:[NSString stringWithUTF8String:msg->longmsg_formatted]
                     forKey:@"longmsg_formatted"];

        if (msg->longmsg)
            [dict setObject:[NSString stringWithUTF8String:msg->longmsg] forKey:@"longmsg"];
        
        if (msg->attachments && msg->attachments->value)
            [dict setObject: PEP_arrayFromBloblist(msg->attachments) forKey:@"attachments"];

        return dict;
    }
    return nil;
}


message *PEP_messageDictToStruct(NSDictionary *dict)
{
    // Direction default to incoming
    PEP_msg_direction dir = PEP_dir_incoming;
    
    if ([dict objectForKey:@"outgoing"])
        dir = [[dict objectForKey:@"outgoing"] boolValue] ? PEP_dir_outgoing : PEP_dir_incoming;
    
    message *msg = new_message(dir);
    
    if(!msg)
        return NULL;
    
    if ([dict objectForKey:@"id"])
        msg->id = strdup([[[dict objectForKey:@"id"] precomposedStringWithCanonicalMapping]
                          UTF8String]);
    
    if ([dict objectForKey:@"shortmsg"])
        msg->shortmsg = strdup([[[dict objectForKey:@"shortmsg"]
                                 precomposedStringWithCanonicalMapping] UTF8String]);

    if ([dict objectForKey:@"sent"])
        msg->sent = new_timestamp([[dict objectForKey:@"sent"] timeIntervalSince1970]);
    
    if ([dict objectForKey:@"recv"])
        msg->recv = new_timestamp([[dict objectForKey:@"recv"] timeIntervalSince1970]);
    
    if ([dict objectForKey:@"from"])
        msg->from = PEP_identityDictToStruct([dict objectForKey:@"from"]);

    if ([dict objectForKey:@"to"])
        msg->to = PEP_identityArrayToList([dict objectForKey:@"to"]);

    if ([dict objectForKey:@"recv_by"])
        msg->recv_by = PEP_identityDictToStruct([dict objectForKey:@"recv_by"]);

    if ([dict objectForKey:@"cc"])
        msg->cc = PEP_identityArrayToList([dict objectForKey:@"cc"]);

    if ([dict objectForKey:@"bcc"])
        msg->bcc = PEP_identityArrayToList([dict objectForKey:@"bcc"]);
    
    if ([dict objectForKey:@"reply_to"])
        msg->reply_to = PEP_identityArrayToList([dict objectForKey:@"reply_to"]);
    
    if ([dict objectForKey:@"in_reply_to"])
        msg->in_reply_to = PEP_arrayToStringlist([dict objectForKey:@"in_reply_to"]);
    
    if ([dict objectForKey:@"references"])
        msg->references = PEP_arrayToStringlist([dict objectForKey:@"references"]);
    
    if ([dict objectForKey:@"opt_fields"])
        msg->opt_fields = PEP_arrayToStringPairlist([dict objectForKey:@"opt_fields"]);
    
    if ([dict objectForKey:@"longmsg"])
        msg->longmsg = strdup([[[dict objectForKey:@"longmsg"]
             precomposedStringWithCanonicalMapping] UTF8String]);
    
    if ([dict objectForKey:@"longmsg_formatted"])
        msg->longmsg_formatted = strdup([[[dict objectForKey:@"longmsg_formatted"]
             precomposedStringWithCanonicalMapping] UTF8String]);

    if ([dict objectForKey:@"attachments"])
        msg->attachments = PEP_arrayToBloblist([dict objectForKey:@"attachments"]);

    return msg;
}
