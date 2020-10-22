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
