//
//  PEPMediaKeyPair+SecureCoding.m
//  PEPObjCTypes
//
//  Created by Dirk Zimmermann on 06.09.22.
//

#import "PEPMediaKeyPair+SecureCoding.h"

static NSString * const kPattern = @"pattern";
static NSString * const kFingerprint = @"fingerprint";

@implementation PEPMediaKeyPair (SecureCoding)

+ (BOOL)supportsSecureCoding
{
    return YES;
}

- (nullable instancetype)initWithCoder:(nonnull NSCoder *)coder
{
    NSString *pattern = [coder decodeObjectOfClass:[NSString class] forKey:kPattern];
    NSString *fingerprint = [coder decodeObjectOfClass:[NSString class] forKey:kFingerprint];

    if (pattern == nil || fingerprint == nil) {
        return nil;
    }

    return [[PEPMediaKeyPair alloc] initWithPattern:pattern fingerprint:fingerprint];
}

- (void)encodeWithCoder:(nonnull NSCoder *)coder
{
    [coder encodeObject:self.pattern forKey:kPattern];
    [coder encodeObject:self.fingerprint forKey:kFingerprint];
}

@end
