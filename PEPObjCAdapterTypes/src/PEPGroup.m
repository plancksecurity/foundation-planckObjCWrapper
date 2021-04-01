//
//  PEPGroup.m
//  pEpObjCAdapter
//
//  Created by Dirk Zimmermann on 01.04.21.
//  Copyright © 2021 p≡p. All rights reserved.
//

#import "PEPGroup.h"

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

@end
