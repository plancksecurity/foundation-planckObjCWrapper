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
    // TODO
    return nil;
}

- (void)encodeWithCoder:(nonnull NSCoder *)coder
{
    // TODO
}

@end
