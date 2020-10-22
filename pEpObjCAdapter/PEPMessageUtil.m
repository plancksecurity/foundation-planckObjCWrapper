//
//  PEPMessageUtil.m
//  pEpiOSAdapter
//
//  Created by Volker Birk on 09.07.15.
//  Copyright (c) 2015 p≡p. All rights reserved.
//

#import "PEPMessageUtil.h"

#import "PEPConstants.h"
#import "PEPIdentity.h"

#import "PEPMessage.h"
#import "PEPAttachment.h"
#import "NSMutableDictionary+PEP.h"
#import "NSArray+Engine.h"
#import "PEPIdentity+Engine.h"

#import "pEp_string.h"

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

        theAttachment.contentDisposition = (PEPContentDisposition) _bl->disposition;
        
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

        bl->disposition = (content_disposition_type) theAttachment.contentDisposition;
    }
    return _bl;
}

NSDictionary *PEP_messageDictFromStruct(message *msg)
{
    NSMutableDictionary *dict = [NSMutableDictionary new];
    if (msg && dict) {
        [dict replaceWithMessage:msg];
    }
    return dict;
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
        msg->from = [[dict objectForKey:kPepFrom] toStruct];

    if ([dict objectForKey:@"to"])
        msg->to = [[dict objectForKey:@"to"] toIdentityList];

    if ([dict objectForKey:@"recv_by"])
        msg->recv_by = [[dict objectForKey:@"recv_by"] toStruct];

    if ([dict objectForKey:@"cc"])
        msg->cc = [[dict objectForKey:@"cc"] toIdentityList];

    if ([dict objectForKey:@"bcc"])
        msg->bcc = [[dict objectForKey:@"bcc"] toIdentityList];
    
    if ([dict objectForKey:@"reply_to"])
        msg->reply_to = [[dict objectForKey:@"reply_to"] toIdentityList];
    
    if ([dict objectForKey:@"in_reply_to"])
        msg->in_reply_to = [[dict objectForKey:@"in_reply_to"] toStringList];
    
    if ([dict objectForKey:@"references"])
        msg->references = [[dict objectForKey:@"references"] toStringList];
    
    if ([dict objectForKey:kPepKeywords])
        msg->keywords = [[dict objectForKey:kPepKeywords] toStringList];

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
