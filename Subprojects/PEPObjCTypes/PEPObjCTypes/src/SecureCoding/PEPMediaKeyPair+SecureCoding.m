//
//  PEPMediaKeyPair+SecureCoding.m
//  PEPObjCTypes
//
//  Created by Dirk Zimmermann on 06.09.22.
//

#import "PEPMediaKeyPair+SecureCoding.h"


@interface PEPMediaKeyPair ()

@property (nonatomic) NSString *pattern;
@property (nonatomic) NSString *fingerprint;

@end

@implementation PEPMediaKeyPair (SecureCoding)

+ (BOOL)supportsSecureCoding
{
    return YES;
}

- (nullable instancetype)initWithCoder:(nonnull NSCoder *)coder
{
    if (self = [self init]) {
        self.pattern = [coder decodeObjectOfClass:[NSString class] forKey:@"pattern"];
        self.fingerprint = [coder decodeObjectOfClass:[NSString class] forKey:@"fingerprint"];
    }

    return self;
}

- (void)encodeWithCoder:(nonnull NSCoder *)coder
{
    // TODO
}

@end
