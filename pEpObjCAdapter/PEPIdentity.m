//
//  PEPIdentity.m
//  pEpObjCAdapter
//
//  Created by Dirk Zimmermann on 30.10.17.
//  Copyright © 2017 p≡p. All rights reserved.
//

#import "PEPIdentity.h"

@implementation PEPIdentity

- (id)initWithAddress:(NSString * _Nonnull)address userName:(NSString * _Nullable)userName
{
    if (self = [super init]) {
        self.address = address;
        self.userName = userName;
    }
    return self;
}

- (id)initWithAddress:(NSString * _Nonnull)address
{
    return [self initWithAddress:address userName:nil];
}

- (BOOL)isEqual:(id)other
{
    if (other == self) {
        return YES;
    } else if (![super isEqual:other]) {
        return NO;
    } else {
        return self.address == ((PEPIdentity *) other).address;
    }
}

- (NSUInteger)hash
{
    return self.address.hash;
}

@end
