//
//  PEPIdentity+Comparison.m
//  PEPObjCTypeUtils
//
//  Created by Martín Brude on 14/2/22.
//

#import "PEPIdentity+Comparison.h"

@implementation PEPIdentity (Comparison)

- (BOOL)isEqualToIdentity:(PEPIdentity *)otherIdentity {
    // We have to compare case-insensitive addresses to determine if they are the same identity.
    NSString *selfAddress = (NSString *) [self valueForKey:@"address"];
    NSString *otherAddress = (NSString *) [otherIdentity valueForKey:@"address"];
    return [selfAddress caseInsensitiveCompare:otherAddress] == NSOrderedSame;
}

@end
