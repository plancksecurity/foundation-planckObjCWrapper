//
//  NSObject+Equality.m
//  pEpObjCAdapter
//
//  Created by Dirk Zimmermann on 24.04.18.
//  Copyright © 2018 p≡p. All rights reserved.
//

#import "NSObject+Equality.h"

@implementation NSObject (Extension)

- (BOOL)isEqualToObject:(NSObject * _Nonnull)other
            basedOnKeys:(NSArray<NSString *> * _Nonnull)keys
{
    for (NSString *theKey in keys) {
        NSObject *objSelf = [self valueForKey:theKey];
        NSObject *objOther = [other valueForKey:theKey];

        if (objSelf == nil && objOther == nil) {
            // considered equal, continue
        } else if (![objSelf isEqual:objOther]) {
            // NSValue, NSArray, NSString all have correctly implemented isEqual, so this works
            return NO;
        }
    }

    return YES;
}

- (NSUInteger)hashBasedOnKeys:(NSArray<NSString *> * _Nonnull)keys
{
    NSUInteger prime = 31;
    NSUInteger result = 1;

    for (NSString *theKey in keys) {
        NSObject *objSelf = [self valueForKey:theKey];
        result = prime * result + objSelf.hash;
    }

    return result;
}

@end
