//
//  PEPIdentity+Comparison.h
//  PEPObjCTypeUtils
//
//  Created by Martín Brude on 14/2/22.
//

#import <Foundation/Foundation.h>
#import <PEPIdentity.h>

NS_ASSUME_NONNULL_BEGIN

@interface PEPIdentity (Comparison)

/// Determine if the identity passed by param is the same identity.
///
/// @param otherIdentity The identity to compare.
/// @return YES if it's the same identity. Otherwise it returns NO.
- (BOOL)isEqualToIdentity:(PEPIdentity *)otherIdentity;

@end

NS_ASSUME_NONNULL_END
