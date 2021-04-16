//
//  PEPMember+SecureCoding.m
//  pEpObjCAdapter
//
//  Created by Dirk Zimmermann on 16.04.21.
//  Copyright © 2021 p≡p. All rights reserved.
//

#import "PEPMember+SecureCoding.h"

@implementation PEPMember (SecureCoding)

+ (BOOL)supportsSecureCoding
{
    return YES;
}

- (void)encodeWithCoder:(nonnull NSCoder *)coder
{
}

- (nullable instancetype)initWithCoder:(nonnull NSCoder *)coder
{
    return nil;
}

@end
