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
    [coder encodeObject:self.manager forKey:kKeyManager];
    [coder encodeObject:self.members forKey:kKeyMembers];
    [coder encodeBool:self.active forKey:kKeyActive];
}

- (nullable instancetype)initWithCoder:(nonnull NSCoder *)coder
{
    PEPIdentity *identity = [coder decodeObjectOfClass:[PEPIdentity class] forKey:kKeyIdentity];
    PEPIdentity *manager = [coder decodeObjectOfClass:[PEPIdentity class] forKey:kKeyManager];

    NSSet *identityArraySet = [NSSet setWithArray:@[[NSArray class], [PEPIdentity class]]];
    NSArray *members = [coder decodeObjectOfClasses:identityArraySet forKey:kKeyMembers];

    BOOL active = [coder decodeBoolForKey:kKeyActive];

    return [[PEPGroup alloc] initWithIdentity:identity
                                      manager:manager
                                      members:members
                                       active:active];
}

@end
