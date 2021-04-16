//
//  PEPMember.m
//  pEpObjCAdapter
//
//  Created by Dirk Zimmermann on 01.04.21.
//  Copyright © 2021 p≡p. All rights reserved.
//

#import "PEPMember.h"

#import "PEPIdentity.h"

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

- (BOOL)isEqual:(id)other
{
    if (other == self) {
        return YES;
    } else {
        PEPMember *member = other;
        return [self.identity isEqual:member.identity] && self.joined == member.joined;
    }
}

- (NSUInteger)hash
{
    NSUInteger prime = 31;
    NSUInteger result = 1;

    result = prime * result + [self.identity hash];
    result = prime * result + ((self.joined) ? 1231 : 1237);

    return result;
}

@end
