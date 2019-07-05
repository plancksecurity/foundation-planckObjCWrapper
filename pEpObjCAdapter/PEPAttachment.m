//
//  PEPAttachment.m
//  pEpObjCAdapter
//
//  Created by Dirk Zimmermann on 16.04.18.
//  Copyright © 2018 p≡p. All rights reserved.
//

#import "PEPAttachment.h"

#import "bloblist.h"

@implementation PEPAttachment

- (instancetype)initWithData:(NSData *)data
{
    if (self = [super init]) {
        self.size = data.length;

        // 0-terminate the blob, just in case
        NSMutableData tmpData = [NSMutableData dataWithData:data];
        [tmpData appendBytes:"\0" length:1]
        self.data = [NSData dataWithData:tmpData];
    }
    return self;
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
