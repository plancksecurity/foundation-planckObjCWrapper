//
//  NSObject+Equality.h
//  pEpObjCAdapter
//
//  Created by Dirk Zimmermann on 24.04.18.
//  Copyright © 2018 p≡p. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (Equality)

/// Comparse the given objects for equality, taking into account that they could be nil.
+ (BOOL)isEqualObject1:(id _Nullable)obj1 toObject2:(id _Nullable)obj2;

/// Comparse the given `NSString`s for equality, taking into account that they could be nil.
+ (BOOL)isEqualString1:(NSString * _Nullable)str1 toString2:(NSString * _Nullable)str2;

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
