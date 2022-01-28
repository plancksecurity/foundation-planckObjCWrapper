//
//  NSArray+PEPBloblist.m
//  PEPObjCTypeUtils
//
//  Created by Martín Brude on 28/1/22.
//

#import "NSArray+PEPBloblist.h"
#import "PEPAttachment.h"

@implementation NSArray (PEPBloblist)

+ (NSArray<PEPAttachment*> *)fromBloblist:(const bloblist_t * _Nonnull)blobList {
    NSMutableArray *array = [NSMutableArray array];

    for (const bloblist_t *_bl = blobList; _bl && _bl->value; _bl = _bl->next) {
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

- (bloblist_t * _Nullable)toBloblist {
    if (self.count == 0) {
        return NULL;
    }

    bloblist_t *_bl = new_bloblist(NULL, 0, NULL, NULL);

    if (!_bl) {
        return NULL;
    }

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
