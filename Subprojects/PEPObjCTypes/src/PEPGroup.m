//
//  PEPGroup.m
//  pEpObjCAdapter
//
//  Created by Dirk Zimmermann on 01.04.21.
//  Copyright © 2021 p≡p. All rights reserved.
//

#import "PEPGroup.h"

#import "PEPIdentity.h"

@implementation PEPGroup

- (instancetype)initWithIdentity:(PEPIdentity *)identity
                         manager:(PEPIdentity *)manager
                         members:(NSArray<PEPMember *> *)members
                          active:(BOOL)active
{
    self = [super init];
    if (self) {
        _identity = identity;
        _manager = manager;
        _members = members;
        _active = active;
    }
    return self;
}

- (BOOL)isEqual:(id)other
{
    if (other == self) {
        return YES;
    }

    if (!other || ![other isKindOfClass:[self class]]) {
        return NO;
    }

    PEPGroup *otherGroup = other;
    return [self.identity isEqual:otherGroup.identity] &&
    [self.manager isEqual:otherGroup.manager] &&
    [self.members isEqualToArray:otherGroup.members] &&
    self.active == otherGroup.active;
}

- (NSUInteger)hash
{
    NSUInteger prime = 31;
    NSUInteger result = 1;

    result = prime * result + [self.identity hash];
    result = prime * result + [self.manager hash];
    result = prime * result + [self.members hash];
    result = prime * result + ((self.active) ? 1231 : 1237);

    return result;
}

@end
