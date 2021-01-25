//
//  PEPAttachment+SecureCoding.m
//  PEPObjCAdapterTypes_macOS
//
//  Created by David Alarcon on 25/1/21.
//  Copyright © 2021 p≡p. All rights reserved.
//

#import "PEPAttachment+SecureCoding.h"

@implementation PEPAttachment (SecureCoding)

/*
 @property (nonatomic, nonnull) NSData *data;
 @property (nonatomic) NSInteger size;
 @property (nonatomic, nullable) NSString *mimeType;
 @property (nonatomic, nullable) NSString *filename;
 @property (nonatomic) PEPContentDisposition contentDisposition;
 */

- (void)encodeWithCoder:(nonnull NSCoder *)coder {
    [coder encodeObject:self.data               forKey:@"data"];
    [coder encodeInteger:self.size              forKey:@"size"];
    [coder encodeObject:self.mimeType           forKey:@"mimeType"];
    [coder encodeObject:self.filename           forKey:@"filename"];
    [coder encodeInt:self.contentDisposition    forKey:@"contentDisposition"];
}

- (nullable instancetype)initWithCoder:(nonnull NSCoder *)decoder {
    if (self = [self init]) {
        self.data =                 [decoder decodeObjectOfClass:[NSData class] forKey:@"data"];
        self.size =                 [decoder decodeIntegerForKey:@"size"];
        self.mimeType =             [decoder decodeObjectOfClass:[NSString class] forKey:@"mimeType"];
        self.filename =             [decoder decodeObjectOfClass:[NSString class] forKey:@"filename"];
        self.contentDisposition =   [decoder decodeIntForKey:@"contentDisposition"];
    }

    return self;
}

+ (BOOL)supportsSecureCoding {
    return  YES;
}

@end
