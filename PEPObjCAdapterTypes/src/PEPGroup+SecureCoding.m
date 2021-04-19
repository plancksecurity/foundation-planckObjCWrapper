//
//  PEPGroup+SecureCoding.m
//  pEpObjCAdapter
//
//  Created by Dirk Zimmermann on 19.04.21.
//  Copyright © 2021 p≡p. All rights reserved.
//

#import "PEPGroup+SecureCoding.h"

#import "PEPIdentity.h"

static NSString * const kKeyIdentity = @"identity";
static NSString * const kKeyManager = @"manager";
static NSString * const kKeyMembers = @"members";
static NSString * const kKeyActive = @"active";

@implementation PEPGroup (SecureCoding)

+ (BOOL)supportsSecureCoding
{
    return YES;
}

- (void)encodeWithCoder:(nonnull NSCoder *)coder
{
    [coder encodeObject:self.identity forKey:kKeyIdentity];
    [coder encodeBool:self.active forKey:kKeyActive];
}

- (nullable instancetype)initWithCoder:(nonnull NSCoder *)coder
{
    PEPIdentity *identity = [coder decodeObjectOfClass:[PEPIdentity class] forKey:kKeyIdentity];
    BOOL joined = [coder decodeBoolForKey:kKeyActive];

    return nil;
}

@end
