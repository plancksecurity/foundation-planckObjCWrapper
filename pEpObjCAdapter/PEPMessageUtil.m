//
//  PEPMessageUtil.m
//  pEpiOSAdapter
//
//  Created by Volker Birk on 09.07.15.
//  Copyright (c) 2015 p≡p. All rights reserved.
//

#import "PEPMessageUtil.h"

#import <PEPObjCAdapterFramework/PEPIdentity.h>
#import "PEPMessage.h"
#import "PEPAttachment.h"
#import "NSMutableDictionary+PEP.h"

#import "pEp_string.h"

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
        PEPAttachment* theAttachment = [[PEPAttachment alloc]
                                        initWithData:[NSData
                                                      dataWithBytes:_bl->value length:_bl->size]];

        if(_bl->filename && _bl->filename[0]) {
            theAttachment.filename = [NSString stringWithUTF8String:_bl->filename];
        }

        if(_bl->mime_type && _bl->mime_type[0]) {
            theAttachment.mimeType = [NSString stringWithUTF8String:_bl->mime_type];
        }

        theAttachment.contentDisposition = _bl->disposition;
        
        [array addObject:theAttachment];
    }
    return array;
}

bloblist_t *PEP_arrayToBloblist(NSArray *array)
{
    if (array.count == 0) {
        return nil;
    }

    bloblist_t *_bl = new_bloblist(NULL, 0, NULL, NULL);
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

        bl->disposition = theAttachment.contentDisposition;
    }
    return _bl;
}

pEp_identity *PEP_identityDictToStruct(NSDictionary *dict)
{
    pEp_identity *ident = new_identity([[[dict objectForKey:kPepAddress]
                                         precomposedStringWithCanonicalMapping] UTF8String],
                                       [[[dict objectForKey:kPepFingerprint]
                                         precomposedStringWithCanonicalMapping] UTF8String],
                                       [[[dict objectForKey:kPepUserID]
                                         precomposedStringWithCanonicalMapping] UTF8String],
                                       [[[dict objectForKey:kPepUsername]
                                         precomposedStringWithCanonicalMapping] UTF8String]);
    if ([dict objectForKey:kPepIsOwn]) {
        ident->me = ((NSNumber*)[dict objectForKey:kPepIsOwn]).boolValue;
    }

    if (dict && ident) {
        if ([dict objectForKey:@"lang"])
            strncpy(ident->lang, [[[dict objectForKey:@"lang"]
                                   precomposedStringWithCanonicalMapping] UTF8String], 2);

        if ([dict objectForKey:kPepCommType])
            ident->comm_type = [[dict objectForKey:kPepCommType] intValue];
    }

    return ident;
}

NSDictionary *PEP_identityDictFromStruct(pEp_identity *ident)
{
    NSMutableDictionary *dict = [NSMutableDictionary new];

    if (ident) {
        if (ident->address && ident->address[0])
            [dict setObject:[NSString stringWithUTF8String:ident->address] forKey:kPepAddress];

        [dict setObject:[NSNumber numberWithBool: ident->me] forKey:kPepIsOwn];
        
        if (ident->fpr && ident->fpr[0])
            [dict setObject:[NSString stringWithUTF8String:ident->fpr] forKey:kPepFingerprint];
        
        if (ident->user_id && ident->user_id[0])
            [dict setObject:[NSString stringWithUTF8String:ident->user_id] forKey:kPepUserID];
        
        if (ident->username && ident->username[0])
            [dict setObject:[NSString stringWithUTF8String:ident->username] forKey:kPepUsername];
        
        if (ident->lang[0])
            [dict setObject:[NSString stringWithUTF8String:ident->lang] forKey:@"lang"];
        
        [dict setObject:[NSNumber numberWithInt: ident->comm_type] forKey:kPepCommType];
    }
    return dict;
}

pEp_identity *PEP_identityToStruct(PEPIdentity *identity)
{
    pEp_identity *ident = new_identity([[identity.address
                                         precomposedStringWithCanonicalMapping] UTF8String],
                                       [[identity.fingerPrint
                                         precomposedStringWithCanonicalMapping] UTF8String],
                                       [[identity.userID
                                         precomposedStringWithCanonicalMapping] UTF8String],
                                       [[identity.userName
                                         precomposedStringWithCanonicalMapping] UTF8String]);

    ident->me = identity.isOwn;

    if (identity.language) {
        strncpy(ident->lang, [[identity.language
                               precomposedStringWithCanonicalMapping] UTF8String], 2);
    }

    ident->comm_type = (PEP_comm_type) identity.commType;

    return ident;
}

