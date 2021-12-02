//
//  PEPAttachment.m
//  pEpObjCAdapter
//
//  Created by Dirk Zimmermann on 16.04.18.
//  Copyright © 2018 p≡p. All rights reserved.
//

#import "PEPAttachment.h"

@implementation PEPAttachment

- (instancetype)initWithData:(NSData *)data
{
    if (self = [super init]) {
        self.data = data;
        self.size = data.length;
    }
    return self;
}

- (NSString *)description
{
    NSMutableString *str =
    [NSMutableString
     stringWithFormat:@"<PEPAttachment 0x%ld %ld bytes, contentDisposition %d",
     (long) self, (long) self.size, self.contentDisposition];

    if (self.mimeType) {
        [str appendFormat:@", %@", self.mimeType];
    }

    if (self.filename) {
        [str appendFormat:@", %@", self.filename];
    }

    [str appendString:@">"];
    return str;
}

// MARK: - NSSecureCoding

- (nullable instancetype)initWithCoder:(nonnull NSCoder *)decoder {
    if (self = [self init]) {
        self.data = [decoder decodeObjectOfClass:[NSData class] forKey:@"data"];
        self.size = [decoder decodeIntegerForKey:@"size"];
        self.mimeType = [decoder decodeObjectOfClass:[NSString class] forKey:@"mimeType"];
        self.filename = [decoder decodeObjectOfClass:[NSString class] forKey:@"filename"];
        self.contentDisposition = [decoder decodeIntForKey:@"contentDisposition"];
    }

    return self;
}

- (void)encodeWithCoder:(nonnull NSCoder *)coder {
    [coder encodeObject:self.data forKey:@"data"];
    [coder encodeInteger:self.size forKey:@"size"];
    [coder encodeObject:self.mimeType forKey:@"mimeType"];
    [coder encodeObject:self.filename forKey:@"filename"];
    [coder encodeInt:self.contentDisposition forKey:@"contentDisposition"];
}

+ (BOOL)supportsSecureCoding {
    return YES;
}

@end
