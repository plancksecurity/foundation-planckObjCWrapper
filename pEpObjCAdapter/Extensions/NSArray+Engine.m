//
//  NSArray+Engine.m
//  pEpiOSAdapter
//
//  Created by Dirk Zimmermann on 21.10.20.
//  Copyright © 2020 p≡p. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "NSArray+Engine.h"

#import "PEPIdentity.h"
#import "PEPIdentity+Engine.h"
#import "PEPAttachment.h"

@implementation NSArray (Engine)

+ (instancetype)arrayFromStringlist:(stringlist_t * _Nonnull)stringList
{
    NSMutableArray *array = [NSMutableArray array];

    for (stringlist_t *_sl = stringList; _sl && _sl->value; _sl = _sl->next) {
        [array addObject:[NSString stringWithUTF8String:_sl->value]];
    }

    return array;
}

+ (NSArray<PEPIdentity *> *)arrayFromIdentityList:(identity_list *)identityList
{
    NSMutableArray *array = [NSMutableArray array];

    for (identity_list *_il = identityList; _il && _il->ident; _il = _il->next) {
        [array addObject:[PEPIdentity fromStruct:_il->ident]];
    }

    return array;
}

+ (instancetype)arrayFromStringPairlist:(stringpair_list_t * _Nonnull)stringPairList
{
    NSMutableArray *array = [NSMutableArray array];

    for (stringpair_list_t *_sl = stringPairList; _sl && _sl->value; _sl = _sl->next) {
        [array addObject:[[NSMutableArray alloc ]initWithObjects:
                [NSString stringWithUTF8String:_sl->value->key],
                [NSString stringWithUTF8String:_sl->value->value],
                nil]];
    }

    return array;
}

+ (instancetype)arrayFromBloblist:(bloblist_t * _Nonnull)blobList
{
    NSMutableArray *array = [NSMutableArray array];

    for (bloblist_t *_bl = blobList; _bl && _bl->value; _bl = _bl->next) {
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

- (stringlist_t * _Nullable)toStringList
{
    if (self.count == 0) {
        return NULL;
    }

    stringlist_t *sl = new_stringlist(NULL);
    if (!sl)
        return NULL;

    stringlist_t *_sl = sl;
    for (NSString *str in self) {
        _sl = stringlist_add(_sl, [[str precomposedStringWithCanonicalMapping] UTF8String]);
    }

    return sl;
}

- (identity_list * _Nullable)toIdentityList
{
    if (self.count == 0) {
        return NULL;
    }

    identity_list *il = new_identity_list(NULL);
    if (!il)
        return NULL;

    identity_list *_il = il;
    for (PEPIdentity *address in self) {
        _il = identity_list_add(_il, [address toStruct]);
    }

    return il;
}

- (stringpair_list_t * _Nullable)toStringPairlist
{
    if (self.count == 0) {
        return NULL;
    }

    stringpair_list_t *sl = new_stringpair_list(NULL);
    if (!sl)
        return NULL;

    stringpair_list_t *_sl = sl;
    for (NSArray *pair in self) {
        stringpair_t *_sp = new_stringpair(
               [[pair[0] precomposedStringWithCanonicalMapping] UTF8String],
               [[pair[1] precomposedStringWithCanonicalMapping] UTF8String]);
        _sl = stringpair_list_add(_sl, _sp);
    }

    return sl;
}

- (bloblist_t * _Nullable)toBloblist
{
    if (self.count == 0) {
        return NULL;
    }

    bloblist_t *_bl = new_bloblist(NULL, 0, NULL, NULL);
    bloblist_t *bl =_bl;

    // free() might be the default, but let's be explicit
    bl->release_value = (void (*) (char *)) free;

    for (PEPAttachment *theAttachment in self) {
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
