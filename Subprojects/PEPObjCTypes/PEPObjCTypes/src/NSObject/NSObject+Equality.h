//
//  NSObject+Equality.h
//  pEpObjCAdapter
//
//  Created by Dirk Zimmermann on 24.04.18.
//  Copyright © 2018 p≡p. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (Equality)

/**
 Invokes `[value1 isEqual:value2]` between all value pairs retrieved
 from `self` and `other`, based on the list of keys.
 @Note `nil` is considered equal to `nil`, in contrast to [NSObject isEqual:].
 */
- (BOOL)isEqualToObject:(NSObject * _Nonnull)other
            basedOnKeys:(NSArray<NSString *> * _Nonnull)keys;

/**
 Calculates a hash based on the given `keys`.
 */
- (NSUInteger)hashBasedOnKeys:(NSArray<NSString *> * _Nonnull)keys;

@end
