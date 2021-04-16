//
//  PEPMember+SecureCoding.m
//  pEpObjCAdapter
//
//  Created by Dirk Zimmermann on 16.04.21.
//  Copyright © 2021 p≡p. All rights reserved.
//

#import "PEPMember+SecureCoding.h"

#import "PEPIdentity.h"

@implementation PEPMember (SecureCoding)

+ (BOOL)supportsSecureCoding
{
    return YES;
}

- (void)encodeWithCoder:(nonnull NSCoder *)coder
{
    [coder encodeObject:self.identity forKey:@"identity"];
    [coder encodeBool:self.joined forKey:@"joined"];
}

- (nullable instancetype)initWithCoder:(nonnull NSCoder *)coder
{
    PEPIdentity *identity = [coder decodeObjectOfClass:[PEPIdentity class] forKey:@"identity"];
    BOOL joined = [coder decodeBoolForKey:@"joined"];

    return [self initWithIdentity:identity joined:joined];
}

@end
