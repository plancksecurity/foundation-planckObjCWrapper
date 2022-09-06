//
//  PEPMediaKeyPair.m
//  PEPObjCTypes
//
//  Created by Dirk Zimmermann on 06.09.22.
//

#import "PEPMediaKeyPair.h"

#import "NSObject+Equality.h"

@implementation PEPMediaKeyPair

- (instancetype)initWithPattern:(NSString *)pattern fingerprint:(NSString *)fingerprint
{
    self = [super init];
    if (self) {
        _pattern = pattern;
        _fingerprint = fingerprint;
    }
    return self;
}

// MARK: - Equality

- (BOOL)isEqualToPEPMediaKeyPair:(PEPMediaKeyPair * _Nonnull)mediaKeyPair
{
    return [self.pattern isEqualToString:mediaKeyPair.pattern] &&
    [self.fingerprint isEqualToString:mediaKeyPair.fingerprint];
}

- (NSUInteger)hash
{
    NSUInteger prime = 31;
    NSUInteger result = 1;

    result = prime * result + self.pattern.hash;
    result = prime * result + self.fingerprint.hash;

    return result;
}

- (BOOL)isEqual:(id)object
{
    if (object == self) {
        return YES;
    }
    if (!object || ![object isKindOfClass:[self class]]) {
        return NO;
    }

    return [self isEqualToPEPMediaKeyPair:object];
}

@end
