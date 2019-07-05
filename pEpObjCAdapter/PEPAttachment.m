//
//  PEPAttachment.m
//  pEpObjCAdapter
//
//  Created by Dirk Zimmermann on 16.04.18.
//  Copyright © 2018 p≡p. All rights reserved.
//

#import "PEPAttachment.h"

#import "bloblist.h"

@interface PEPAttachment ()

/** Internal blob (binary data) _with_ 0-terminator. */
@property (nonatomic, nonnull) NSData *data;

@end

@implementation PEPAttachment

- (instancetype)initWithData:(NSData *)data
{
    if (self = [super init]) {
        self.size = data.length;

        // 0-terminate the blob, just in case
        NSMutableData *tmpData = [NSMutableData dataWithData:data];
        [tmpData appendBytes:"\0" length:1];
        self.data = [NSData dataWithData:tmpData];
    }
    return self;
}

- (NSData *)dataWithZeroTerminator
{
    return self.data;
}

- (NSData *)dataWithoutZeroTerminator
{
    return [NSData dataWithBytes:self.data.bytes length:self.size];
}

- (NSString *)description
{
    NSMutableString *str =
    [NSMutableString
     stringWithFormat:@"<PEPAttachment 0x%u %ld bytes, contentDisposition %d",
     (uint) self, (long) self.size, self.contentDisposition];

    if (self.mimeType) {
        [str appendFormat:@", %@", self.mimeType];
    }

    if (self.filename) {
        [str appendFormat:@", %@", self.filename];
    }

    [str appendString:@">"];
    return str;
}

@end
