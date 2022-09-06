//
//  PEPMediaKeyPair+SecureCoding.m
//  PEPObjCTypes
//
//  Created by Dirk Zimmermann on 06.09.22.
//

#import "PEPMediaKeyPair+SecureCoding.h"

@implementation PEPMediaKeyPair (SecureCoding)

+ (BOOL)supportsSecureCoding
{
    return YES;
}

- (nullable instancetype)initWithCoder:(nonnull NSCoder *)coder
{
    NSString *pattern = [coder decodeObjectOfClass:[NSString class] forKey:@"pattern"];
    NSString *fingerprint = [coder decodeObjectOfClass:[NSString class] forKey:@"fingerprint"];

    if (pattern == nil || fingerprint == nil) {
        return nil;
    }

    return [[PEPMediaKeyPair alloc] initWithPattern:pattern fingerprint:fingerprint];
}

- (void)encodeWithCoder:(nonnull NSCoder *)coder
{
    // TODO
}

@end
