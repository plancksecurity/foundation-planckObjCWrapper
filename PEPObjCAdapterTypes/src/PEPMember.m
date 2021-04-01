//
//  PEPMember.m
//  pEpObjCAdapter
//
//  Created by Dirk Zimmermann on 01.04.21.
//  Copyright © 2021 p≡p. All rights reserved.
//

#import "PEPMember.h"

@class PEPIdentity;

@implementation PEPMember

- (instancetype)initWithIdentity:(PEPIdentity *)identity joined:(BOOL)joined
{
    self = [super init];
    if (self) {
        _identity = identity;
        _joined = joined;
    }
    return self;
}

@end