PEPIdentity *PEP_identityFromStruct(pEp_identity *ident)
{
    PEPIdentity *identity = nil;
    if (ident->address && ident->address[0]) {
        identity = [[PEPIdentity alloc]
                    initWithAddress:[NSString stringWithUTF8String:ident->address]];
    }

    if (ident->fpr && ident->fpr[0]) {
        identity.fingerPrint = [NSString stringWithUTF8String:ident->fpr];
    }

    if (ident->user_id && ident->user_id[0]) {
        identity.userID = [NSString stringWithUTF8String:ident->user_id];
    }

    if (ident->username && ident->username[0]) {
        identity.userName = [NSString stringWithUTF8String:ident->username];
    }

    if (ident->lang[0]) {
        identity.language = [NSString stringWithUTF8String:ident->lang];
    }

    identity.commType = ident->comm_type;

    return identity;
}

NSArray<PEPIdentity *> *PEP_arrayFromIdentityList(identity_list *il)
{
    NSMutableArray *array = [NSMutableArray array];
    
    for (identity_list *_il = il; _il && _il->ident; _il = _il->next) {
        [array addObject:PEP_identityFromStruct(il->ident)];
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
        PEPIdentity *ident = PEP_identityFromStruct(_il->ident);
        [array addObject:ident];
    }
    
    return array;
}

NSDictionary *PEP_messageDictFromStruct(message *msg)
{
    NSMutableDictionary *dict = [NSMutableDictionary new];
    if (msg && dict) {
        [dict replaceWithMessage:msg];
    }
    return dict;
}

PEPMessage * _Nullable pEpMessageFromStruct(message * _Nullable msg)
{
    if (!msg) {
        return nil;
    }
    NSDictionary *dict = PEP_messageDictFromStruct(msg);
    PEPMessage *theMessage = [PEPMessage new];
    [theMessage setValuesForKeysWithDictionary:dict];
    return theMessage;
}

message *PEP_messageToStruct(PEPMessage *message) {
    return PEP_messageDictToStruct((NSDictionary *) message);
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
        msg->id = new_string([[[dict objectForKey:@"id"] precomposedStringWithCanonicalMapping]
                              UTF8String], 0);
    
    if ([dict objectForKey:@"shortmsg"])
        msg->shortmsg = new_string([[[dict objectForKey:@"shortmsg"]
                                     precomposedStringWithCanonicalMapping] UTF8String], 0);

    if ([dict objectForKey:@"sent"])
        msg->sent = new_timestamp([[dict objectForKey:@"sent"] timeIntervalSince1970]);
    
    if ([dict objectForKey:@"recv"])
        msg->recv = new_timestamp([[dict objectForKey:@"recv"] timeIntervalSince1970]);
    
    if ([dict objectForKey:kPepFrom])
        msg->from = PEP_identityDictToStruct([dict objectForKey:kPepFrom]);

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
    
    if ([dict objectForKey:kPepKeywords])
        msg->keywords = PEP_arrayToStringlist([dict objectForKey:kPepKeywords]);

    if ([dict objectForKey:@"opt_fields"])
        msg->opt_fields = PEP_arrayToStringPairlist([dict objectForKey:@"opt_fields"]);
    
    if ([dict objectForKey:@"longmsg"])
        msg->longmsg = new_string([[[dict objectForKey:@"longmsg"]
                                    precomposedStringWithCanonicalMapping] UTF8String], 0);
    
    if ([dict objectForKey:@"longmsg_formatted"])
        msg->longmsg_formatted = new_string([[[dict objectForKey:@"longmsg_formatted"]
                                              precomposedStringWithCanonicalMapping]
                                             UTF8String], 0);

    if ([dict objectForKey:@"attachments"])
        msg->attachments = PEP_arrayToBloblist([dict objectForKey:@"attachments"]);

    return msg;
}
