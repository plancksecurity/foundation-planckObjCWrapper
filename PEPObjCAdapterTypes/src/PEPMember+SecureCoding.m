//
//  PEPMember+SecureCoding.m
//  pEpObjCAdapter
//
//  Created by Dirk Zimmermann on 16.04.21.
//  Copyright © 2021 p≡p. All rights reserved.
//

#import "PEPMember+SecureCoding.h"

#import "PEPIdentity.h"

static NSString * const kKeyIdentity = @"identity";
static NSString * const kKeyJoined = @"joined";

@implementation PEPMember (SecureCoding)

+ (BOOL)supportsSecureCoding
{
    return YES;
}

- (void)encodeWithCoder:(nonnull NSCoder *)coder
{
    [coder encodeObject:self.identity forKey:kKeyIdentity];
    [coder encodeBool:self.joined forKey:kKeyJoined];
}

- (nullable instancetype)initWithCoder:(nonnull NSCoder *)coder
{
    PEPIdentity *identity = [coder decodeObjectOfClass:[PEPIdentity class] forKey:kKeyIdentity];
    BOOL joined = [coder decodeBoolForKey:kKeyJoined];

    return [self initWithIdentity:identity joined:joined];
}

@end
